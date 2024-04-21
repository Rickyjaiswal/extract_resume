import spacy
from spacy.matcher import PhraseMatcher
import fitz  # PyMuPDF
from flask import Flask, request, jsonify


app = Flask(__name__)

# Load spaCy model
nlp = spacy.load("en_core_web_sm")

# Function to extract text from PDF
# def extract_text_from_pdf(pdf_path):
#     doc = fitz.open(pdf_path)
#     text = ""
#     for page in doc:
#         text += page.get_text()
#     return text

# Function to extract information using spaCy
# def parse_resume(text):
#     doc = nlp(text)
#     # Example: Extracting names and organizations
#     for entity in doc.ents:
#         if entity.label_ in ["PERSON", "ORG"]:
#             print(f"{entity.label_}: {entity.text}")

# Function to extract sections and entities using spaCy
@app.route('/parse_resume', methods=['POST'])
def parse_resume():
    text = request.json.get('text')
    doc = nlp(text)
    sections = {'Education': [], 'Experience': [], 'Skills': [], 'Certificates': [], 'Employment': [], 'User Details': [], 'HOBBIES': []}

    # Custom logic to identify sections (simple example based on newlines and keywords)
    lines = text.split('\n')
    current_section = None
    
    for line in lines:
        line = line.strip()
        if 'education' in line.lower():
            current_section = 'Education'
        elif 'details' in line.lower() or any(kw in line.lower() for kw in ['phone', 'email', 'address']):
            current_section = 'User Details'
        elif 'experience' in line.lower():
            current_section = 'Experience'
        elif 'skills' in line.lower():
            current_section = 'Skills'
        elif 'hobbies' in line.lower():
            current_section = 'HOBBIES'
        elif 'employment' in line.lower():
            current_section = 'Employment'
        elif 'certificates' in line.lower() or 'certifications' in line.lower():
            current_section = 'Certificates'
        elif current_section:
            sections[current_section].append(line)

    # Print sections and entities
    for section, content in sections.items():
        print(f"Section: {section}")
        for item in content:
            print(f"  - {item}")
    
    print("\nNamed Entities:")
    for entity in doc.ents:
        print(f"{entity.label_}: {entity.text}")

    entities = {entity.label_: entity.text for entity in doc.ents}
    
    return jsonify({
        'sections': sections,
        'named_entities': entities
    })

# Example PDF path
# pdf_path = 'sample.pdf'
# text = extract_text_from_pdf(pdf_path)
# parse_resume(text)

if __name__ == '__main__' : 
    app.run(debug=True)