#!/bin/sh

echo "Generating a new SSH key..."

# Generating a new SSH key
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
ssh-keygen -t ed25519 -C $1 -f ~/.ssh/id_ed25519

# Adding your SSH key to the ssh-agent
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
eval "$(ssh-agent -s)"

touch ~/.ssh/config
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

if [[ $(uname) == "Darwin" ]]; then
    ssh-add -K ~/.ssh/id_ed25519
else
    ssh-add ~/.ssh/id_ed25519
fi

if [[ $(uname) == "Darwin" ]]; then
    pbcopy < ~/.ssh/id_ed25519.pub
else
    xclip -selection clipboard < ~/.ssh/id_ed25519.pub
fi

git remote set-url origin git@github.com:se-bastiaan/dotfiles.git