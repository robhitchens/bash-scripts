#!/usr/bin/env bash

# TODO should add steps to download and install go from source
# TODO should add variable for go version
# TODO should add options to install go versions side by side
rm -rf /usr/local/go && \
tar -C /usr/local -xzvf go1.24.3.linux-amd64.tar.gz
# TODO should check to see if line already exists in bashrc
cat "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
# Install delve debugger
go install github.com/go-delve/delve/cmd/dlv@latest
cat "export PATH=$PATH:$HOME/go/bin" >> ~/.bashrc

# Install gore repl
go install github.com/x-motemen/gore/cmd/gore@latest
