#!/bin/bash

# Logging
LOG_FILE="/config/git-backup.log"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
echo "$TIMESTAMP - 🔄 Start Git backup" >> "$LOG_FILE"

# Naar config directory gaan
cd /config || {
    echo "$TIMESTAMP - ❌ FOUT: Kan niet navigeren naar /config directory" >> "$LOG_FILE"
    exit 1
}

# Instellingen: submodules negeren
git config submodule.recurse false

# Voeg wijzigingen toe (alle bestanden behalve submodules)
git add -A :/

# Check of er wijzigingen zijn
if git diff --staged --quiet; then
    echo "$TIMESTAMP - ℹ️ Geen wijzigingen gevonden om te backuppen" >> "$LOG_FILE"
else
    COMMIT_MSG="Automatische backup $TIMESTAMP"
    if git commit -m "$COMMIT_MSG"; then
        echo "$TIMESTAMP - ✅ Wijzigingen succesvol gecommit" >> "$LOG_FILE"

        # Push naar repository
        if git push >> "$LOG_FILE" 2>&1; then
            echo "$TIMESTAMP - ✅ Backup succesvol gepusht naar repository" >> "$LOG_FILE"
        else
            echo "$TIMESTAMP - ⚠️ WAARSCHUWING: Push mislukt, commit is lokaal opgeslagen" >> "$LOG_FILE"
        fi
    else
        echo "$TIMESTAMP - ⚠️ WAARSCHUWING: Commit is mislukt" >> "$LOG_FILE"
    fi
fi

echo "$TIMESTAMP - ✅ Git backup voltooid" >> "$LOG_FILE"
