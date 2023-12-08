import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import ast

# Initialize Firebase
cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Load the Excel file
excel_file_path = 'Dialoguess-Level Creation.xlsx'
dialogues_data = pd.read_excel(excel_file_path)

# Function to safely convert a string representation of a list to a list
def convert_string_to_list(string):
    try:
        return ast.literal_eval(string)
    except ValueError as e:
        print(f"Error converting string to list: {e}")
        return []

# Add new columns for each validation
dialogues_data['Level_Validation'] = False
dialogues_data['RightOptionIndex_Validation'] = False
dialogues_data['Options_Validation'] = False

# Function to fetch data from Firestore
def fetch_data_from_firestore(level):
    doc_ref = db.collection('dialogues').document(f'level_{level}')
    doc = doc_ref.get()
    if doc.exists:
        return doc.to_dict()
    else:
        return None

# Get user input for the start row
start_row = int(input("Enter the starting row number for validation: "))
if start_row < 1 or start_row > len(dialogues_data):
    print("Invalid row number. Starting from row 1.")
    start_row = 1

# Validate data starting from the specified row
for index, row in dialogues_data.iterrows():
    if index < start_row - 1:
        continue

    level = int(row['level'])
    firestore_data = fetch_data_from_firestore(level)
    
    if firestore_data:
        # Validate level
        dialogues_data.at[index, 'Level_Validation'] = (firestore_data.get('level') == level)
        
        # Validate rightOptionIndex
        dialogues_data.at[index, 'RightOptionIndex_Validation'] = (firestore_data.get('rightOptionIndex') == int(row['rightOptionIndex']))
        
        # Validate options
        firestore_options = firestore_data.get('options', [])
        excel_options = convert_string_to_list(row['options'])
        dialogues_data.at[index, 'Options_Validation'] = (firestore_options == excel_options)

# Explicitly set the data type of validation columns to boolean
dialogues_data['Level_Validation'] = dialogues_data['Level_Validation'].astype(bool)
dialogues_data['RightOptionIndex_Validation'] = dialogues_data['RightOptionIndex_Validation'].astype(bool)
dialogues_data['Options_Validation'] = dialogues_data['Options_Validation'].astype(bool)

# Slice the DataFrame from the user-specified start row to the end
validated_dialogues_data = dialogues_data[start_row - 1:]

# Save the sliced DataFrame to a new Excel file
validated_dialogues_data.to_excel('Dialoguess-Level Creation Validated.xlsx', index=False)

print(f"Validation process completed and saved to 'Dialoguess-Level Creation Validated.xlsx' starting from row {start_row}")
