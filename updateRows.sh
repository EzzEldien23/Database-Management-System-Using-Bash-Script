#!/usr/bin/bash

BASE_DIR="./DataBases"
DBname="$1"
Tname="$2"

if [[ -z "$DBname" || -z "$Tname" ]]; then
    zenity --error --text="Usage: ./updateRow.sh DBname TableName" --width=400 --height=100
    exit 1
fi

DB_PATH="$BASE_DIR/$DBname"
TABLES_PATH="$DB_PATH/Tables"
META_PATH="$DB_PATH/Meta"
meta_file="$META_PATH/$Tname.meta"
data_file="$TABLES_PATH/$Tname"

if [[ ! -f "$meta_file" ]]; then
    zenity --error --text="Meta file not found: $meta_file" --width=400 --height=100
    exit 1
fi

if [[ ! -f "$data_file" ]]; then
    zenity --error --text="Data file not found: $data_file" --width=400 --height=100
    exit 1
fi

meta_line=$(cat "$meta_file")
IFS='|' read -r -a parts <<< "$meta_line"

pk_index=-1
col_names=()
for idx in "${!parts[@]}"; do
    col_name=$(echo "${parts[$idx]}" | cut -d':' -f1)
    col_flag=$(echo "${parts[$idx]}" | cut -d':' -f3)
    col_names+=("$col_name")
    if [[ "$col_flag" == "PK" ]]; then
        pk_index=$idx
        pk_name="$col_name"
    fi
done

if [[ $pk_index -eq -1 ]]; then
    zenity --error --text="No PK defined for this table!" --width=400 --height=100
    exit 1
fi

pk_val=$(zenity --entry --title="Update Row in $Tname" \
    --text="Enter PRIMARY KEY value ($pk_name) of the row to update:" --width=400 --height=120)

if [[ $? -ne 0 || -z "$pk_val" ]]; then
    exit 0
fi

row=$(awk -F',' -v c="$((pk_index+1))" -v v="$pk_val" '$c==v {print; exit}' "$data_file")
if [[ -z "$row" ]]; then
    zenity --error --text="No row found with PK=$pk_val" --width=350 --height=100
    exit 1
fi

IFS=',' read -r -a fields <<< "$row"

for idx in "${!parts[@]}"; do
    col_name=$(echo "${parts[$idx]}" | cut -d':' -f1)
    col_type=$(echo "${parts[$idx]}" | cut -d':' -f2)

    if [[ "$idx" -eq "$pk_index" ]]; then
        continue 
    fi

    new_val=$(zenity --entry --title="Update Column $col_name" \
        --text="Current value: ${fields[$idx]}\nEnter new value (leave empty to keep current):" \
        --width=400 --height=120)

    if [[ $? -ne 0 ]]; then
        new_val="${fields[$idx]}" 
    fi

    if [[ -z "$new_val" ]]; then
        new_val="${fields[$idx]}" 
    fi

    if [[ "$col_type" == "INT" ]]; then
        while ! [[ "$new_val" =~ ^-?[0-9]+$ ]]; do
            new_val=$(zenity --entry --title="Invalid INT" \
                --text="Column $col_name must be INT. Current: ${fields[$idx]}\nEnter new INT value:" \
                --width=400 --height=120)
            if [[ -z "$new_val" ]]; then
                new_val="${fields[$idx]}"
                break
            fi
        done
  else
    if [[ "$new_val" == *","* ]]; then
        zenity --error --text="Column $col_name: comma is not allowed." --width=350 --height=100
        new_val=$(zenity --entry --title="Invalid STR" \
            --text="Column $col_name cannot contain commas. Current: ${fields[$idx]}\nEnter new value:" \
            --width=400 --height=120)
        if [[ $? -ne 0 || -z "$new_val" ]]; then
            new_val="${fields[$idx]}"
        fi
    fi

    while ! [[ "$new_val" =~ ^[[:alpha:]]+( [[:alpha:]]+)*$ ]]; do
        zenity --error --text="Column $col_name must contain letters only.\nSpaces allowed between words only (no leading/trailing spaces)." --width=420 --height=120
        new_val=$(zenity --entry --title="Invalid STR" \
            --text="Column $col_name: Enter letters only. Current: ${fields[$idx]}\nEnter new value:" \
            --width=400 --height=120)
        if [[ $? -ne 0 || -z "$new_val" ]]; then
            new_val="${fields[$idx]}"
            break
        fi
    done
fi

    fields[$idx]="$new_val"
done

updated_row=$(IFS=,; echo "${fields[*]}")
awk -v pk="$pk_val" -F',' -v OFS=',' '$((PK=$pk_index+1)) != pk' "$data_file" > temp_file
awk -F',' -v pk_col="$((pk_index+1))" -v pk_val="$pk_val" '$pk_col != pk_val' "$data_file" > temp_file
echo "$updated_row" >> temp_file
mv temp_file "$data_file"

zenity --info --text="Row updated successfully!\nNew values:\n$(IFS=$'\n'; echo "${fields[*]}")" --width=500 --height=200
exit 0

