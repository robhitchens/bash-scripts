#!/usr/bin/env bash
mkdir -p /tmp/discord-update
curl --verbose --output-dir "/tmp/discord-update"  -OL 'https://discord.com/api/download/stable?platform=linux&format=deb'
sudo dpkg -i /tmp/discord-update/stable 
