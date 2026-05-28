class DashboardController < ApplicationController
    skip_forgery_protection
    
    # Dashboard home page - serves React app
    def index
      render :index
    end
  
    # API endpoints for dashboard
    def applicants
      page = params[:page] || 1
      per_page = params[:per_page] || 20
      status = params[:status] || 'all'
      search = params[:search]
  
      applicants = Applicant.recent
  
      # Filter by status
      applicants = applicants.where(status: status) if status != 'all'
  
      # Search
      applicants = applicants.search(search) if search.present?
  
      # Pagination
      applicants = applicants.page(page).per(per_page)
  
      render json: {
        success: true,
        data: ActiveModelSerializers::CollectionSerializer.new(applicants, serializer: ApplicantSerializer),
        pagination: {
          current_page: applicants.current_page,
          total_pages: applicants.total_pages,
          total_count: applicants.total_count
        }
      }
    end
  
    def show
      applicant = Applicant.find(params[:id])
      render json: { success: true, data: ApplicantSerializer.new(applicant) }
    rescue ActiveRecord::RecordNotFound
      render json: { success: false, error: 'Not found' }, status: :not_found
    end
  
    def stats
      stats = {
        total: Applicant.count,
        pending: Applicant.where(status: 'pending').count,
        reviewed: Applicant.where(status: 'reviewed').count,
        rejected: Applicant.where(status: 'rejected').count,
        hired: Applicant.where(status: 'hired').count,
        by_position: Applicant.group(:position_of_interest).count,
        by_source: Applicant.group(:heard_about_us).count
      }
  
      render json: { success: true, data: stats }
    end
  
    def settings
      # Return dashboard settings
      render json: { 
        success: true, 
        data: {
          title: 'Job Applications Dashboard',
          version: '1.0.0',
          supported_positions: [
            'Salesforce Administrator',
            'Salesforce Developer',
            'Business Analyst',
            'Manager',
            'Intern'
          ]
        }
      }
    end
  end
  
  # app/views/dashboard/index.html.erb
  # This serves the React dashboard
  # The React app will be in app/javascript/components/Dashboard.jsx
  