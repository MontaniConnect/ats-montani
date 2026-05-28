# class Api::ApplicantsController < ApplicationController
#   skip_forgery_protection
#   before_action :validate_api_key, only: [:create]

#   # POST /api/applicants
#   def create
#     Rails.logger.info("Received applicant submission: #{params.inspect}")

#     # Extract data from Zapier format (data__ prefixed fields)
#     applicant_params = extract_applicant_params

#     # Validate required fields
#     if applicant_params[:first_name].blank? || 
#        applicant_params[:last_name].blank? || 
#        applicant_params[:email].blank? || 
#        applicant_params[:resume_url].blank?
      
#       return render json: { 
#         success: false, 
#         error: 'Missing required fields: first_name, last_name, email, resume_url',
#         received: applicant_params
#       }, status: :bad_request
#     end

#     begin
#       # Download and upload resume to Supabase
#       resume_data = download_resume(applicant_params[:resume_url])
      
#       if resume_data.nil?
#         return render json: { 
#           success: false, 
#           error: 'Failed to download resume from Webflow'
#         }, status: :bad_request
#       end

#       # Upload to Supabase Storage
#       resume_path, resume_size = upload_to_supabase(resume_data, applicant_params[:email])

#       # Create applicant record
#       applicant = Applicant.create!(
#         first_name: applicant_params[:first_name],
#         last_name: applicant_params[:last_name],
#         email: applicant_params[:email],
#         phone: applicant_params[:phone],
#         position_of_interest: applicant_params[:position_of_interest],
#         expected_salary: applicant_params[:expected_salary],
#         years_of_experience: applicant_params[:years_of_experience],
#         linkedin_profile: applicant_params[:linkedin_profile],
#         tech_stack: applicant_params[:tech_stack],
#         why_montani: applicant_params[:why_montani],
#         heard_about_us: applicant_params[:heard_about_us],
#         timeline_to_start: applicant_params[:timeline_to_start],
#         resume_file_path: resume_path,
#         resume_file_size: resume_size,
#         resume_url: "#{ENV['SUPABASE_URL']}/storage/v1/object/public/resumes/#{resume_path}",
#         status: 'pending',
#         ip_address: request.remote_ip,
#         user_agent: request.user_agent
#       )

#       Rails.logger.info("Applicant created successfully: #{applicant.id}")

#       render json: {
#         success: true,
#         message: 'Resume submitted successfully',
#         applicant_id: applicant.id,
#         resume_url: applicant.resume_url,
#         timestamp: Time.current.iso8601
#       }, status: :created

#     rescue => e
#       Rails.logger.error("Error processing applicant: #{e.message}\n#{e.backtrace.join("\n")}")

#       render json: {
#         success: false,
#         error: e.message,
#         timestamp: Time.current.iso8601
#       }, status: :internal_server_error
#     end
#   end

#   # GET /api/applicants
#   def index
#     applicants = Applicant.recent

#     # Filtering
#     applicants = applicants.by_status(params[:status]) if params[:status].present?
#     applicants = applicants.by_position(params[:position]) if params[:position].present?
#     applicants = applicants.by_source(params[:source]) if params[:source].present?
#     applicants = applicants.search(params[:search]) if params[:search].present?

#     # Pagination
#     page = params[:page] || 1
#     per_page = params[:per_page] || 20
#     applicants = applicants.page(page).per(per_page)

#     render json: {
#       success: true,
#       data: ActiveModelSerializers::CollectionSerializer.new(applicants, serializer: ApplicantSerializer),
#       pagination: {
#         current_page: applicants.current_page,
#         total_pages: applicants.total_pages,
#         total_count: applicants.total_count,
#         per_page: per_page
#       }
#     }, status: :ok
#   end

#   # GET /api/applicants/:id
#   def show
#     applicant = Applicant.find(params[:id])
#     render json: { success: true, data: ApplicantSerializer.new(applicant) }, status: :ok
#   rescue ActiveRecord::RecordNotFound
#     render json: { success: false, error: 'Applicant not found' }, status: :not_found
#   end

#   # PATCH/PUT /api/applicants/:id
#   def update
#     applicant = Applicant.find(params[:id])
    
