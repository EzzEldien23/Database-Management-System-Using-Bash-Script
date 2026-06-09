#!/usr/bin/bash

BASE_DIR="./DataBases"
DBname="$1"

if [[ -z "$DBname" ]]; then
    zenity --error --text="No database selected!" --width=300 --height=80
    exit 1
fi

DB_PATH="$BASE_DIR/$DBname"
TABLES_PATH="$DB_PATH/Tables"
META_PATH="$DB_PATH/Meta"

if [[ ! -d "$DB_PATH" ]]; then
    zenity --error --text="Database '$DBname' does NOT exist." --width=350 --height=80
    exit 1
fi

mkdir -p "$TABLES_PATH" "$META_PATH"

tables=$(ls "$TABLES_PATH")
if [[ -z "$tables" ]]; then
    zenity --info --text="No tables found in database '$DBname'." --width=350 --height=80
    exit 0
fi

Tname=$(zenity --list \
    --title="Delete Table from $DBname" \
    --text="Select a table to delete:" \
    --column="Tables" $tables \
    --width=400 --height=300)

if [[ $? -ne 0 ]]; then
    zenity --info --text="Table deletion canceled." --width=300 --height=80
    exit 0
fi

zenity --question \
    --title="Confirm Deletion" \
    --text="Are you sure you want to delete table '$Tname'?\nThis will remove both data and metadata." \
    --width=400 --height=150

if [[ $? -eq 0 ]]; then
    rm -f "$TABLES_PATH/$Tname"
    rm -f "$META_PATH/$Tname.meta"
    zenity --info --text="Table '$Tname' has been deleted successfully!" --width=350 --height=80
else
    zenity --info --text="Deletion canceled." --width=300 --height=80
fi

exit 0

