from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
import os
import pandas as pd
import json
import requests
import uuid

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Initialize the Gemini API with your API key
api_key = "AIzaSyDf95m97fUjvn4CuaC4KD8KHicDF28l4y4"
genai.configure(api_key=api_key)

# Azure Translator API configuration
TRANSLATOR_KEY = "CqxUuD3Q49pvij9qtQdRjBmSecrSKVfVMlfVecIThYWr8iBEy5KGJQQJ99BAACGhslBXJ3w3AAAbACOGnNg4"
TRANSLATOR_ENDPOINT = "https://api.cognitive.microsofttranslator.com"
TRANSLATOR_REGION = "centralindia"


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
    


@app.route('/travel-health-score', methods=['POST'])
def travel_health_score():
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
        f"Based on the following travel scenario, calculate a Travel Health Score on a scale of 0.00 to 10.00:\n"
        f"- Current city: {current_city}\n"
        f"- Destination city: {destination_city}\n\n"
        f"Attached are:\n"
        f"1. User responses (plain text).\n"
        f"2. Diet information for {current_city} (CSV format).\n"
        f"3. Diet information for {destination_city} (CSV format).\n\n"
        f"Consider the following factors in your calculation:\n"
        f"- The user's health conditions, including chronic issues and sensitivities.\n"
        f"- The dietary compatibility between the user and the destination city's typical diet compared to the current city.\n"
        f"- The user's adaptability to the destination city's weather conditions.\n"
        f"- Any potential risks or benefits associated with the travel scenario.\n\n"
        f"Please provide a single numerical output as a decimal value between 0.00 and 10.00. For example: 8.29 or 5.63.\n"
        f"Do not include any explanation or extra text, only return the value. Nothing else should be included in the response."
    )

        # Step 5: Send the text and prompt to Gemini for analysis
        model = genai.GenerativeModel('gemini-1.5-pro')
        response = model.generate_content([
            {'text': prompt},
            {'text': responses_content},
            {'text': current_city_diet_text},
            {'text': destination_city_diet_text}
        ])
        travel_health_score = response.text.strip()
        print(travel_health_score)
        return jsonify({'travelHealthScore': travel_health_score})
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500



@app.route('/summarize', methods=['POST'])
def summarize():
    try:
        # Parse JSON data from the request
        data = request.get_json()
        user_id = data.get('user_id')
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
        return jsonify({'summary': summary_result})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500



@app.route('/generalized-health-score', methods=['POST'])
def health_score():
    try:
        # Parse JSON data from the request
        data = request.get_json()
        user_id = data.get('user_id')
        if not data:
            return jsonify({"error": "Invalid JSON data"}), 400

        # Create a prompt to generate the health score
        prompt = (
        f"Based on the following user responses, generate a health score on a scale of 0.00 to 10.00:\n"
        f"{json.dumps(data.get('responses', []), indent=2)}\n\n"
        f"Use the following guidelines for generating the health score:\n"
        f"1. **Health Factors**: Consider conditions such as chronic diseases (e.g., diabetes, heart disease), past surgeries, and mental health. These conditions will impact the score based on their severity.\n"
        f"2. **Positive Responses**: Conditions like 'No' answers or lack of symptoms should increase the score.\n"
        f"3. **Negative Responses**: Conditions like 'Yes' answers to serious health issues (e.g., stroke, cancer) should decrease the score, but avoid extreme deductions.\n"
        f"4. **Score Range**: The score should range between 0.00 (worst) and 10.00 (best), with intermediate values depending on the severity and combination of conditions.\n"
        f"5. **Avoid extreme deductions**: Try to keep the score above 0.00 and reflect the overall health status. For example, if multiple severe conditions are reported, the score should reflect that but not go below 3.00 unless the conditions are extreme.\n"
        f"6. **Precision**: Keep the score precise to two decimal places.\n\n"
        f"Return only the score as a decimal number between 0.00 and 10.00. Example: 7.58 or 6.25 or 8.09"
        f"Try not to keep the second decimal place as 0"
    )

        # Send the text and prompt to Gemini for analysis
        model = genai.GenerativeModel('gemini-1.5-pro')
        response = model.generate_content([{'text': prompt}])

        # Get the health score from the Gemini response
        health_score = response.text.strip()
        return jsonify({'healthScore': health_score})
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({'error': str(e)}), 500
    

@app.route('/translate', methods=['POST'])
def translate_text():
    try:
        # Parse request data
        data = request.get_json()
        if not data:
            return jsonify({"error": "Invalid JSON data"}), 400

        # Extract required parameters from the request
        text_to_translate = data.get('text')
        from_language = data.get('from', 'en')  # Default to English if not specified
        to_language = data.get('to', ['en'])  # Expecting a list of target languages

        if not text_to_translate or not to_language:
            return jsonify({"error": "Missing 'text' or 'to' in the request"}), 400

        # Convert `to_language` to a single item list if it's not already a list
        if isinstance(to_language, str):
            to_language = [to_language]

        # Construct the request to Azure Translator API
        path = '/translate'
        constructed_url = TRANSLATOR_ENDPOINT + path

        params = {
            'api-version': '3.0',
            'from': from_language,
            'to': to_language
        }

        headers = {
            'Ocp-Apim-Subscription-Key': TRANSLATOR_KEY,
            'Ocp-Apim-Subscription-Region': TRANSLATOR_REGION,
            'Content-type': 'application/json',
            'X-ClientTraceId': str(uuid.uuid4())
        }

        body = [{'text': text_to_translate}]

        # Send the request to Azure Translator API
        response = requests.post(constructed_url, params=params, headers=headers, json=body)

        # Handle the response
        if response.status_code != 200:
            return jsonify({"error": "Translation API error", "details": response.text}), response.status_code

        translation_result = response.json()

        # Format the response for the client
        translations = [
            {"language": t["to"], "translatedText": t["text"]}
            for t in translation_result[0]["translations"]
        ]

        return jsonify({"translations": translations})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)