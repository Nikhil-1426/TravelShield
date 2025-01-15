from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
import os
import pandas as pd
import json

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
    return jsonify({"message": "Welcome to the Travel Health API. Use the /analyze-travel-health endpoint to upload and process data."})

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

        # Step 3: Convert files to supported formats
        # Convert JSON to plain text
        with open(responses_path, 'r') as responses_file:
            responses_content = responses_file.read()

        # Convert Excel to plain text (Markdown or CSV)
        current_city_diet = pd.read_excel(current_city_diet_path)
        current_city_diet_text = current_city_diet.to_csv(index=False)

        destination_city_diet = pd.read_excel(destination_city_diet_path)
        destination_city_diet_text = destination_city_diet.to_csv(index=False)

        # Step 4: Create a prompt for the analysis
        prompt = (
            f"Analyze the following travel scenario:\n"
            f"- Current city: {current_city}\n"
            f"- Destination city: {destination_city}\n\n"
            f"Attached are:\n"
            f"1. User responses (plain text).\n"
            f"2. Diet information for {current_city} (CSV format).\n"
            f"3. Diet information for {destination_city} (CSV format).\n\n"
            f"Provide a concise analysis covering only the following points: 1. Diet Recommendations: Tailored dietary advice for the destination based on the user’s health responses and city-specific diet data. 2. General Precautions: Guidance for adapting to locational and seasonal changes, focusing on health and safety. 3. Weather Recommendations: Advice on how the user should prepare for weather conditions in the destination. Ensure the output is clear, actionable, and user-friendly.."
        )

        # Step 5: Send the text and prompt to Gemini for analysis
        model = genai.GenerativeModel('gemini-1.5-pro')
        response = model.generate_content([
            {'text': prompt},
            {'text': responses_content},
            {'text': current_city_diet_text},
            {'text': destination_city_diet_text}
        ])

        # Step 6: Get the analysis from the Gemini response
        analysis_result = response.text

        # Step 7: Return the analysis as JSON response
        return jsonify({'analysis': analysis_result})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500
    


@app.route('/summarize', methods=['POST'])
def summarize():
    try:
        # Parse JSON data from the request
        data = request.get_json()
        if not data:
            return jsonify({"error": "Invalid JSON data"}), 400

        # Create a summarization prompt
        prompt = (
            f"Summarize the following responses:\n"
            f"{json.dumps(data.get('responses', []), indent=2)}\n\n"
            f"Provide a concise summary of the user's responses, highlighting key points. Keep the summary under 200 words."
        )

        # Send the text and prompt to Gemini for summarization
        model = genai.GenerativeModel('gemini-1.5-pro')
        response = model.generate_content([{'text': prompt}])

        # Get the summary from the Gemini response
        summary_result = response.text

        # Return the summary as JSON response
        return jsonify({'summary': summary_result})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)