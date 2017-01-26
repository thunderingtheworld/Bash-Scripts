#!/bin/bash

# Function for notifications. Good for getting progress status.
notif () {
 osascript <<EOD
 display notification "$1" \
 with title "First setup"
EOD
}


xcode-select --install
osascript <<EOD
display dialog \
"A window should have popped up behind this one, prompting installation of XCode CLI Tools.\nClick OK when XCode CLI tools are installed. NOT BEFORE!" \
buttons {"Cancel", "OK"} \
with title "Wait for it..." \
with icon caution
EOD


# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  notif "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Fix the PATH so brew works properly
echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
brew doctor

# Now update
notif "Updating Brew and installing a few tools"
# Update homebrew recipes
brew update

# Some of the following is necessary for security reasons (Shellshock)
# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install Bash 4
brew install bash

# Install more recent versions of some OS X tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep

# Install some binaries
binaries=(
  apple-gcc42
  git
  git-extras
  python
  python3
  hub
  node
)

notif "Installing binaries..."

brew install ${binaries[@]}

brew link --overwrite python

# Install brew vim
brew install vim --env-std --override-system-vim

brew cleanup

notif "Setting up pip and virtualenv..."
sudo pip install virtualenv
sudo pip install virtualenvwrapper
cd $HOME
mkdir .virtualenvs

# Now to set up some software using Cask
brew install caskroom/cask/brew-cask
brew tap caskroom/unofficial
brew tap caskroom/versions
# One for popcorn time
brew tap casidiablo/homebrew-custom
# Get my own custom homebrew stuffs
brew tap 7oi/homebrew-custom

# Apps
apps=(
  bettertouchtool
  codekit
  cycling74-max
  iterm2
  lastpass
  macaw
  paragon-ntfs
  pd-extended
  pycharm
  unrarx
  wacom-tablet
  vlc
  xquartz
)

# Install apps to /Applications
# Default is: /Users/$user/Applications
notif "Installing apps..."
brew cask install --appdir="/Applications" ${apps[@]}

# ...aaaand fonts!
brew tap caskroom/fonts

# fonts
fonts=(
  font-anonymous-pro-for-powerline
  font-clear-sans
  font-dejavu-sans-mono-for-powerline
  font-droid-sans-mono-for-powerline
  font-inconsolata-dz-for-powerline
  font-m-plus
  font-merriweather
  font-merriweather-sans
  font-meslo-lg-for-powerline
  font-roboto
)

brew cask install ${fonts[@]}

# Set up Powerline
pip install https://github.com/Lokaltog/powerline/tarball/develop


# Cleanup
brew linkapps
brew cleanup
brew prune
brew cask cleanup

chsh -s /bin/zsh

# Create symlinks with ln -s path/to/original /path/to/link
# Get files from google drive: gdget.py file_id
