class CreateApplicants < ActiveRecord::Migration[8.1]
    def change
      create_table :applicants do |t|
        t.string :first_name, null: false
        t.string :last_name, null: false
        t.string :email, null: false
        t.string :phone
  
        t.string :resume_file_path
        t.integer :resume_file_size
        t.string :resume_url
        t.string :resume_file_name
  
        t.string :position_of_interest
        t.string :expected_salary
        t.string :years_of_experience
        t.string :linkedin_profile
  
        t.text :tech_stack
        t.text :why_montani
        t.string :heard_about_us
        t.string :timeline_to_start
  
        t.string :status, default: 'pending'
        t.text :notes
        t.datetime :reviewed_at
        t.string :reviewed_by
  
        t.timestamps
      end
  
      add_index :applicants, :email, unique: true
      add_index :applicants, :status
      add_index :applicants, :created_at
      add_index :applicants, :position_of_interest
    end
  end