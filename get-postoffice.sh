#!/bin/bash

OWNER="Kethen"
REPO="aemu_postoffice"
API_URL="https://api.github.com/repos/$OWNER/$REPO/releases/latest"
RELEASE_DATA=$(curl -s $API_URL)
TAG_NAME=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
DOWNLOAD_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | startswith("aemu_")) | .browser_download_url')


if [ -z $DOWNLOAD_URL ]
then
    echo "No download URL could be found."
    exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")

echo "Downloading $FILENAME"
wget -O "$FILENAME" "$DOWNLOAD_URL"
unzip -d aemu_postoffice "$FILENAME"
rm -v "$FILENAME"
