#!/usr/bin/env bash

# TODO should add steps to download and install go from source
# TODO should add variable for go version
# TODO should add options to install go versions side by side
# FIXME: forgot to curl command to download go binary.
readonly goversion='go1.25.3.linux-amd64.tar.gz'
cd ~/.local/share
curl -L "https://go.dev/dl/${goversion}" -o "./${goversion}"
rm -rf ~/.local/share/go && \
tar -C ~/.local/share -xzvf "${goversion}"
# TODO should check to see if line already exists in bashrc
cat "export PATH=\$PATH:$HOME/.local/share/go/bin" >> ~/.bashrc
# Install delve debugger
go install github.com/go-delve/delve/cmd/dlv@latest
cat "export PATH=\$PATH:$HOME/go/bin" >> ~/.bashrc

# Install gore repl
go install github.com/x-motemen/gore/cmd/gore@latest
