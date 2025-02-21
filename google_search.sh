#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 \"search term\" [max_results]"
  exit 1
fi

search_term="$1"
encoded_search_term=$(echo "$search_term" | sed 's/ /+/g')
max_results=${2:-50}  # Default to 50 results
results_per_page=10   # Google typically shows 10 results per page
download_folder="resume"
mkdir -p "$download_folder"
filename="urls.txt"
> "$filename"

# Fetch results page by page
for ((start=0; start<max_results; start+=results_per_page)); do
  page_results=$(curl -s "https://www.google.com/search?q=$encoded_search_term&start=$start" -A "Mozilla/5.0" | \
                 grep -oP 'https?://[^"]+\.xls' | uniq)
  if [ -n "$page_results" ]; then
    echo "$page_results" >> "$filename"
  else
    echo "No more results found at offset $start. Exiting pagination."
    break
  fi
done

# Deduplicate URLs
sort -u -o "$filename" "$filename"

# Download PDFs
wget -i "$filename" -P "$download_folder"

echo "Downloaded PDFs are saved in $download_folder. URLs logged in $filename."