#     if applicant.update(applicant_update_params)
#       render json: { 
#         success: true, 
#         data: ApplicantSerializer.new(applicant),
#         message: 'Applicant updated successfully'
#       }, status: :ok
#     else
#       render json: { 
#         success: false, 
#         errors: applicant.errors.full_messages 
#       }, status: :unprocessable_entity
#     end
#   rescue ActiveRecord::RecordNotFound
#     render json: { success: false, error: 'Applicant not found' }, status: :not_found
#   end

#   # DELETE /api/applicants/:id
#   def destroy
#     applicant = Applicant.find(params[:id])
#     applicant.destroy
#     render json: { success: true, message: 'Applicant deleted successfully' }, status: :ok
#   rescue ActiveRecord::RecordNotFound
#     render json: { success: false, error: 'Applicant not found' }, status: :not_found
#   end

#   # GET /api/applicants/stats/overview
#   def stats
#     stats = ApplicantStats.first || {}
    
#     render json: {
#       success: true,
#       data: {
#         total_submissions: stats['total_submissions'] || 0,
#         pending: stats['pending'] || 0,
#         reviewed: stats['reviewed'] || 0,
#         rejected: stats['rejected'] || 0,
#         hired: stats['hired'] || 0,
#         unique_positions: stats['unique_positions'] || 0,
#         avg_resume_size_mb: stats['avg_resume_size_mb'] || 0,
#         latest_submission: stats['latest_submission']
#       }
#     }, status: :ok
#   end

#   private

#   def extract_applicant_params
#     {
#       first_name: params['data__First Name'] || params['first_name'] || '',
#       last_name: params['data__Last Name'] || params['last_name'] || '',
#       email: params['data__Email'] || params['email'] || '',
#       phone: params['data__Phone Number'] || params['phone'],
#       resume_url: params['data__Resume'] || params['resume_url'],
#       position_of_interest: params['data__Position of Interest'] || params['position_of_interest'],
#       expected_salary: params['data__Expected Salary'] || params['expected_salary'],
#       years_of_experience: params['data__Years of Experience'] || params['years_of_experience'],
#       linkedin_profile: params['data__LinkedIn Profile'] || params['linkedin_profile'],
#       tech_stack: params['data__Techstack'] || params['tech_stack'],
#       why_montani: params['data__Why do you want to work at Montani?'] || params['why_montani'],
#       heard_about_us: params['data__Where did you hear about us?'] || params['heard_about_us'],
#       timeline_to_start: params['data__What\'s your timeline to start?'] || params['timeline_to_start']
#     }
#   end

#   def applicant_update_params
#     params.require(:applicant).permit(
#       :status, :notes, :position_of_interest, :expected_salary,
#       :years_of_experience, :linkedin_profile, :tech_stack, :why_montani
#     )
#   end

#   def download_resume(url)
#     return nil if url.blank?

#     begin
#       response = HTTParty.get(url, timeout: 30)
#       response.body if response.success?
#     rescue => e
#       Rails.logger.error("Failed to download resume: #{e.message}")
#       nil
#     end
#   end

#   def upload_to_supabase(file_data, email)
#     require 'supabase'

#     client = Supabase::Client.new(
#       ENV['SUPABASE_URL'],
#       ENV['SUPABASE_KEY']
#     )

#     timestamp = Time.current.to_i
#     sanitized_email = email.split('@').first.gsub(/[^a-z0-9]/i, '')
#     file_path = "resumes/#{sanitized_email}-#{timestamp}.pdf"

#     begin
#       response = client.storage.from('resumes').upload(file_path, file_data)
#       [file_path, file_data.size]
#     rescue => e
#       Rails.logger.error("Failed to upload to Supabase: #{e.message}")
#       raise "Supabase upload failed: #{e.message}"
#     end
#   end

#   def validate_api_key
#     # Optional: Add API key validation if needed
#     # token = request.headers['Authorization']&.split(' ')&.last
#     # render json: { error: 'Unauthorized' }, status: :unauthorized unless valid_token?(token)
#   end
# end

# # View for stats
# class ApplicantStats < ApplicationRecord
#   self.table_name = 'applicant_stats'
#   self.primary_key = nil
# end


class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end