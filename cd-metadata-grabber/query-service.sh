#!/usr/bin/env bash
# link to discogs api documentation <https://www.discogs.com/developers> 
# example request
#response=$(curl -i -H 'Accept: application/vnd.discogs.v2.discogs+json' -X 'GET' --location 'https://api.discogs.com/releases/249504' --user-agent 'cd-mdg/0.1')
# Note: authentication is required on search api.

# Just using key and secret for now for simple testing.
auth="Authorization: Discogs key=$discogsKey, secret=$discogsSecret"

response=$(curl -i \
  -H 'Accept: application/vnd.discogs.v2.discogs+json' \
  -H "$auth" \
  -X 'GET' \
  --location 'https://api.discogs.com/database/search?barcode=0094636624822' \
  --user-agent 'cd-mdg/0.1')

lines=$(echo "$response" | wc -l)
echo "$(echo "$response" | head -n$(($lines-1)))"
json=$(echo "$response" | tail -n1 | jq '.')

echo "$json"

#use '.results[0].cover_image' to get cover art as jpeg

#master_url=$(echo "$json" | jq '.results[0].master_url' | tr -d '"')
#albumInfo=$(curl -i --user-agent 'cd-mdg/0.1' --location "$master_url")

# echo "$albumInfo" | tail -n1 | jq '.'
 
# so from the response we want to take the results[0].master_url property and fetch it for track information.
# If there's more than one result, will need to decide upon criteria for picking one.

# Link to search api on discogs: https://www.discogs.com/developers#page:database,header:database-search
