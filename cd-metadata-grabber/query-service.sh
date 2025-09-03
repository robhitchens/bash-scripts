#!/usr/bin/env bash
# link to discogs api documentation <https://www.discogs.com/developers> 
# example request
#response=$(curl -i -H 'Accept: application/vnd.discogs.v2.discogs+json' -X 'GET' --location 'https://api.discogs.com/releases/249504' --user-agent 'cd-mdg/0.1')
# Note: authentication is required on search api.

# Just using key and secret for now for simple testing.
readonly auth="Authorization: Discogs key=$discogsKey, secret=$discogsSecret"
readonly barcode='0094636624822'
readonly userAgent='cd-mdg/0.1'

function fetchInitialData {
  local upc="$1"
  local response=$(curl -i \
    -H 'Accept: application/vnd.discogs.v2.discogs+json' \
    -H "$auth" \
    -X 'GET' \
    --location "https://api.discogs.com/database/search?barcode=$upc" \
    --user-agent "$userAgent")

  local lines=$(echo "$response" | wc -l)
  local responseHeaders=$(echo "$response" | head -n$(($lines-1)))
  local json=$(echo "$response" | tail -n1 | jq '.')

  echo "$json"
}

function fetchTrackInfo {
  local url="$1"

  local response=$(curl -i \
    -H 'Accept: application/vnd.discogs.v2.discogs+json' \
    -H "$auth" \
    -X 'GET' \
    --location "$url" \
    --user-agent "$userAgent") 

  local lines=$(echo "$response" | wc -l)
  local responseHeaders=$(echo "$response" | head -n$(($lines-1)))
  local json=$(echo "$response" | tail -n1 | \
    jq '{id: .id, artists: .artists, title: .title, genres: .genres, styles: .styles, year: .year, tracklist: .tracklist}')

  # TODO need to workout jq queries to reshape data in usable format for further processing  # TODO need to review format for tracklist metadata structure.
  echo "$json"
  # TODO use jq to pull out artist info
  # TODO use jq to pull out label info
  #      NOTE: it doesn't look like there's any label info on this request.
  # TODO use jq to pull out genre
  # TODO use jq to pull out album info
  # TODO use jq to pull track info and format into list of tracks
}


function fetchCoverImage {
  local outputFile="$1"
  local coverImageUrl="$2"

  # FIXME: this will probably bomb, will need to bring in my function for staging files to be written to.
  local absoluteFileOutput=$(realpath --relative-to=/ "$outputFile")

  curl \
    -X 'GET' \
    --user-agent "$userAgent" \
    -H 'Accept: image/jpeg' \
    --location "$location" > "$absoluteFileOutput"

}

readonly barcodeSearchResult=$(fetchInitialData "$barcode")
# FIXME: kinda cheesing the logic a bit, searchresults will most likely be an array, and may contain more than one entry even for a single barcode. Should probably query some other data to fully match the correct result.
#master_url=$(echo "$json" | jq '.results[0].master_url' | tr -d '"')
readonly masterUrl=$(echo "$barcodeSearchResult" | jq '.results[0].master_url' | tr -d '"' )
echo "master url: [$masterUrl]"
#use '.results[0].cover_image' to get cover art as jpeg
#readonly coverImageUrl=$(echo "$barcodeSearchResult" | jq '.results[0].cover_image' | tr -d '"')
#echo "cover image url: [$coverImageUrl]"

readonly trackInfo=$(fetchTrackInfo "$masterUrl")
echo "$trackInfo" 
# TODO need to test this out.
# fetchCoverImage "outputDir" "$coverImageUrl"

# so from the response we want to take the results[0].master_url property and fetch it for track information.
# If there's more than one result, will need to decide upon criteria for picking one.

# Link to search api on discogs: https://www.discogs.com/developers#page:database,header:database-search
#
# TODO need to work on creating functions and structure for retrieving metadata information.
