#!/bin/bash

# Haal een toegangstoken op
TOKEN=$(cat /config/.storage/auth* | grep -o '"access_token":"[^"]*' | head -1 | sed 's/"access_token":"//')

# Maak een API call en sla de resultaten op
curl -s -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     http://supervisor/core/api/states > /config/entities_dump.json

echo "Entiteiten dump opgeslagen in /config/entities_dump.json"
