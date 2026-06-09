#!/usr/bin/bash

BASE_DIR="./DataBases"
DBname="$1"

if [[ -z "$DBname" ]]; then
    zenity --error --text="No database selected!" --width=400 --height=100
    exit 1
fi

DB_PATH="$BASE_DIR/$DBname"
TABLES_PATH="$DB_PATH/Tables"
META_PATH="$DB_PATH/Meta"

if [[ ! -d "$DB_PATH" ]]; then
    zenity --error --text="Database '$DBname' does not exist!" --width=400 --height=100
    exit 1
fi

TABLES=($(ls "$TABLES_PATH"))
if [[ ${#TABLES[@]} -eq 0 ]]; then
    zenity --info --text="No tables found in database '$DBname'." --width=400 --height=100
    exit 0
fi

Tname=$(zenity --list \
    --title="Select Table to Use" \
    --text="Available tables in '$DBname':" \
    --column="Tables" "${TABLES[@]}" \
    --width=400 --height=300)

if [[ $? -ne 0 || -z "$Tname" ]]; then
    zenity --info --text="No table selected. Exiting..." --width=350 --height=80
    exit 0
fi

while true; do
    choice=$(zenity --list \
        --title="Using Table: $Tname" \
        --text="Choose an action:" \
        --column="Option" \
        "Insert Into Table" \
        "Select From Table" \
        "Delete Rows" \
        "Update Rows" \
        "Show Table Structure" \
        "Back" \
        --width=400 --height=350)

    if [[ $? -ne 0 || -z "$choice" ]]; then
        zenity --info --text="Exiting table operations..." --width=350 --height=80
        exit 0
    fi

    case "$choice" in
        "Insert Into Table")
            ./insertIntoTable.sh "$DBname" "$Tname"
            zenity --info --text="Finished inserting into table '$Tname'." --width=350 --height=80
            ;;
        "Select From Table")
            ./selectFromTable.sh "$DBname" "$Tname"
            ;;
        "Delete Rows")
            ./deleteRows.sh "$DBname" "$Tname"
            ;;
        "Update Rows")
            ./updateRows.sh "$DBname" "$Tname"
            ;;
        "Show Table Structure")
            if [[ -f "$META_PATH/$Tname.meta" ]]; then
                META=$(cat "$META_PATH/$Tname.meta")
                zenity --info --text="Table Structure for '$Tname':\n$META" --width=500 --height=300
            else
                zenity --error --text="Meta file not found!" --width=350 --height=80
            fi
            ;;
        "Back")
            zenity --info --text="Exiting table '$Tname'..." --width=350 --height=80
            exit 0
            ;;
        *)
            zenity --error --text="Invalid choice!" --width=300 --height=80
            ;;
    esac
done

