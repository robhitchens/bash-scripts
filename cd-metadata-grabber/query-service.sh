#!/usr/bin/env bash
# link to discogs api documentation <https://www.discogs.com/developers> 
# example request
response=$(curl -i -X 'GET' --location 'https://api.discogs.com/releases/249504' --user-agent 'cd-mdg/0.1')
lines=$(echo "$response" | wc -l)
echo "$(echo "$response" | head -n$(($lines-1)))"
echo "$response" | tail -n1 | jq '.'
