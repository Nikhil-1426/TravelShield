from flask import Flask, send_file, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
import os
import pandas as pd

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Initialize the Gemini API with your API key
api_key = "AIzaSyBvPXyV7EzQGMSub6Iz0OJNVZnOFiW6JzI"
genai.configure(api_key=api_key)

# Directory to save uploaded files temporarily
UPLOAD_FOLDER = './uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/')
def home():
    return jsonify({"message": "Welcome to the Travel Health API. Use the /process-travel-health endpoint to upload and process data."})

# Route to handle the analysis request
@app.route('/analyze-travel-health', methods=['POST'])
def analyze_travel_health():
    try:
        # Step 1: Get cities from the request
        current_city = request.form.get('current_city')
        destination_city = request.form.get('destination_city')

        if not current_city or not destination_city:
            return jsonify({"error": "Missing current or destination city"}), 400

        # Step 2: Handle uploaded files
        if 'responses' not in request.files or 'current_city_diet' not in request.files or 'destination_city_diet' not in request.files:
            return jsonify({"error": "Missing necessary files"}), 400

        # Save the uploaded files
        responses_file = request.files['responses']
        current_city_diet_file = request.files['current_city_diet']
        destination_city_diet_file = request.files['destination_city_diet']

        responses_path = os.path.join(UPLOAD_FOLDER, 'responses.json')
        current_city_diet_path = os.path.join(UPLOAD_FOLDER, f'{current_city}_diet.xlsx')
        destination_city_diet_path = os.path.join(UPLOAD_FOLDER, f'{destination_city}_diet.xlsx')

        responses_file.save(responses_path)
        current_city_diet_file.save(current_city_diet_path)
        destination_city_diet_file.save(destination_city_diet_path)

        # Load diet data
        current_city_diet = pd.read_excel(current_city_diet_path)
        destination_city_diet = pd.read_excel(destination_city_diet_path)

        # Step 3: Create a prompt for the analysis
        prompt = (
            f"These are the 3 files: the user responses, diet for {current_city}, and diet for {destination_city}. "
            f"Let's say a person is traveling from {current_city} to {destination_city}. "
            "What are the precautions related to the diet, weather, and health he should be taking?"
        )

        # Step 4: Create a Gemini model instance
        model = genai.GenerativeModel('gemini-1.5-pro')

        # Step 5: Send the files and prompt to Gemini for analysis
        response = model.generate_content([responses_path, current_city_diet_path, destination_city_diet_path, prompt])
        
        # Step 6: Get the analysis from the Gemini response
        analysis_result = response.text

        # Step 7: Return the analysis as JSON response
        return jsonify({'analysis': analysis_result})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)