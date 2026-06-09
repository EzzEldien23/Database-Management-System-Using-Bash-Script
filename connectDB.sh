#!/usr/bin/bash

BASE_DIR="./DataBases"
mkdir -p "$BASE_DIR"

DB_LIST=($(ls "$BASE_DIR" 2>/dev/null))

if [[ ${#DB_LIST[@]} -eq 0 ]]; then
    zenity --info --text="No databases found. Create a database first." --width=350 --height=100
    exit 0
fi

DBname=$(zenity --list \
    --title="Connect to Database" \
    --text="Select a database to connect:" \
    --column="Databases" "${DB_LIST[@]}" \
    --width=400 --height=300 \
    --cancel-label="Exit")

if [[ $? -ne 0 || -z "$DBname" ]]; then
    zenity --info --text="Exiting..." --width=300 --height=80
    exit 0
fi

zenity --info --text="Connected to database '$DBname'." --width=350 --height=80

while true; do
    ACTION=$(zenity --list \
        --title="Database Manager: $DBname" \
        --text="Select an action for database '$DBname':" \
        --column="Options" \
        "List Tables" "Create Table" "Delete Table" "Use Table" "Back" \
        --width=500 --height=350 \
        --cancel-label="Exit")

    if [[ $? -ne 0 || -z "$ACTION" ]]; then
        zenity --info --text="Disconnecting from '$DBname'..." --width=350 --height=80
        exit 0
    fi

    case "$ACTION" in

        "List Tables")
         bash ListTable.sh $DBname
         ;;
  
        "Create Table")
            bash createTable.sh "$DBname"
            zenity --info --text="Finished creating table." --width=350 --height=80
            ;;
            
        "Delete Table")
            bash deleteTable.sh "$DBname"
            zenity --info --text="Finished deleting table." --width=350 --height=80
            ;;

        "Use Table")
            bash useTable.sh "$DBname"
            ;;

        "Back")
            zenity --info --text="Disconnected from '$DBname'." --width=350 --height=80
            exit 0
            ;;

        *)
            zenity --error --text="Invalid option!" --width=300 --height=80
            ;;
    esac
done

