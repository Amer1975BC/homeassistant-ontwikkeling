#!/bin/bash

# Token opslaan in beveiligd bestand (buiten Git backup)
cat > /config/.github_token << 'EOF'
GITHUB_TOKEN=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
EOF
chmod 600 /config/.github_token  # Alleen leesbaar voor eigenaar

# Configuratie
SOURCE_DIR="/config"  # De hoofdmap van je Home Assistant-configuratie
GITHUB_USER="Amer1975BC"
GITHUB_EMAIL=""  # Vul hier je e-mailadres in
COMMIT_MESSAGE="Automatische backup van Home Assistant configuratie"
REPO_DIR="/tmp/homeassistant-ontwikkeling"  # Tijdelijke directory voor de repository

# Laad token uit beveiligd bestand
source /config/.github_token
GITHUB_REPO="https://Amer1975BC:$GITHUB_TOKEN@github.com/Amer1975BC/homeassistant-ontwikkeling.git"

# Lijst met bestanden/mappen om uit te sluiten
EXCLUDE_PATTERNS=(
  ".storage"
  ".cloud"
  ".google.token"
  ".github_token"  # Exclude het token bestand zelf
  "image"
  "tts"
  "__pycache__"
  "*.log"
  "*.db"
  "*.db-shm"
  "*.db-wal"
  "*.log.*"
  "home-assistant.log"
  "home-assistant_v2.db"
  "deps"
  "www/community"
)

# Bouw de rsync exclude parameters
EXCLUDE_ARGS=""
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude=$pattern"
done

# Zorg ervoor dat git geïnstalleerd is
if ! command -v git &> /dev/null; then
    echo "Git is niet geïnstalleerd. Installeer het met: apt-get update && apt-get install -y git"
    exit 1
fi

# Zorg ervoor dat rsync geïnstalleerd is
if ! command -v rsync &> /dev/null; then
    echo "Rsync is niet geïnstalleerd. Installeer het met: apt-get update && apt-get install -y rsync"
    exit 1
fi

# Controleer of de bronmap bestaat
if [ ! -d "$SOURCE_DIR" ]; then
    echo "De bronmap '$SOURCE_DIR' bestaat niet."
    exit 1
fi

# Clone of update de repository
if [ ! -d "$REPO_DIR" ]; then
    echo "Repository wordt gekloond..."
    git clone "$GITHUB_REPO" "$REPO_DIR"
else
    echo "Repository wordt bijgewerkt..."
    cd "$REPO_DIR" || exit 1
    git pull
fi

# Configureer git gebruiker als deze nog niet is ingesteld
cd "$REPO_DIR" || exit 1
if [ -z "$(git config --get user.name)" ]; then
    git config user.name "$GITHUB_USER"
    if [ -n "$GITHUB_EMAIL" ]; then
        git config user.email "$GITHUB_EMAIL"
    fi
    echo "Git gebruiker geconfigureerd."
fi

# Controleer op welke branch we zitten
if ! git checkout main 2>/dev/null; then
    git checkout master 2>/dev/null
fi

# Verwijder alle oude bestanden in de repo, behalve .git
find "$REPO_DIR" -mindepth 1 -maxdepth 1 -not -path "$REPO_DIR/.git" -exec rm -rf {} \;

# Kopieer alle bestanden van de Home Assistant configuratie, met uitsluiting van de gespecificeerde bestanden
echo "Kopieren van configuratiebestanden..."
eval "rsync -av --delete $EXCLUDE_ARGS $SOURCE_DIR/ $REPO_DIR/"

# Voeg alle wijzigingen toe aan git
cd "$REPO_DIR" || exit 1
git add -A

# Check of er wijzigingen zijn
if [ -n "$(git status --porcelain)" ]; then
    # Commit de wijzigingen
    git commit -m "$COMMIT_MESSAGE"
    
    # Push de wijzigingen naar de remote repository
    git push
    
    echo "Gesynchroniseerd met GitHub: Home Assistant configuratie is bijgewerkt."
else
    echo "Geen wijzigingen gevonden om te synchroniseren."
fi

# Send notification to Home Assistant
curl -X POST -H "Content-Type: application/json" \
  -d '{"message": "Home Assistant configuratie backup naar GitHub voltooid"}' \
  http://localhost:8123/api/services/persistent_notification/create
