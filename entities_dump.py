import json
import requests
import os

# Configuratie
HA_URL = "http://supervisor/core/api/states"
TOKEN = os.environ.get("SUPERVISOR_TOKEN")
OUTPUT_FILE = "/config/entities_dump.json"

# API aanroepen
headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

response = requests.get(HA_URL, headers=headers)
entities = response.json()

# Opslaan naar bestand
with open(OUTPUT_FILE, "w") as f:
    json.dump(entities, f, indent=2)

print(f"Entiteiten opgeslagen naar {OUTPUT_FILE}")