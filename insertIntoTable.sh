#!/usr/bin/bash

BASE_DIR="./DataBases"
DBname="$1"
Tname="$2"

if [[ -z "$DBname" || -z "$Tname" ]]; then
    zenity --error --text="Usage: ./insertIntoTable_GUI.sh DBname TableName" --width=400 --height=80
    exit 1
fi

DB_PATH="$BASE_DIR/$DBname"
TABLES_PATH="$DB_PATH/Tables"
META_PATH="$DB_PATH/Meta"

meta_file="$META_PATH/$Tname.meta"
data_file="$TABLES_PATH/$Tname"

if [[ ! -f "$meta_file" ]]; then
    zenity --error --text="Meta file not found for table '$Tname'" --width=400 --height=80
    exit 1
fi

if [[ ! -f "$data_file" ]]; then
    touch "$data_file"
fi

meta_line=$(cat "$meta_file")
IFS='|' read -r -a parts <<< "$meta_line"

columns_text=""
for idx in "${!parts[@]}"; do
    name=$(echo "${parts[$idx]}" | cut -d':' -f1)
    flag=$(echo "${parts[$idx]}" | cut -d':' -f3)
    if [[ "$flag" == "PK" ]]; then
        columns_text="$columns_text$((idx+1)). $name [PK]\n"
    else
        columns_text="$columns_text$((idx+1)). $name\n"
    fi
done

zenity --info \
    --title="Insert Row into $Tname" \
    --text="Table columns:\n$columns_text" \
    --width=400 --height=300

values_str=""
for idx in "${!parts[@]}"; do
    name=$(echo "${parts[$idx]}" | cut -d':' -f1)
    typ=$(echo "${parts[$idx]}" | cut -d':' -f2)
    flag=$(echo "${parts[$idx]}" | cut -d':' -f3)

    while true; do
        val=$(zenity --entry \
            --title="Enter Value" \
            --text="Enter value for column: $name\nType: $typ$( [[ "$flag" == "PK" ]] && echo " [PK]" )" \
            --width=400 --height=120)

        if [[ $? -ne 0 ]]; then
            zenity --info --text="Insertion canceled." --width=300 --height=80
            exit 0
        fi

        if [[ "$flag" == "PK" && -z "$val" ]]; then
            zenity --error --text="Primary Key cannot be empty!" --width=300 --height=80
            continue
        fi

        if [[ "$flag" == "PK" ]]; then
            col=$((idx+1))
            if cut -d',' -f"$col" "$data_file" | grep -x "$val" >/dev/null 2>&1; then
                zenity --error --text="This PK value already exists. Enter another." --width=300 --height=80
                continue
            fi
        fi

        if [[ "$typ" == "INT" && ! "$val" =~ ^-?[0-9]+$ ]]; then
            zenity --error --text="INT column must contain numeric values only." --width=300 --height=80
            continue
        fi

        if [[ "$typ" == "STR" ]]; then
     		if [[ "$val" == *","* ]]; then
        	zenity --error --text="Comma is not allowed in string values." --width=350 --height=100
        	continue
       fi
       if ! [[ "$val" =~ ^[[:alpha:]]+( [[:alpha:]]+)*$ ]]; then
        	zenity --error --text="String must contain letters only.\nSpaces are allowed between words only." --width=380 --height=120
        	continue
    fi
fi

        if [[ -z "$values_str" ]]; then
            values_str="$val"
        else
            values_str="$values_str,$val"
        fi
        break
    done
done

echo "$values_str" >> "$data_file"

zenity --info \
    --title="Insertion Successful" \
    --text="Row inserted successfully into table '$Tname'.\n\nValues:\n$values_str" \
    --width=400 --height=200

exit 0

