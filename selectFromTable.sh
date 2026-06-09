#!/usr/bin/bash

BASE_DIR="./DataBases"

DBname="$1"
Tname="$2"

if [[ -z "$DBname" || -z "$Tname" ]]; then
    zenity --error --text="Usage: ./selectFromTable.sh DBname TableName" --width=350 --height=100
    exit 1
fi

META_FILE="$BASE_DIR/$DBname/Meta/$Tname.meta"
DATA_FILE="$BASE_DIR/$DBname/Tables/$Tname"

if [[ ! -f "$META_FILE" ]]; then
    zenity --error --text="Meta file not found: $META_FILE" --width=400 --height=100
    exit 1
fi

if [[ ! -f "$DATA_FILE" ]]; then
    zenity --error --text="Data file not found: $DATA_FILE" --width=400 --height=100
    exit 1
fi

meta_line=$(cat "$META_FILE")
IFS='|' read -r -a columns <<< "$meta_line"

pk_index=-1
col_names=()
pk_name=""
for idx in "${!columns[@]}"; do
    cname=$(echo "${columns[$idx]}" | cut -d':' -f1)
    flag=$(echo "${columns[$idx]}" | cut -d':' -f3)
    col_names+=("$cname")
    if [[ "$flag" == "PK" ]]; then
        pk_index=$((idx+1))
        pk_name="$cname"
    fi
done

if [[ $pk_index -eq -1 ]]; then
    zenity --error --text="No PK defined for this table!" --width=400 --height=100
    exit 1
fi

choice=$(zenity --list \
    --title="Select From Table: $Tname" \
    --text="Choose selection type:" \
    --column="Option" \
    "Select ALL columns" "Select SPECIFIC columns" "Select WHERE PK = value" \
    --width=400 --height=400)

if [[ $? -ne 0 ]]; then
    exit 0
fi

if [[ "$choice" == "Select ALL columns" ]]; then
    result=$(awk -F',' '{print}' "$DATA_FILE" | column -t -s ',')
    zenity --text-info --title="All rows from $Tname" --width=700 --height=400 --editable --filename=<(echo "$result")
    exit 0
fi

if [[ "$choice" == "Select SPECIFIC columns" ]]; then
    col_choices=()
    for cname in "${col_names[@]}"; do
        col_choices+=("$cname" "FALSE")
    done

      col_choices=()
    for cname in "${col_names[@]}"; do
        col_choices+=("FALSE" "$cname")
    done

    selected=$(zenity --list \
        --checklist \
        --title="Select Columns" \
        --text="Select columns to display:" \
        --column="Select" --column="Column" \
        "${col_choices[@]}" \
        --width=500 --height=400)
        
        
    if [[ $? -ne 0 || -z "$selected" ]]; then
        zenity --info --text="No columns selected." --width=350 --height=100
        exit 0
    fi

    IFS='|' read -r -a sel_cols <<< "$selected"
    col_indexes=()
    for s in "${sel_cols[@]}"; do
        for idx in "${!col_names[@]}"; do
            if [[ "${col_names[$idx]}" == "$s" ]]; then
                col_indexes+=($((idx+1)))
            fi
        done
    done

    cols_str=$(IFS=','; echo "${col_indexes[*]}")

    result=$(awk -F',' -v cols="$cols_str" '
    BEGIN { n = split(cols, c, ",") }
    {
        out=""
        for(i=1;i<=n;i++){
            idx=c[i]
            if(out=="") out=$idx
            else out=out","$idx
        }
        print out
    }' "$DATA_FILE" | column -t -s ',')

    zenity --text-info --title="Selected columns from $Tname" --width=700 --height=400 --editable --filename=<(echo "$result")
    exit 0
fi

if [[ "$choice" == "Select WHERE PK = value" ]]; then
    pk_val=$(zenity --entry --title="Search by PK" --text="Enter PK value ($pk_name):" --width=400 --height=120)
    if [[ $? -ne 0 || -z "$pk_val" ]]; then
        exit 0
    fi

    result=$(awk -F',' -v pk_col="$pk_index" -v pk_val="$pk_val" '{if($pk_col==pk_val) print}' "$DATA_FILE" | column -t -s ',')

    if [[ -z "$result" ]]; then
        zenity --info --text="No row found with PK=$pk_val" --width=350 --height=100
        exit 0
    fi

    zenity --text-info --title="Row with PK=$pk_val from $Tname" --width=700 --height=400 --editable --filename=<(echo "$result")
    exit 0
fi

zenity --error --text="Invalid selection!" --width=350 --height=100
exit 1
