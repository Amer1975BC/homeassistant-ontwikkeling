#!/bin/bash

# Logging
LOG_FILE="/config/git-backup.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Start Git backup" >> $LOG_FILE

# Naar config directory gaan
cd /config || {
    echo "FOUT: Kan niet navigeren naar /config directory" >> $LOG_FILE
    exit 1
}

# Ignoreer submodule wijzigingen
git config submodule.recurse false

# Voeg alle bestanden toe behalve submodules
git add -A :/

# Check of er wijzigingen zijn
if git diff --staged --quiet; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Geen wijzigingen gevonden om te backuppen" >> $LOG_FILE
else
    # Commit wijzigingen
    git commit -m "Automatische backup $(date '+%Y-%m-%d %H:%M:%S')" && {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Wijzigingen succesvol gecommit" >> $LOG_FILE
        
        # Push naar repository
        if git push; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup succesvol gepusht naar repository" >> $LOG_FILE
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') - WAARSCHUWING: Push mislukt, maar commit is lokaal opgeslagen" >> $LOG_FILE
        fi
    } || {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - WAARSCHUWING: Commit is mislukt" >> $LOG_FILE
    }
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Git backup voltooid" >> $LOG_FILE
