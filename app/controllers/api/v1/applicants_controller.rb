# ... [keep everything the same until the extract_applicant_params method]

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

  # ... [rest of the methods stay the same]
