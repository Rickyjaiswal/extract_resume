import spacy
from spacy.matcher import PhraseMatcher
import fitz  # PyMuPDF
import re
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
    sections = {
        'Profile': [],
        'Summary': [],
        'Education': [],
        'Experience': [],
        'Skills': [],
        'Certificates': [],
        'Hobbies': [],
        'Projects': [],
        'TOOLS': [],
        'METHODOLOGIES': [],
        'User Details': [],
        'CoreSkills': []
    }

    # Regular expressions for finding emails and phone numbers
    email_pattern = re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
    phone_pattern = re.compile(r'\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}')

    # Find emails and phone numbers
    emails = email_pattern.findall(text)
    phones = phone_pattern.findall(text)

    # Extract name and address
    name = None
    address = None

    # Assuming the name is the first line or first entity recognized as PERSON
    for ent in doc.ents:
        if ent.label_ == 'PERSON' and not name:
            name = ent.text
            break
    
    # Look for entities tagged as GPE or LOC for addresses
    address_candidates = [ent.text for ent in doc.ents if ent.label_ in ['GPE', 'LOC']]
    if address_candidates:
        address = ', '.join(address_candidates)

    # Custom logic to identify sections
    lines = text.split('\n')
    current_section = None
    
    for line in lines:
        line = line.strip()
        if 'profile' in line.lower() or 'objective' in line.lower():
            current_section = 'Profile'
        elif 'summary' in line.lower():
            current_section = 'Summary'
        elif 'coreskills' in line.lower():
            current_section = 'CoreSkills'
        elif 'education' in line.lower():
            current_section = 'Education'
        elif 'experience' in line.lower() or 'employment history' in line.lower():
            current_section = 'Experience'
        elif 'skills' in line.lower():
            current_section = 'Skills'
        elif 'tools' in line.lower():
            current_section = 'TOOLS'
        elif 'methodologies' in line.lower():
            current_section = 'METHODOLOGIES'
        elif 'certificates' in line.lower() or 'certifications' in line.lower():
            current_section = 'Certificates'
        elif 'hobbies' in line.lower() or 'interests' in line.lower():
            current_section = 'Hobbies'
        elif 'projects' in line.lower() or 'portfolio' in line.lower():
            current_section = 'Projects'
        elif current_section:
            sections[current_section].append(line)

    # Print sections and entities
    for section, content in sections.items():
        print(f"Section: {section}")
        for item in content:
            print(f"  - {item}")
    sections['User Details'].append(f"\nContact Information:\nName: {name}\nEmail: {', '.join(emails)}\nPhone: {', '.join(phones)}\nAddress: {address}")
    print("\nNamed Entities:")
    for entity in doc.ents:
        print(f"{entity.label_}: {entity.text}")

    # Print contact information
    print(f"\nContact Information:\nName: {name}\nEmail: {', '.join(emails)}\nPhone: {', '.join(phones)}\nAddress: {address}")

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