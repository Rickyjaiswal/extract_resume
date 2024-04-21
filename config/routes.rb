Rails.application.routes.draw do
  post 'extract/parse'
  post 'extract/parse_resume_data'
  post 'extract/parse_resume'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
