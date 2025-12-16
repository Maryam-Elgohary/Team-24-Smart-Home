import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import joblib
import os

# Load data
df = pd.read_csv('smart_home_data.csv')

# Feature encoding
day_mapping = {'Monday': 0, 'Tuesday': 1, 'Wednesday': 2, 'Thursday': 3, 
               'Friday': 4, 'Saturday': 5, 'Sunday': 6}
time_mapping = {'morning': 0, 'afternoon': 1, 'evening': 2, 'night': 3}
condition_mapping = {'sleeping': 0, 'at_work': 1, 'at_home': 2, 
                     'out': 3, 'getting_ready': 4, 'awake': 5}
mood_mapping = {'peaceful': 0, 'focused': 1, 'tired': 2, 'stressed': 3, 
                'happy': 4, 'calm': 5, 'energetic': 6}

df['mood'] = df['mood'].map(mood_mapping)
df['person_condition'] = df['person_condition'].map(condition_mapping)
df['time_of_day'] = df['time_of_day'].map(time_mapping)

# Use 'test_switch' as output
df['test_switch'] = df['tv_status'] 
input_features = ['mood', 'person_condition', 'time_of_day', 'at_home', 'is_holiday']

# Input features and target
X = df[input_features]
y = df['test_switch']

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train model
switch_model = RandomForestClassifier(n_estimators=100, random_state=42)
switch_model.fit(X_train, y_train)

# Evaluate
y_pred = switch_model.predict(X_test)
print("Test Switch Prediction Accuracy:", accuracy_score(y_test, y_pred))

# Save model
if not os.path.exists('models'):
    os.makedirs('models')
joblib.dump(switch_model, 'test_switch_model.pkl')
sample_input = pd.DataFrame([{
    'mood': mood_mapping['happy'],
    'person_condition': condition_mapping['awake'],
    'time_of_day': time_mapping['evening'],
    'at_home': 1,
    'is_holiday': 0
}])

prediction = switch_model.predict(sample_input)[0]
print("Test Switch Status:", "ON" if prediction == 1 else "OFF")
joblib.dump(switch_model, 'test_switch_model.pkl')