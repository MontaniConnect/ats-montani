class CreateSubmissionLogs < ActiveRecord::Migration[8.1]
    def change
      create_table :submission_logs do |t|
        t.references :applicant, null: false, foreign_key: true
        t.string :action
        t.json :details
        t.text :error_message
        t.string :ip_address
        t.string :user_agent
  
        t.timestamps
      end
  
      add_index :submission_logs, :created_at
      add_index :submission_logs, [:applicant_id, :action]
    end
  end