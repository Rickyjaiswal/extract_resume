class CreateParsedResumes < ActiveRecord::Migration[6.1]
  def change
    create_table :parsed_resumes do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :job_title
      t.string :location
      t.text :education
      t.text :core_skills
      t.text :skills
      t.text :tools
      t.text :description
      t.text :hobbies
      t.text :experience

      t.timestamps
    end
  end
end
