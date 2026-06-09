#!/usr/bin/bash

BASE_DIR="./DataBases"
mkdir -p "$BASE_DIR"

while true; do
    ACTION=$(zenity --list \
        --title="Database Manager" \
        --text="Select an action:" \
        --column="Option" \
        "Create DB" "List DB" "Remove DB" "Connect to DB" "Exit" \
        --height=400 --width=400 --ok-label="Select" --cancel-label="Quit")

    if [[ $? -ne 0 ]]; then
        zenity --info --text="Exiting Database Manager." --width=300 --height=100
        exit 0
    fi

    case "$ACTION" in
        "Create DB")
            bash ./createDB.sh
            zenity --info --text="Database creation finished." --width=350 --height=100
            ;;

        "List DB")
            DB_LIST=$(ls "$BASE_DIR")
            if [[ -z "$DB_LIST" ]]; then
                zenity --info --text="No databases found." --width=300 --height=100
            else
                zenity --list \
                    --title="Existing Databases" \
                    --column="Databases" $DB_LIST \
                    --height=300 --width=400
            fi
            ;;

        "Remove DB")
            bash ./removeDB.sh
            zenity --info --text="Database removal finished." --width=350 --height=100
            ;;

        "Connect to DB")
            bash ./connectDB.sh
            ;;

        "Exit")
            zenity --info --text="Exiting Database Manager." --width=300 --height=100
            exit 0
            ;;

        *)
            zenity --error --text="Invalid option selected!" --width=300 --height=100
            ;;
    esac
done

