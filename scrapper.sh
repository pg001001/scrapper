#!/bin/bash

# sudo apt update
# sudo apt install googler wget libreoffice

# Dependencies check
command -v googler >/dev/null 2>&1 || { echo >&2 "googler is required but it's not installed. Install it using 'sudo apt install googler'."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required but it's not installed. Install it using 'sudo apt install wget'."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "unzip is required but it's not installed. Install it using 'sudo apt install unzip'."; exit 1; }
command -v libreoffice >/dev/null 2>&1 || { echo >&2 "libreoffice is required for converting XLS files to CSV. Install it using 'sudo apt install libreoffice'."; exit 1; }

# Create directories
DOWNLOAD_DIR="downloaded_files"
MERGED_FILE="merged_data.csv"
mkdir -p "$DOWNLOAD_DIR"

echo "Searching for .xls and .csv files containing '@gmail.com'..."
# Perform Google Dork search using googler and extract URLs
googler --noprompt 'filetype:xls OR filetype:csv "@gmail.com"' --count 50 | grep -Eo 'http[s]?://[^ ]+' > urls.txt

echo "Downloading files..."
# Download files
while read -r url; do
    filename=$(basename "$url")
    wget -q --show-progress -P "$DOWNLOAD_DIR" "$url"
done < urls.txt

echo "Converting .xls files to .csv and merging data..."
# Convert XLS to CSV and merge all CSV files
for file in "$DOWNLOAD_DIR"/*; do
    extension="${file##*.}"
    
    if [[ "$extension" == "xls" || "$extension" == "xlsx" ]]; then
        # Convert XLS/XLSX to CSV using LibreOffice
        libreoffice --headless --convert-to csv "$file" --outdir "$DOWNLOAD_DIR"
        csv_file="${file%.*}.csv"
        if [[ -f "$csv_file" ]]; then
            cat "$csv_file" >> "$MERGED_FILE"
            rm "$csv_file"
        fi
    elif [[ "$extension" == "csv" ]]; then
        cat "$file" >> "$MERGED_FILE"
    fi
done

echo "Data merged into $MERGED_FILE"

# Clean up
rm -rf "$DOWNLOAD_DIR"
rm urls.txt

echo "All done!"
