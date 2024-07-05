#!/bin/bash

# # Activate the virtual environment
source venv/bin/activate

# Create the apps database
python database.py

# Run the Python application
python app.py

