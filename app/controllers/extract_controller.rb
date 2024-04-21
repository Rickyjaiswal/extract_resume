require 'open-uri'
require 'pdf-reader'
require 'pdf/reader'
require 'docx'
class ExtractController < ApplicationController

  def parse_resume
    parse_resume_with_service(ParseService)
  end

  def parse_resume_data
    parse_resume_with_service(ParsePersonalDetailService)
  end

  def parse
    parse_resume_with_service(ParserpyService)
  end

  private

  def parse_resume_with_service(service_class)
    begin
      file_extension = File.extname(params[:file].original_filename).downcase
      resume_text = case file_extension
                    when '.pdf'
                      extract_text_from_pdf(params[:file].tempfile)
                    when '.docx'
                      extract_text_from_doc(params[:file].tempfile.path)
                    else
                      raise ArgumentError, 'Unknown file type.'
                    end

      resume_data = service_class.new(resume_text).perform
      # render json: { resume_data: resume_data }, status: :ok
      render plain: resume_text, status: :ok
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: 'An error occurred while parsing the resume.' }, status: :internal_server_error
    end
  end


  def extract_text_from_doc(doc_file)
    text = ''
    doc = Docx::Document.open(doc_file)
    doc.paragraphs.each do |paragraph|
      text << paragraph.text
    end

    text
  end

  def extract_text_from_pdf(pdf_file)
    text = ''
    open(pdf_file, 'rb') do |io|
      reader = PDF::Reader.new(io)
      reader.pages.each do |page|
        text << page.text
      end
    end
    text
  end

end
