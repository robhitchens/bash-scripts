#!/usr/bin/env bash
#location='https://api.discogs.com/masters/12032'
#location='https://api.discogs.com/releases/704921'
location='https://i.discogs.com/umCnUGVPr-YjsjL10pTbHpxzPnW93OlHyWreTPU9jnQ/rs:fit/g:sm/q:90/h:600/w:600/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTcwNDky/MS0xMzMzMjAzOTQ4/LmpwZWc.jpeg'
#response=$(curl -i --user-agent 'cd-mdg/0.1' -H 'Accept: image/jpeg' --location "$location")

#lines=$(echo "$response" | wc -l)
#echo "number of lines $lines"
#echo "$(echo "$response" | head -n$(($lines-1)))"
#echo "$response" | tail -n1 | jq '.'
#echo "$response" | base64

# Will need to do something like below to fetch album cover art.
curl --user-agent 'cd-mdg/0.1' -H 'Accept: image/jpeg' --location "$location" > /tmp/nitzer-ebb-bodywork-remixes-cover.jpeg

