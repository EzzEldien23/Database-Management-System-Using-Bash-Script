#!/usr/bin/bash

BASE_DIR="./DataBases"
DBname="$1"
db_path="$BASE_DIR/$DBname"

tables=$(ls "$db_path/Meta" | grep ".meta$" | sed 's/.meta$//')

if [ -z "$tables" ]; then
    zenity --info --text="No tables found in the database path: $db_path" --width=300  
    exit 0
else
    zenity --list --title="Available Tables" \
        --text="Tables in the database named: $db_name" \
        --column="Tables" $tables \
        --width=400 --height=300
    status=$?
    if [ "$status" -ne 0 ]; then

        exit 0
    fi
    fi

