class Api::V1::ApplicantsController < ApplicationController
  skip_forgery_protection

  def create
    Rails.logger.info("Received params: #{params.inspect}")
    
    applicant_params = extract_applicant_params
    
    if applicant_params[:first_name].blank? || applicant_params[:last_name].blank? || 
       applicant_params[:email].blank? || applicant_params[:resume_url].blank?
      return render json: { success: false, error: 'Missing required fields' }, status: :bad_request
    end

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
      resume_url: applicant_params[:resume_url],
      status: 'pending'
    )

    render json: { success: true, applicant_id: applicant.id }, status: :created
  rescue => e
    Rails.logger.error("Error: #{e.message}")
    render json: { success: false, error: e.message }, status: :bad_request
  end

  def index
    applicants = Applicant.all.order(created_at: :desc)
    render json: { 
      success: true, 
      data: applicants.map { |a| a.attributes }
    }
  rescue => e
    Rails.logger.error("Index error: #{e.message}")
    render json: { success: false, error: e.message }, status: :bad_request
  end

  def show
    applicant = Applicant.find(params[:id])
    render json: { success: true, data: applicant.attributes }
  rescue => e
    render json: { success: false, error: 'Not found' }, status: :not_found
  end

  private

  def extract_applicant_params
    {
      first_name: params[:first_name] || '',
      last_name: params[:last_name] || '',
      email: params[:email] || '',
      phone: params[:phone],
      resume_url: params[:resume_url],
      position_of_interest: params[:position_of_interest],
      expected_salary: params[:expected_salary],
      years_of_experience: params[:years_of_experience],
      linkedin_profile: params[:linkedin_profile],
      tech_stack: params[:tech_stack],
      why_montani: params[:why_montani],
      heard_about_us: params[:heard_about_us],
      timeline_to_start: params[:timeline_to_start]
    }
  end
end
