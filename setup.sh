#! /bin/zsh

# Install Homebrew
echo "Installing Homebrew"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew doctor
brew update
echo "Homebrew installed"

# Install Xcode Command Line Tools
xcode-select --install

# So we use all of the packages we are about to install
echo "export PATH='/usr/local/bin:$PATH'\n" >> ~/.bashrc
source ~/.bashrc

# Remove old dot flies
sudo rm -rf ~/.bashrc > /dev/null 2>&1
sudo rm -rf ~/.vim > /dev/null 2>&1
sudo rm -rf ~/.vimrc > /dev/null 2>&1
sudo rm -rf ~/.zshrc > /dev/null 2>&1
sudo rm -rf ~/.zprofile > /dev/null 2>&1
sudo rm -rf ~/.gitconfig > /dev/null 2>&1
sudo rm -rf ~/.gitignore_global > /dev/null 2>&1
sudo rm -rf ~/.psqlrc > /dev/null 2>&1
sudo rm -rf ~/.config > /dev/null 2>&1
sudo rm -rf ~/Brewfile > /dev/null 2>&1

echo "Old dotfiles removed"

# Create symlinks
SYMLINKS=()
ln -sf $(pwd)/homedir/vim ~/.vim
SYMLINKS+=('.vim')
ln -sf $(pwd)/homedir/vimrc ~/.vimrc
SYMLINKS+=('.vimrc')
ln -sf $(pwd)/homedir/bashrc ~/.bashrc
SYMLINKS+=('.bashrc')
ln -sf $(pwd)/homedir/zshrc ~/.zshrc
SYMLINKS+=('.zshrc')
ln -sf $(pwd)/homedir/zprofile ~/.zprofile
SYMLINKS+=('.zprofile')
ln -sf $(pwd)/homedir/config ~/.config
SYMLINKS+=('.config')
ln -s $(pwd)/homedir/gitconfig ~/.gitconfig
SYMLINKS+=('.gitconfig')
ln -s $(pwd)/homedir/gitignore_global ~/.gitignore_global
SYMLINKS+=('.gitignore_global')
ln -s $(pwd)/homedir/psqlrc ~/.psqlrc
SYMLINKS+=('.psqlrc')
ln -sf $(pwd)/homebrew/Brewfile ~/Brewfile
SYMLINKS+=('Brewfile')

echo ${SYMLINKS[@]} "symlinks created"

read -r -p "Do you want to change the gitconfig user info? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # Interactivily change git config
    read -p "Enter name for gitconfig: " gitname
    read -p "Enter email for gitconig: " gitemail

    git config --global user.name gitname
    git config --global user.email gitemail
fi

# Install all packages from Brewfile
echo "Starting to install packages from Brewfile"
brew bundle --file=~/Brewfile
echo "Brewfile packages installed"

read -r -p "Do you want to change to install nvm and the latest Node LTS? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Installing nvm and latest Node LTS"

    git_latest_release() {
        basename $(curl -fs -o/dev/null -w %{redirect_url} https://github.com/$1/releases/latest)
    }
    nvm_version=$(git_latest_release "nvm-sh/nvm");

    echo "Installing nvm version: ${nvm_version}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts

    echo "nvm and latest Node LTS installed"
fi

read -r -p "Do you want to install the latest Python 3 version using pyenv? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Installing latest Python 3 version using pyenv"

    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    pyenv install 3
    pyenv global 3

    echo "Latest Python 3 version installed"
fi

read -r -p "Do you want to install Poetry? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Installing Poetry"

    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="/Users/sebastiaan/.local/bin:$PATH"
    poetry config virtualenvs.in-project true
    poetry completions zsh > ~/.zfunc/_poetry

    echo "Poetry installed"
fi

read -r -p "Do you want to install Rye? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Installing Rye"

    curl -sSf https://rye.astral.sh/get | bash
    rye self completion -s zsh > ~/.zfunc/_rye

    echo "Rye installed"
fi

read -r -p "Do you want to install Rust? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Installing Rust"

    curl https://sh.rustup.rs -sSf | sh
    export PATH="$HOME/.cargo/bin:$PATH"

    echo "Rust installed"
fi

read -r -p "Do you want to install Bun? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Installing Bun"

    curl -sSL https://bun.sh | bash

    echo "Bun installed"
fi

echo "Setup complete! Please restart your terminal to see the changes"