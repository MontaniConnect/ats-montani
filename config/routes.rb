Rails.application.routes.draw do
  # API Routes
  namespace :api do
    namespace :v1 do
      # Applicants endpoints
      resources :applicants do
        collection do
          get :stats
          get :export_csv
        end
        member do
          patch :mark_as_reviewed
          patch :mark_as_hired
          patch :mark_as_rejected
        end
      end
    end
  end

  # Dashboard Routes
  root 'dashboard#index'
  
  get '/dashboard', to: 'dashboard#index'
  get '/dashboard/applicants', to: 'dashboard#applicants'
  get '/dashboard/applicants/:id', to: 'dashboard#show'
  get '/dashboard/stats', to: 'dashboard#stats'
  get '/dashboard/settings', to: 'dashboard#settings'

  # Health check
  get '/health', to: 'health#check'

  # API documentation
  get '/api/docs', to: 'api#docs'
end

# config/routes/api.rb (if using modular routing)
# namespace :api do
#   namespace :v1 do
#     resources :applicants do
#       collection do
#         get :stats
#         get :export_csv
#       end
#       member do
#         patch :mark_as_reviewed
#         patch :mark_as_hired
#         patch :mark_as_rejected
#       end
#     end
#   end
# end
# Rebuild
