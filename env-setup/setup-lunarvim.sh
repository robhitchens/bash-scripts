# Install neovim
curl --verbose -OL https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
tar -C /usr/local/ -xvzf nvim-linux-x86_64.tar.gz
mv /usr/local/nvim-linux-x86_64 /usr/local/nvim
# TODO should add check to see if line already exists in bashrc
cat "export PATH=$PATH:/usr/local/nvim/bin/" >> ~/.bashrc
# TODO add step to cleanup archive
rm nvim-linux-x86_64.tar.gz

# Setup Node
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.14.0".
nvm current # Should print "v22.14.0".

# Verify npm version:
npm -v # Should print "10.9.2".

# Setup cargo NOTE this is an interactive installer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Refresh shell
. "$HOME/.cargo/env"

# Check version
rustc --version

cargo install ripgrep

# install lunarvim NOTE interactive
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)

echo "export PATH=$PATH:/$HOME/.local/bin/"
