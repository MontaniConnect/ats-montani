class Applicant < ApplicationRecord
  
    # Associations
    has_many :submission_logs, dependent: :destroy
  
    # Enums
    enum :status, { pending: 'pending', reviewed: 'reviewed', rejected: 'rejected', hired: 'hired' }
    enum :heard_about_us, { 
      indeed: 'Indeed',
      jobstreet: 'Jobstreet',
      linkedin: 'LinkedIn',
      social_media: 'Social Media',
      referrals: 'Referrals'
    }
    enum :timeline_to_start, {
      asap: 'ASAP',
      one_week: '1 week',
      two_to_four_weeks: '2-4 weeks',
      more_than_four_weeks: '>4 weeks'
    }
  
    # Validations
    validates :first_name, :last_name, :email, presence: true, length: { minimum: 2, maximum: 255 }
    validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :phone, allow_blank: true, length: { minimum: 7, maximum: 20 }
    validates :resume_url, presence: true
    validates :status, presence: true, inclusion: { in: %w(pending reviewed rejected hired) }
  
    # Callbacks
    before_create :set_defaults
    after_create :log_submission
  
    # Scopes
    scope :by_position, ->(position) { where(position_of_interest: position) }
    scope :by_status, ->(status) { where(status: status) }
    scope :by_source, ->(source) { where(heard_about_us: source) }
    scope :recent, -> { order(created_at: :desc) }
    scope :search, ->(query) { 
      where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
    }
  
    # Instance Methods
    
    def full_name
      "#{first_name} #{last_name}"
    end
  
    def days_since_submission
      ((Time.current - created_at) / 1.day).to_i
    end
  
    def download_resume
      # Download resume from Supabase Storage
      if resume_url.present?
        begin
          response = HTTParty.get(resume_url)
          response.body if response.success?
        rescue => e
          Rails.logger.error("Failed to download resume: #{e.message}")
          nil
        end
      end
    end
  
    def mark_as_reviewed(reviewer = nil)
      update(status: :reviewed, reviewed_at: Time.current, reviewed_by: reviewer)
      log_submission('MARKED_REVIEWED', { reviewed_by: reviewer })
    end
  
    def mark_as_hired(reviewer = nil)
      update(status: :hired, reviewed_at: Time.current, reviewed_by: reviewer)
      log_submission('MARKED_HIRED', { reviewed_by: reviewer })
    end
  
    def mark_as_rejected(reviewer = nil)
      update(status: :rejected, reviewed_at: Time.current, reviewed_by: reviewer)
      log_submission('MARKED_REJECTED', { reviewed_by: reviewer })
    end
  
    def to_csv_row
      [
        full_name,
        email,
        phone,
        position_of_interest,
        years_of_experience,
        expected_salary,
        tech_stack,
        why_montani,
        heard_about_us,
        timeline_to_start,
        status,
        linkedin_profile,
        created_at.strftime('%Y-%m-%d %H:%M:%S'),
        days_since_submission
      ]
    end
  
    private
  
    def set_defaults
      self.status ||= 'pending'
    end
  
    def log_submission(action = 'SUBMISSION_CREATED', details = {})
      submission_logs.create(
        action: action,
        details: details.merge({
          ip_address: ip_address,
          user_agent: user_agent
        })
      )
    end
  end
  

  