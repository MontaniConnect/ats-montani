# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2024_05_26_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "applicants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "expected_salary"
    t.string "first_name", null: false
    t.string "heard_about_us"
    t.string "last_name", null: false
    t.string "linkedin_profile"
    t.text "notes"
    t.string "phone"
    t.string "position_of_interest"
    t.string "resume_file_name"
    t.string "resume_file_path"
    t.integer "resume_file_size"
    t.string "resume_url"
    t.datetime "reviewed_at"
    t.string "reviewed_by"
    t.string "status", default: "pending"
    t.text "tech_stack"
    t.string "timeline_to_start"
    t.datetime "updated_at", null: false
    t.text "why_montani"
    t.string "years_of_experience"
    t.index ["created_at"], name: "index_applicants_on_created_at"
    t.index ["email"], name: "index_applicants_on_email", unique: true
    t.index ["position_of_interest"], name: "index_applicants_on_position_of_interest"
    t.index ["status"], name: "index_applicants_on_status"
  end

  create_table "submission_logs", force: :cascade do |t|
    t.string "action"
    t.bigint "applicant_id", null: false
    t.datetime "created_at", null: false
    t.json "details"
    t.text "error_message"
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["applicant_id", "action"], name: "index_submission_logs_on_applicant_id_and_action"
    t.index ["applicant_id"], name: "index_submission_logs_on_applicant_id"
    t.index ["created_at"], name: "index_submission_logs_on_created_at"
  end

  add_foreign_key "submission_logs", "applicants"
end
