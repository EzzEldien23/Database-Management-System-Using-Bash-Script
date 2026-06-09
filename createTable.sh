#!/usr/bin/bash

BASE_DIR="./DataBases"
DBname="$1"

if [[ -z "$DBname" ]]; then
    zenity --error --text="No database selected!" --width=350 --height=100
    exit 1
fi

DB_PATH="$BASE_DIR/$DBname"
TABLES_DIR="$DB_PATH/Tables"
META_DIR="$DB_PATH/Meta"

mkdir -p "$TABLES_DIR" "$META_DIR"

while true; do
    tableName=$(zenity --entry \
        --title="Create Table in $DBname" \
        --text="Enter table name (or type 'back' to cancel):" \
        --width=600 --height=120)

    if [[ $? -ne 0 || "$tableName" == "back" ]]; then
        zenity --info --text="Table creation canceled." --width=350 --height=100
        exit 0
    fi

    if [[ -z "$tableName" ]]; then
        zenity --error --text="Table name cannot be empty!" --width=350 --height=100
        continue
    fi

    if [[ ! "$tableName" =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
        zenity --error --text="Invalid name! Must start with a letter and contain letters, digits, or _" \
            --width=500 --height=120
        continue
    fi

    if [[ -e "$TABLES_DIR/$tableName" ]]; then
        zenity --error --text="Table '$tableName' already exists!" --width=400 --height=100
        continue
    fi

    touch "$TABLES_DIR/$tableName"
    touch "$META_DIR/$tableName.meta"
    break
done

zenity --info --text="Table '$tableName' created.\nNow add columns." --width=400 --height=120

meta_line=""
pk_set="false"

while true; do
    colName=$(zenity --entry \
        --title="Add Column to $tableName" \
        --text="Enter column name (or 'done' to finish):" \
        --width=600 --height=120)

    if [[ $? -ne 0 ]]; then
        zenity --info --text="Column entry canceled. Finishing..." --width=350 --height=100
        break
    fi

    if [[ "$colName" == "done" ]]; then
        if [[ -z "$meta_line" ]]; then
            zenity --error --text="You must add at least one column!" --width=350 --height=100
            continue
        fi
        break
    fi

    if [[ -z "$colName" ]]; then
        zenity --error --text="Column name cannot be empty!" --width=350 --height=100
        continue
    fi

    if [[ ! "$colName" =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
        zenity --error --text="Invalid column name! Use letters, numbers, and underscore only." \
            --width=500 --height=120
        continue
    fi

    dtype=$(zenity --list \
        --title="Select Data Type" \
        --text="Select datatype for '$colName':" \
        --column="Type" "INT" "STR" \
        --width=400 --height=250)

    if [[ $? -ne 0 ]]; then
        zenity --info --text="Column type selection canceled. Skipping column." --width=350 --height=100
        continue
    fi

    pk_flag=""
    if [[ "$pk_set" == "false" ]]; then
        ans=$(zenity --list \
            --title="Primary Key" \
            --text="Is this column PRIMARY KEY?" \
            --column="Choice" "Yes" "No" \
            --width=350 --height=200)

        case "$ans" in
            Yes)
                pk_flag="PK"
                pk_set="true"
                ;;
            No)
                pk_flag=""
                ;;
            *)
                zenity --info --text="Skipping PK selection." --width=300 --height=80
                ;;
        esac
    fi

    entry="$colName:$dtype"
    if [[ -n "$pk_flag" ]]; then
        entry="$entry:$pk_flag"
    fi

    if [[ -z "$meta_line" ]]; then
        meta_line="$entry"
    else
        meta_line="$meta_line|$entry"
    fi

    zenity --info --text="Column '$colName' added." --width=350 --height=80
done

echo "$meta_line" > "$META_DIR/$tableName.meta"

zenity --info --text="Table '$tableName' created successfully!\n\nMetadata:\n$meta_line" \
    --width=600 --height=250
exit 0

