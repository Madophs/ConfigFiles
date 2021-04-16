#!/bin/bash

STEAM_DIR=$HOME/.steam
BACKUP_DIR=$HOME/MEGAsync/steam_backup
FILE_REPORT=$BACKUP_DIR/files.txt

function getCksumsFromDir() {
    DIR=$1
    cksum $DIR/*.sl2 | sort -k 1
}

function getCksumsFromVar() {
    FILES=$1
    echo $FILES | xargs cksum | sort -k 1
}

if [[ -d $STEAM_DIR && -d $BACKUP_DIR ]]; then
    FILES=$(find $STEAM_DIR -name "*.sl2" -printf '"%p"\n' | tee $FILE_REPORT)
    echo $FILES | xargs cp -t $BACKUP_DIR

    if [[ $? == 0 ]]; then
        echo "Files have been successfully backed up"
    else
        echo "[ERROR] Something went wrong."
        exit 1
    fi

    printf "\nOriginal cksums\n"
    column -c 4 \
        <( paste  <( column -enxt <(getCksumsFromVar "${FILES}" | awk -F '[/ ]' '{print $1" "$2" "$(NF)" "}' ) )\
        <( getCksumsFromVar "${FILES}" | awk -F '[/]' '{print $(NF-2)}') )

    printf "\nBackup cksums\n"

    column -c 4 \
        <( paste  <( column -enxt <(getCksumsFromDir $BACKUP_DIR | awk -F '[/ ]' '{print $1" "$2" "$(NF)" "}' ) )\
        <( getCksumsFromVar "${FILES}" | awk -F '[/]' '{print $(NF-2)}') )
else
    echo "[ERROR] Steam or Backup directory not found..."
    exit 1
fi

