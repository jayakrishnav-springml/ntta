#!/bin/bash

# Check if arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <source_project> <destination_project> <table_list_file>"
    exit 1
fi

# Get arguments from command line
source_project="$1"
destination_project="$2"
table_list_file="$3"


# WARNING AND CONFIRMATION PROMPT
echo -e "\nWARNING: This script will copy and overwrite tables in project '$destination_project' from '$source_project'.\n"
read -p "Are you sure you want to proceed? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi


# Check if table list file exists
if [ ! -f "$table_list_file" ]; then
    echo "Error: Table list file '$table_list_file' not found."
    #create the list with this but use ONLY tables you want to copy
    #select TABLE_NAME from edw_TRIPS.INFORMATION_SCHEMA.TABLES

    exit 1
fi

while IFS= read -r table
do
    # Remove leading/trailing whitespace and check if line is empty
    table=$(echo "$table" | xargs)
    if [[ -n "$table" ]]; then
        echo "Copying table: $table"
        echo "bq cp --force=true ${source_project}:${table} ${destination_project}:${table}"
        bq cp --force=true "${source_project}:${table}" "${destination_project}:${table}"
        if [ $? -ne 0 ]; then
            echo "Error copying table: $table"
            exit 1
        fi
    fi
done < "$table_list_file"

echo "All tables copied successfully."
