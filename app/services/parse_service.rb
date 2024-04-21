class ParseService
  def initialize(resume_text)
    @resume_text = resume_text
  end

  def perform
    name_email_regex = /([\w\s]+)\s+([\w.]+@[^\s@]+\.[^\s@]+)/
    job_title_location_regex = /([A-Za-z\s]+)\s*,\s*([A-Za-z\s]+)/
    education_regex = /HIGHEST EDUCATION:\s*(.*?)\n\n/m
    skills_regex = /skills:\s*:? (.*?)\n\n/mi #/skills\s*:? (.*?)\n\n/mi #
    core_skills_regex = /core_skills:\s*:? (.*?)\n\n/mi
    tools_regex = /TOOLS:\s*(.*?)\n\n/m
    methodologies_regex = /METHODOLOGIES:\s*(.*?)\n\n/m
    experience_highlights_regex = /EXPERIENCEHIGHLIGHTS:\s*(.*?)\n\n/m
    hobbies_regex = /HOBBIES:\s*(.*?)\n\n/m

    name_email_match = @resume_text.match(name_email_regex)
    phone_match = @resume_text.scan(/(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?/).first
    job_title_location_match = @resume_text.match(job_title_location_regex)
    education_match = @resume_text.match(education_regex)
    core_skills_match = @resume_text.match(core_skills_regex)
    skills_match = @resume_text.match(skills_regex)
    tools_match = @resume_text.match(tools_regex)
    methodologies_match = @resume_text.match(methodologies_regex)
    experience_highlights_match = @resume_text.match(experience_highlights_regex)
    hobbies_match = @resume_text.match(hobbies_regex)

    name = name_email_match ? name_email_match[1].strip : "Name not found"
    phone = phone_match ? phone_match : "Phone no not found"
    email = name_email_match ? name_email_match[2].strip : nil
    job_title = job_title_location_match ? job_title_location_match[1].strip : "Job title not found"
    location = job_title_location_match ? job_title_location_match[2].strip : "Location not found"
    education = education_match ? education_match[1].strip : "Education not found"
    core_skills = core_skills_match ? core_skills_match[1].strip.split(", ").map(&:strip).sort_by(&:downcase) : "Core Skills not found"
    skills = skills_match ? skills_match[1].strip.split(", ").map(&:strip).sort_by(&:downcase) : "Skills not found"
    tools = tools_match ? tools_match[1].strip.split(", ").map(&:strip) : "Tools not found"
    methodologies = methodologies_match ? methodologies_match[1].strip.split("\n").map(&:strip) : "Methodologies not found"
    experience_highlights = experience_highlights_match ? experience_highlights_match[1].strip.split("\n").map(&:strip) : "Experience highlights not found"
    hobbies = hobbies_match ? hobbies_match[1].strip.split("\n").map(&:strip) : "Hobbies not found"

    resume_data = {
      name: name,
      phone: phone,
      email: email,
      job_title: job_title,
      location: location,
      education: education,
      core_skills: core_skills,
      skills: skills,
      tools: tools,
      description: methodologies,
      hobbies: hobbies,
      experience: experience_highlights
    }

    resume = ParsedResume.find_or_create_by(email: email) do |r|
      resume_data.each do |attribute, value|
        r[attribute] = value
      end
    end

    return resume_data
  end
end
