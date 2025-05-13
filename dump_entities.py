import requests
import json
import os
import re

# Functie om een token te vinden
def get_token():
    # Zoek een token in de auth bestanden
    auth_dir = '/config/.storage/'
    if os.path.exists(auth_dir):
        for filename in os.listdir(auth_dir):
            if 'auth' in filename:
                try:
                    with open(os.path.join(auth_dir, filename), 'r') as f:
                        content = f.read()
                        match = re.search(r'"access_token":"([^"]+)"', content)
                        if match:
                            return match.group(1)
                except:
                    pass
    return None

# Haal een token op
token = get_token()

if not token:
    print("Geen token gevonden. Vul handmatig een Long-Lived Access Token in.")
    print("Je kunt een token aanmaken in je gebruikersprofiel in Home Assistant.")
    token = input("Token: ").strip()

# Probeer verbinding te maken met verschillende URLs
urls = [
    "http://supervisor/core/api/states",
    "http://localhost:8123/api/states",
    "http://127.0.0.1:8123/api/states",
    "http://homeassistant:8123/api/states"
]

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

success = False

for url in urls:
    try:
        print(f"Proberen verbinding te maken met {url}...")
        response = requests.get(url, headers=headers, timeout=10)
        
        if response.status_code == 200:
            entities = response.json()
            
            # Opslaan naar bestand
            with open('/config/entities_dump.json', 'w') as f:
                json.dump(entities, f, indent=2)
            
            print(f"Succesvol {len(entities)} entiteiten opgeslagen in /config/entities_dump.json")
            
            # Maak ook een tekstversie met alleen entity_id's
            with open('/config/entity_ids.txt', 'w') as f:
                for entity in entities:
                    f.write(f"{entity['entity_id']}\n")
            
            print(f"Entity IDs opgeslagen in /config/entity_ids.txt")
            
            success = True
            break
        else:
            print(f"Fout bij {url}: {response.status_code} {response.text}")
    
    except Exception as e:
        print(f"Fout bij verbinden met {url}: {e}")

if not success:
    print("Kon geen verbinding maken met Home Assistant API.")
    print("Controleer of je het juiste token gebruikt en of de API toegankelijk is.")
