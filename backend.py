# backend.py
#uvicorn backend:app --reload --host 0.0.0.0 --port 8000
from fastapi import FastAPI
from pydantic import BaseModel
import pandas as pd
import joblib
import os

# Load the trained model
MODEL_PATH = "test_switch_model.pkl"
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model file not found at {MODEL_PATH}")

switch_model = joblib.load(MODEL_PATH)

# Mappings
mood_mapping = {'peaceful': 0, 'focused': 1, 'tired': 2, 'stressed': 3, 
                'happy': 4, 'calm': 5, 'energetic': 6}
condition_mapping = {'sleeping': 0, 'at_work': 1, 'at_home': 2, 
                     'out': 3, 'getting_ready': 4, 'awake': 5}
time_mapping = {'morning': 0, 'afternoon': 1, 'evening': 2, 'night': 3}

# FastAPI app
app = FastAPI(title="Test Switch Home Automation API")

# Input model
class SwitchInput(BaseModel):
    mood: str
    person_condition: str
    time_of_day: str
    at_home: int
    is_holiday: int

def handle_unknown(input_value, mapping, default_value):
    """Handle unknown values safely"""
    return mapping.get(input_value, mapping[default_value])
@app.post("/predict_switch")
def predict_switch(data: SwitchInput):
    try:
        mood = data.mood.lower()
        at_home = data.at_home

        if at_home == 1 and mood in ["happy", "energetic", "focused"] :
            test_switch_status = "ON"
        if at_home == 0 and mood in ["tired", "stressed", "peaceful"] :
            test_switch_status = "OFF"

        return {"test_switch": test_switch_status}

    except Exception as e:
        return {"error": str(e)}

# Root endpoint
@app.get("/")
def root():
    return {"message": "Test Switch Home Automation API is running!"}
