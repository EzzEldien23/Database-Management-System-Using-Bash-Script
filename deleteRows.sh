#!/usr/bin/bash

BASE_DIR="./DataBases"
DBname="$1"
Tname="$2"

if [[ -z "$DBname" || -z "$Tname" ]]; then
    zenity --error --text="Usage: ./deleteRows_GUI.sh DBname TableName" --width=400 --height=80
    exit 1
fi

META_FILE="$BASE_DIR/$DBname/Meta/$Tname.meta"
DATA_FILE="$BASE_DIR/$DBname/Tables/$Tname"

if [[ ! -f "$META_FILE" ]]; then
    zenity --error --text="Meta file not found: $META_FILE" --width=400 --height=80
    exit 1
fi

if [[ ! -f "$DATA_FILE" ]]; then
    zenity --error --text="Data file not found: $DATA_FILE" --width=400 --height=80
    exit 1
fi

meta_line=$(cat "$META_FILE")
IFS='|' read -r -a columns <<< "$meta_line"

pk_index=-1
for idx in "${!columns[@]}"; do
    flag=$(echo "${columns[$idx]}" | cut -d':' -f3)
    if [[ "$flag" == "PK" ]]; then
        pk_index=$((idx+1)) 
        pk_name=$(echo "${columns[$idx]}" | cut -d':' -f1)
        break
    fi
done

if [[ $pk_index -eq -1 ]]; then
    zenity --error --text="No PK defined for table '$Tname'!" --width=350 --height=80
    exit 1
fi

zenity --text-info \
    --title="Table: $Tname" \
    --filename="$DATA_FILE" \
    --width=600 --height=400 \
    --editable \
    --ok-label="Continue"

while true; do
    pk_val=$(zenity --entry \
        --title="Delete Row from $Tname" \
        --text="Enter PK value ($pk_name) to delete:" \
        --width=400 --height=100)

    if [[ $? -ne 0 ]]; then
        zenity --info --text="Deletion canceled." --width=300 --height=80
        exit 0
    fi

    if [[ -z "$pk_val" ]]; then
        zenity --error --text="PK value cannot be empty!" --width=300 --height=80
        continue
    fi

    row=$(awk -F',' -v col="$pk_index" -v val="$pk_val" '$col==val {print; exit}' "$DATA_FILE")
    if [[ -z "$row" ]]; then
        zenity --error --text="PK value '$pk_val' not found. Try again." --width=350 --height=80
        continue
    fi

    zenity --question \
        --title="Confirm Deletion" \
        --text="Are you sure you want to delete this row?\n$row" \
        --width=400 --height=150

    if [[ $? -eq 0 ]]; then
        awk -F',' -v col="$pk_index" -v val="$pk_val" '$col != val' "$DATA_FILE" > temp_file
        mv temp_file "$DATA_FILE"
        zenity --info --text="Row deleted successfully!" --width=300 --height=80
        break
    else
        zenity --info --text="Deletion canceled." --width=300 --height=80
        break
    fi
done

zenity --text-info \
    --title="Updated Table: $Tname" \
    --filename="$DATA_FILE" \
    --width=600 --height=400 \
    --editable \
    --ok-label="Done"

exit 0

