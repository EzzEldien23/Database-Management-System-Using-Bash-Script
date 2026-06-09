#!/usr/bin/bash

BASE_DIR="./DataBases"
mkdir -p "$BASE_DIR"

while true; do
    DBname=$(zenity --entry --title="Remove Database" \
        --text="Enter database name to remove (or leave blank to cancel):" \
        --entry-text="" \
        --width=400)

    rc=$?
    if [[ $rc -ne 0 ]]; then
        zenity --question --title="Cancel" --text="Do you want to exit without deleting any database?" \
            --ok-label="Yes, exit" --cancel-label="No, go back"
        if [[ $? -eq 0 ]]; then
            exit 0
        else
            continue
        fi
    fi


    DBname="$(printf "%s" "$DBname" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"


    if [[ -z "$DBname" ]]; then
        zenity --question --title="Empty name" --text="Database name is empty. Do you want to cancel?" \
            --ok-label="Yes, cancel" --cancel-label="No, re-enter"
        if [[ $? -eq 0 ]]; then
            exit 0
        else
            continue
        fi
    fi


    if ! [[ "$DBname" =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
	zenity --error --title="Error" --text="Invalid name please use letters, numbers, and underscore only, and start with a letter." --width=450
        continue
    fi


    if [[ ! -d "$BASE_DIR/$DBname" ]]; then
	zenity --error --title="Error" --text="Database '$DBname' does NOT exist in:\n$BASE_DIR" --width=450
        zenity --question --title="Not found" --text="Do you want to try another name?" \
            --ok-label="Yes" --cancel-label="No, exit"
        if [[ $? -ne 0 ]]; then
            exit 0
        else
            continue
        fi
    fi

    break
done

zenity --question \
    --title="Confirm Deletion" \
    --text="Are you sure you want to permanently delete the database:\n\n$DBname\n\nThis will remove the folder and all its contents." \
    --ok-label="Yes, delete" --cancel-label="No, cancel" \
    --width=450

confirm_rc=$?
if [[ $confirm_rc -ne 0 ]]; then
zenity --info --title="Cancelled" --text="Deletion cancelled." --width=400
    exit 0
fi

if rm -r -- "$BASE_DIR/$DBname"; then
zenity --info --title="Deleted" --text="Database '$DBname' has been deleted." --width=400
    exit 0
else
zenity --error --title="Error" \
       --text="Failed to delete database '$DBname'.\nCheck permissions and try again." \
       --width=450
    exit 1
fi

