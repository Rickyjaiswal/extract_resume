require 'uri'
require 'net/http'
require 'json'

class ParserpyService
  def initialize(pdf_text)
    @pdf_text = pdf_text
  end

  def get_name(string)
    name_regex = /Name:\s*(\w+)/
    name_match = string[0].match(name_regex)
    if name_match.present?
     return name_match[1] 
    else
      return "Name not found"
    end
    email = email_match[1] if email_match
  end

  def get_email(string)
    email_regex = /Email:\s*([^\s@]+@[^\s@]+\.[^\s@]+)/
    email_match = string[0].match(email_regex)

    if email_match.present?
     return email_match[1] 
    else
      return nil
    end
  end

  def get_phone(string)
    string[0].scan(/\b\d{10}\b/)
  end

  def get_location(string)
    string[0].scan(/[A-Z][a-z]+(?: [A-Z][a-z]+)*, [A-Z][a-z]+(?: [A-Z][a-z]+)*(?:, [A-Z][a-z]+)?/)
  end

  def get_job_title(string)
    string[0].scan(/\b[A-Z][a-z]+\b/)
  end

  def perform
    url = URI("http://localhost:5000/parse_resume")
    payload = { text: @pdf_text }

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json

    response = http.request(request)
    data = JSON.parse(response.body)
    resume_data = {
      name: get_name(data['sections']['User Details']),
      phone: get_phone(data['sections']['User Details']),
      email: get_email(data['sections']['User Details']),
      job_title: get_job_title(data['sections']['User Details']),
      location: get_location(data['sections']['User Details']),
      education: data['sections']['Education'],
      core_skills: data['sections']['CoreSkills'],
      skills: data['sections']['Skills'].map(&:strip).sort_by(&:downcase),
      tools: data['sections']['TOOLS'],
      description: data['sections']['METHODOLOGIES'],
      hobbies: data['sections']['Hobbies'],
      experience: data['sections']['Experience']
    }

    resume = ParsedResume.find_or_initialize_by(email: resume_data[:email])
    resume.assign_attributes(resume_data)
    resume.save

    resume_data
  end
end