#!/bin/bash

STEAM_DIR=$HOME/.steam
BACKUP_DIR=$HOME/MEGAsync/steam_backup
FILE_REPORT=$BACKUP_DIR/files.txt

if [[ -d $STEAM_DIR && -d $BACKUP_DIR ]]; then
    FILES=$(find $STEAM_DIR -name "*.sl2" -printf '"%p"\n' | tee $FILE_REPORT)
    echo $FILES | xargs cp -t $BACKUP_DIR
    echo "Files have been successfully backed up"
    echo "Original cksums"
    echo $FILES | xargs cksum | sort -k 1 | awk -F '[/ ]' '{print $1" "$2" "$(NF)}'
    echo ""
    echo "Destination cksums"
    cksum $BACKUP_DIR/*.sl2 | sort -k 1 | awk -F '[/ ]' '{print $1" "$2" "$(NF)}'
else
    echo "[ERROR] Steam or Backup directory not found..."
    exit 1
fi
