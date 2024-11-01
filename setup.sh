#!/usr/bin/env bash

# Check if Homebrew is installed
if test ! $(which brew); then
    echo "Homebrew not installed"
    echo "Installing Homebrew"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed"
fi

echo "Updating Homebrew"
brew doctor
brew update
echo "Homebrew installed"

# Install Xcode Command Line Tools, if not installed
xcode-select --install

# So we use all of the packages we are about to install
echo "export PATH='/usr/local/bin:$PATH'\n" >> ~/.bashrc
source ~/.bashrc

# Install all packages from Brewfile
echo "Starting to install packages from Brewfile"
brew bundle --file=./homebrew/Brewfile
echo "Brewfile packages installed"

echo "Symlinking Docker CLI plugins"
mkdir -p ~/.docker/cli-plugins
ln -sfn $(which docker-compose) ~/.docker/cli-plugins/docker-compose
ln -sfn $(which docker-buildx) ~/.docker/cli-plugins/docker-buildx
echo "Docker CLI plugins linked"

rm -rf ~/.bashrc > /dev/null 2>&1
rm -rf ~/.vim > /dev/null 2>&1
rm -rf ~/.vimrc > /dev/null 2>&1
rm -rf ~/.zshrc > /dev/null 2>&1
rm -rf ~/.zprofile > /dev/null 2>&1
rm -rf ~/.gitconfig > /dev/null 2>&1
rm -rf ~/.gitignore_global > /dev/null 2>&1
rm -rf ~/.psqlrc > /dev/null 2>&1
rm -rf ~/.config/starship/starship.toml > /dev/null 2>&1
rm -rf ~/Brewfile > /dev/null 2>&1

apps=$(ls homedir)
echo "Stowing apps for user: ${whoami}"
for app in ${apps[@]}; do
    # If the directory name starts with mac and the OS is not macOS, skip
    if [[ $app == mac-* && $(uname) != "Darwin" ]]; then
        continue
    fi
    stow -v -R -t "${HOME}" -d "homedir" --dotfiles $app 
done
echo "Stowing complete!"

if [[ $(uname) != "Darwin" ]]; then
    read -r -p "Do you want install apps using the Caskfile? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        echo "Starting to install apps from Caskfile"
        brew bundle --file=./homebrew/Caskfile
        echo "Caskfile apps installed"
    fi
fi

read -r -p "Do you want to set the gitconfig user info? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    # Interactivily change git config
    read -p "Enter name for gitconfig: " gitname
    read -p "Enter email for gitconig: " gitemail

    echo [user]\n\tname = ${gitname}\n\temail = ${gitemail} > ~/.gitconfig_local
fi

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

    curl -fsSL https://bun.sh/install | bash

    echo "Bun installed"
fi

echo "Setup complete! Please restart your terminal to see the changes"