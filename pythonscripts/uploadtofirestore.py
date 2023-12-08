import firebase_admin
from firebase_admin import credentials, firestore, storage
import os
import pandas as pd
import ast

cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'fluttersociallogin-ff63d.appspot.com'
})
db = firestore.client()
bucket = storage.bucket()

directory = 'original'
# Load the Excel file
excel_file_path = 'Dialoguess-Level Creation.xlsx'
dialogues_data = pd.read_excel(excel_file_path)

# Convert the string representation of the list to an actual list
def convert_string_to_list(string):
    try:
        return ast.literal_eval(string)
    except ValueError as e:
        print(f"Error converting string to list: {e}")
        return []

# Apply the conversion to the 'options' column
dialogues_data['options'] = dialogues_data['options'].apply(convert_string_to_list)

# Get user input for the start row
start_row = int(input("Enter the starting row number for upload: "))

# Adjust the DataFrame index to start from the user-specified row
dialogues_data_adjusted = dialogues_data[start_row - 1:]

# Upload process starting from the specified row
for index, row in dialogues_data_adjusted.iterrows():
    level = int(row['level'])
    options = row['options']  # This is now a list
    rightOptionIndex = int(row['rightOptionIndex'])
    image_path = os.path.join(directory, f'{level}.png')
    
    # Upload image
    blob = bucket.blob(f'{level}.png')
    blob.upload_from_filename(image_path)
    blob.make_public()
    image_url = blob.public_url
    
    # Update Firestore
    doc_ref = db.collection('dialogues').document(f'level_{level}')
    doc_ref.set({
        'imageUrl': image_url,
        'level': level,
        'options': options,  # This needs to be a list
        'rightOptionIndex': rightOptionIndex
    })

    print("Completed row",index)
