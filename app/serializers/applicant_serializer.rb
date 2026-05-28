class ApplicantSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :phone, :full_name,
               :position_of_interest, :expected_salary, :years_of_experience,
               :linkedin_profile, :tech_stack, :why_montani, :heard_about_us,
               :timeline_to_start, :resume_url, :resume_file_size, :status,
               :created_at, :reviewed_at, :days_since_submission
  
    def days_since_submission
      object.days_since_submission
    end
  
    def full_name
      object.full_name
    end
  end