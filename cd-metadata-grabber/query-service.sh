#!/usr/bin/env bash
# link to discogs api documentation <https://www.discogs.com/developers> 
# example request
echo $(curl -X 'GET' --location 'https://api.discogs.com/releases/249504') | jq '.'
