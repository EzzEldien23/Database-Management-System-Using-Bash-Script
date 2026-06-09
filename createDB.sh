#!/usr/bin/bash

BASE_DIR="./DataBases"
mkdir -p "$BASE_DIR"

while true; do

    DBname=$(zenity --entry \
        --title="Create Database" \
        --text="Enter database name (or type 'back' to exit):" \
        --width=500 --height=100)

    if [[ $? -ne 0 ]]; then
        zenity --info --text="Exiting create database..." --width=350 --height=80
        break
    fi

    if [[ "$DBname" == "back" ]]; then
        zenity --info --text="Going back..." --width=300 --height=80
        break
    fi

    if [[ -z "$DBname" ]]; then
        zenity --error --text="Name cannot be empty!" --width=300 --height=80
        continue
    fi

    if [[ ! "$DBname" =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
        zenity --error --text="Invalid name!\n- Must start with a letter\n- Allowed characters: letters, numbers, _" \
            --width=400 --height=120
        continue
    fi

    if [[ -e "$BASE_DIR/$DBname" ]]; then
        zenity --error --text="Database '$DBname' already exists. Try another name." --width=350 --height=80
        continue
    fi

    mkdir "$BASE_DIR/$DBname"
    mkdir "$BASE_DIR/$DBname/Tables"
    mkdir "$BASE_DIR/$DBname/Meta"

    zenity --info --text="Database created successfully: $DBname" --width=350 --height=80
    break

done

