#!/usr/bin/env bash
# link to discogs api documentation <https://www.discogs.com/developers> 
# example request
#response=$(curl -i -H 'Accept: application/vnd.discogs.v2.discogs+json' -X 'GET' --location 'https://api.discogs.com/releases/249504' --user-agent 'cd-mdg/0.1')
# Note: authentication is required on search api.

# Just using key and secret for now for simple testing.
auth="Authorization: Discogs key=$discogsKey, secret=$discogsSecret"
response=$(curl -i -H 'Accept: application/vnd.discogs.v2.discogs+json' -H "$auth" -X 'GET' --location 'https://api.discogs.com/database/search?barcode=0094636624822' --user-agent 'cd-mdg/0.1')
lines=$(echo "$response" | wc -l)
echo "$(echo "$response" | head -n$(($lines-1)))"
echo "$response" | tail -n1 | jq '.'

# Link to search api on discogs: https://www.discogs.com/developers#page:database,header:database-search
