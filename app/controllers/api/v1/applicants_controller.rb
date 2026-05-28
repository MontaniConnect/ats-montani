class Api::V1::ApplicantsController < ApplicationController
  skip_forgery_protection
  before_action :validate_api_key, only: [:create]

  def create
    Rails.logger.info("Received applicant submission: #{params.inspect}")

    applicant_params = extract_applicant_params

    if applicant_params[:first_name].blank? || 
       applicant_params[:last_name].blank? || 
       applicant_params[:email].blank? || 
       applicant_params[:resume_url].blank?
      
      return render json: { 
        success: false, 
        error: 'Missing required fields: first_name, last_name, email, resume_url',
        received: applicant_params
      }, status: :bad_request
    end

    begin
      # Create applicant record with resume URL directly (skip download)
      applicant = Applicant.create!(
        first_name: applicant_params[:first_name],
        last_name: applicant_params[:last_name],
        email: applicant_params[:email],
        phone: applicant_params[:phone],
        position_of_interest: applicant_params[:position_of_interest],
        expected_salary: applicant_params[:expected_salary],
        years_of_experience: applicant_params[:years_of_experience],
        linkedin_profile: applicant_params[:linkedin_profile],
        tech_stack: applicant_params[:tech_stack],
        why_montani: applicant_params[:why_montani],
        heard_about_us: applicant_params[:heard_about_us],
        timeline_to_start: applicant_params[:timeline_to_start],
        resume_url: applicant_params[:resume_url],  # Store URL directly
        status: 'pending',
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )

      Rails.logger.info("Applicant created successfully: #{applicant.id}")

      render json: {
        success: true,
        message: 'Application submitted successfully',
        applicant_id: applicant.id,
        resume_url: applicant.resume_url,
        timestamp: Time.current.iso8601
      }, status: :created

    rescue => e
      Rails.logger.error("Error processing applicant: #{e.message}\n#{e.backtrace.join("\n")}")

      render json: {
        success: false,
        error: e.message,
        timestamp: Time.current.iso8601
      }, status: :internal_server_error
    end
  end

  def index
    applicants = Applicant.recent

    applicants = applicants.by_status(params[:status]) if params[:status].present?
    applicants = applicants.by_position(params[:position]) if params[:position].present?
    applicants = applicants.by_source(params[:source]) if params[:source].present?
    applicants = applicants.search(params[:search]) if params[:search].present?

    page = params[:page] || 1
    per_page = params[:per_page] || 20
    applicants = applicants.page(page).per(per_page)

    render json: {
      success: true,
      data: applicants.map { |app| ApplicantSerializer.new(app).as_json },
      pagination: {
        current_page: applicants.current_page,
        total_pages: applicants.total_pages,
        total_count: applicants.total_count,
        per_page: per_page
      }
    }, status: :ok
  end

  def show
    applicant = Applicant.find(params[:id])
    render json: { success: true, data: ApplicantSerializer.new(applicant) }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Applicant not found' }, status: :not_found
  end

  def update
    applicant = Applicant.find(params[:id])
    
    if applicant.update(applicant_update_params)
      render json: { 
        success: true, 
        data: ApplicantSerializer.new(applicant),
        message: 'Applicant updated successfully'
      }, status: :ok
    else
      render json: { 
        success: false, 
        errors: applicant.errors.full_messages 
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Applicant not found' }, status: :not_found
  end

  def destroy
    applicant = Applicant.find(params[:id])
    applicant.destroy
    render json: { success: true, message: 'Applicant deleted successfully' }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Applicant not found' }, status: :not_found
  end

  def stats
    stats = ApplicantStats.first || {}
    
    render json: {
      success: true,
      data: {
        total_submissions: stats['total_submissions'] || 0,
        pending: stats['pending'] || 0,
        reviewed: stats['reviewed'] || 0,
        rejected: stats['rejected'] || 0,
        hired: stats['hired'] || 0,
        unique_positions: stats['unique_positions'] || 0,
        avg_resume_size_mb: stats['avg_resume_size_mb'] || 0,
        latest_submission: stats['latest_submission']
      }
    }, status: :ok
  end

  private

  def extract_applicant_params
    {
      first_name: params['first_name'] || params['data__First Name'] || '',
      last_name: params['last_name'] || params['data__Last Name'] || '',
      email: params['email'] || params['data__Email'] || '',
      phone: params['phone'] || params['data__Phone Number'],
      resume_url: params['resume_url'] || params['data__Resume'],
      position_of_interest: params['position_of_interest'] || params['data__Position of Interest'],
      expected_salary: params['expected_salary'] || params['data__Expected Salary'],
      years_of_experience: params['years_of_experience'] || params['data__Years of Experience'],
      linkedin_profile: params['linkedin_profile'] || params['data__LinkedIn Profile'],
      tech_stack: params['tech_stack'] || params['data__Techstack'],
      why_montani: params['why_montani'] || params['data__Why do you want to work at Montani?'],
      heard_about_us: params['heard_about_us'] || params['data__Where did you hear about us?'],
      timeline_to_start: params['timeline_to_start'] || params['data__What\'s your timeline to start?']
    }
  end

  def applicant_update_params
    params.require(:applicant).permit(
      :status, :notes, :position_of_interest, :expected_salary,
      :years_of_experience, :linkedin_profile, :tech_stack, :why_montani
    )
  end

  def validate_api_key
    # Optional: Add API key validation if needed
  end
end
