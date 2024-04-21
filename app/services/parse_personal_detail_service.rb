class ParsePersonalDetailService
  def initialize(resume_text)
    @resume_text = resume_text
  end

  def perform
    personal_details = {}
    name_email_regex = /([\w\s]+)\s+([\w.]+@[^\s@]+\.[^\s@]+)/
    matches = @resume_text.match(name_email_regex)
    if matches.present?
      personal_details[:name] = matches[1]
      personal_details[:email] = matches[2]
    else
      personal_details[:name] = @resume_text.scan(/Name:\s*(.*?)\s/).flatten.first

      # Extract email
      personal_details[:email] = @resume_text.scan(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/).first
    end
   
    personal_details[:phone] = @resume_text.scan(/(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?/).first
    # personal_details[:SKILLS] = @resume_text.match(/SKILLS:\s*\n\s*(.*?)(?=\n\n|\z)/m)[1].split(',').map(&:strip) || @resume_text.match(/skills:\s*\n\s*(.*?)(?=\n\n|\z)/m)[1].split(',').map(&:strip)
    skills_section_regex = /SKILLS[\s\S]+?(?=(?:\n\n[A-Z]+|$))/
    personal_details[:SKILLS] = @resume_text.match(skills_section_regex)
    # personal_details[:SKILLS] = @resume_text.match(/(?:s|S)KILLS:\s*(.*?)(?:\n\n|\z)/m)[1].split(',').map(&:strip)
    personal_details[:HOBBIES] = @resume_text.match(/(?:h|H)OBBIES:\s*(.*?)(?:\n\n|\z)/m)[1].split(',').map(&:strip)
    if @resume_text.match(/(?:l|L)ANGUAGES:\s*(.*?)(?:\n\n|\z)/m).present?
      personal_details[:LANGUAGES] = @resume_text.match(/(?:l|L)ANGUAGES:\s*(.*?)(?:\n\n|\z)/m)[1].split(',').map(&:strip)
    else
      personal_details[:LANGUAGES] = []
    end
    if @resume_text.match(/social_profiles:\s*\n\s*(.*?)(?=\n\n|\z)/m).present?
      personal_details[:social_profiles] = @resume_text.match(/social_profiles:\s*\n\s*(.*?)(?=\n\n|\z)/m)[1].split(',').map(&:strip)
    else
      personal_details[:social_profiles] = []
    end
    if @resume_text.match(/educations:\s*\n\s*(.*?)(?=\n\n|\z)/m).present?
      personal_details[:educations] = @resume_text.match(/educations:\s*\n\s*(.*?)(?=\n\n|\z)/m)[1].split(',').map(&:strip) || @resume_text.match(/higher_educations:\s*\n\s*(.*?)(?=\n\n|\z)/m)[1].split(',').map(&:strip)
    else
      personal_details[:educations] = []
    end
    if @resume_text.match(/work_experiences:\s*\n\s*(.*?)(?=\n\n|\z)/m).present?
      personal_details[:work_experiences] = @resume_text.match(/work_experiences:\s*\n\s*(.*?)(?=\n\n|\z)/m)[1].split(',').map(&:strip) || @resume_text.match(/(?:e|E)XPERIENCES:\s*(.*?)(?:\n\n|\z)/m)[1].split(',').map(&:strip)
    else
      personal_details[:work_experiences] = []
    end
    return personal_details
  # rescue StandardError => e
  #   return 'Something went wrong'
  end
end