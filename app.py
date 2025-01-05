from flask import Flask, request, jsonify
import pandas as pd
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Directory to save uploaded files temporarily
UPLOAD_FOLDER = './uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/process-travel-health', methods=['POST'])
def process_travel_health():
    try:
        # Check if files are part of the request
        if 'responses' not in request.files or 'current_city' not in request.files or 'destination_city' not in request.files:
            return jsonify({"error": "Missing files in the request"}), 400

        # Save the uploaded JSON file
        responses_file = request.files['responses']
        responses_path = os.path.join(UPLOAD_FOLDER, 'responses.json')
        responses_file.save(responses_path)

        # Save the current city dietary file
        current_city_file = request.files['current_city']
        current_city_path = os.path.join(UPLOAD_FOLDER, 'current_city.xlsx')
        current_city_file.save(current_city_path)

        # Save the destination city dietary file
        destination_city_file = request.files['destination_city']
        destination_city_path = os.path.join(UPLOAD_FOLDER, 'destination_city.xlsx')
        destination_city_file.save(destination_city_path)

        # Load and process the JSON file
        with open(responses_path, 'r') as file:
            user_responses = file.read()

        # Load the Excel files
        current_city_diet = pd.read_excel(current_city_path)
        destination_city_diet = pd.read_excel(destination_city_path)

        # Analyze the data (example: find diet conflicts and precautions)
        analysis = analyze_diet_and_responses(
            user_responses=user_responses,
            current_city_diet=current_city_diet,
            destination_city_diet=destination_city_diet,
        )

        # Return the analysis as a JSON response
        return jsonify({
            "status": "success",
            "analysis": analysis
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500


def analyze_diet_and_responses(user_responses, current_city_diet, destination_city_diet):
    """
    Analyze user responses and dietary preferences from the two Excel files.

    Args:
        user_responses (str): User responses in JSON format.
        current_city_diet (DataFrame): Dietary preferences of the current city.
        destination_city_diet (DataFrame): Dietary preferences of the destination city.

    Returns:
        dict: Analysis result with precautions and recommendations.
    """
    # Example analysis (expand based on your requirements):
    precautions = []
    recommendations = []

    # Example: Check if any foods from current city conflict with destination city
    current_foods = set(current_city_diet['Food'].dropna())
    destination_foods = set(destination_city_diet['Food'].dropna())
    conflicting_foods = current_foods.intersection(destination_foods)

    if conflicting_foods:
        precautions.append(
            f"Be cautious with the following foods that might differ in preparation or availability: {', '.join(conflicting_foods)}"
        )

    # Example: Provide recommendations based on user responses
    if 'diabetes' in user_responses:
        recommendations.append("Monitor blood sugar levels during your travel.")
    return {
        "precautions": precautions,
        "recommendations": recommendations
    }


if __name__ == '__main__':
    app.run(debug=True)
