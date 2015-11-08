#!/bin/bash
# Created by Nicolae Ghimbovschi 2015
# https://github.com/xfreebird

function showActionMessage() { echo "⏳`tput setaf 12` $1 `tput op`"; }

function showMessage() {
  showActionMessage "$1"
  osascript -e "display notification \"$1\" with title \"Installer\""
}

function cleanUp() {
  showActionMessage "Revoking passwordless sudo for '$USERNAME'"
  sudo -S bash -c "cp /etc/sudoers.orig /etc/sudoers"
  exit 0
}

function ver() { 
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ') 
}

function abort() { echo "!!! $@" >&2; exit 1; }

USERNAME=$(whoami)

[ "$USERNAME" = "root" ] && abort "Run as yourself, not root."
groups | grep -q admin || abort "Add $USERNAME to the admin group."

echo -n "Apple Account (e.g. user@mail.com): "
read APPLE_USERNAME

echo -n "Apple Account Password: "
read -s APPLE_PASSWORD
echo 

[[ "$APPLE_USERNAME" == "" ]] && abort "Set APPLE_USERNAME env variable with the email of an Apple Developer Account."
[[ "$APPLE_PASSWORD" == "" ]] && abort "Set APPLE_PASSWORD env variable with the password of an Apple Developer Account."

#==========================================================
#==== Enable passwordless sudo
#==== Very important to have this running without the need
#==== of user input
#==========================================================
showActionMessage "Enabling Temporary passwordless sudo for '$USERNAME'"
sudo bash -c "cp /etc/sudoers /etc/sudoers.orig; echo '${USERNAME} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"

#==========================================================
#==== Call cleanUp if the script is stopped, finishes or 
#==== is terminated
#==========================================================
trap cleanUp SIGHUP SIGINT SIGTERM EXIT

showActionMessage "Enabling Developer Mode"
sudo /usr/sbin/DevToolsSecurity --enable
sudo /usr/sbin/dseditgroup -o edit -t group -a staff _developer

showActionMessage "Fixing permission issues for calabash"
sudo security authorizationdb write system.privilege.taskport allow

showActionMessage "Injecting environment variables"
echo 'export LC_ALL=en_US.UTF-8' > ~/.profile
echo 'export ANDROID_HOME=/usr/local/opt/android-sdk' >> ~/.profile
echo 'export NDK_HOME=/usr/local/opt/android-ndk' >> ~/.profile
echo 'export GOPATH=/usr/local/opt/go/libexec' >> ~/.profile
echo 'export FINDBUGS_HOME=/usr/local/Cellar/findbugs/3.0.1/libexec' >> ~/.profile
echo 'export SONAR_RUNNER_HOME=/usr/local/Cellar/sonar-runner/2.4/libexec' >> ~/.profile
echo 'export M2_HOME=/usr/local/Cellar/maven30/3.0.5/libexec' >> ~/.profile
echo 'export M2=/usr/local/Cellar/maven30/3.0.5/libexec/bin' >> ~/.profile
echo 'export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$ANDROID_HOME/bin:$PATH:$GOPATH:$GOPATH/bin' >> ~/.profile
echo 'export JENV_ROOT=/usr/local/var/jenv' >> ~/.profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.profile
echo 'if which jenv > /dev/null; then eval "$(jenv init -)"; fi' >> ~/.profile
source ~/.profile

ln -s ~/.profile ~/.bashrc

#==========================================================
#==== Update OSX
#==========================================================
showActionMessage "Updating the operating system"
sudo softwareupdate -i -a -v 

#==========================================================
#==== Upgrade system Ruby
#==========================================================
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sudo gem update -p

#==========================================================
#==== Install Xcode command line tools
#==== Required by Brew and Ruby Gems
#==========================================================
showActionMessage "Installing Xcode command line tools."
# https://github.com/timsutton/osx-vm-templates/blob/master/scripts/xcode-cli-tools.sh
sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
sudo softwareupdate -i "$PROD" -v
sudo rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

#==========================================================
#==== Install Brew and taps
#==========================================================
showActionMessage "Installing brew"
echo "" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew tap homebrew/versions
brew tap xfreebird/utils
brew tap facebook/fb
brew tap caskroom/cask
brew tap caskroom/versions
brew install caskroom/cask/brew-cask

#==========================================================
#==== Install Alternative Ruby Environment
#==== User writeable, no need for sudo
#==========================================================
showActionMessage "Installing rbenv 2.2.3"
brew install rbenv ruby-build
eval "$(rbenv init -)"
rbenv install 2.2.3
rbenv global 2.2.3

#==========================================================
#==== Reload the shell environment
#==========================================================
source ~/.profile

#==========================================================
#==== Install Ruby Gems
#==========================================================
showActionMessage "Installing rbenv Gems"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem update -p
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | gem install bundler \
ocunit2junit nomad-cli cocoapods xcpretty xcode-install slather cloc synx \
fastlane deliver snapshot frameit pem sigh produce cert codes spaceship pilot gym \
calabash-cucumber calabash-android

# temporary fix for cocoapods 
# https://github.com/CocoaPods/CocoaPods/issues/2908
gem uninstall psych --all
gem install psych -v 2.0.0

#==========================================================
#==== Reload the shell environment
#==========================================================
source ~/.profile

#==========================================================
#==== Install the latest available Xcode from
#==== http://developer.apple.com/downloads
#==== We don't use the AppStore Xcode
#==========================================================
showActionMessage "Installing the latest Xcode:"
export XCODE_INSTALL_USER="$APPLE_USERNAME"
export XCODE_INSTALL_PASSWORD="$APPLE_PASSWORD"
xcversion update
xcode_version_install=""
xcode_latest_installed_version=$(xcversion installed | cut -f1 | tail -n 1)

#get the latest xcode version (non beta)
for xcode_version in $(xcversion list | grep -v beta)
do
  xcode_version_install=$xcode_version
done

if [ x"$xcode_version_install" != x"" ]; then
  if [ $(ver "$xcode_version_install") -gt $(ver "$xcode_latest_installed_version") ];
  then
    showActionMessage "Xcode $xcode_version:"
    xcversion install "$xcode_version_install"
    sudo xcodebuild -license accept
  fi
fi

#==========================================================
#==== Install Brew packages
#==========================================================
showActionMessage "Installing brew packages"
brew update
brew upgrade

brew cask install oclint java java7

#==========================================================
#==== Install Alternative Java Environment
#==== User writeable, no need for sudo
#==========================================================
showActionMessage "Installing jenv"
brew install jenv
eval "$(jenv init -)"
for java_home in $(/usr/libexec/java_home -V 2>&1 | uniq | grep -v Matching | grep "Java SE" | cut -f3 | sort)
do
( sleep 1 && while [ 1 ]; do sleep 1; echo y; done ) | jenv add "$java_home"
done

jenv global 1.7

brew install \
git bash-completion \
lcov gcovr ios-sim \
node go xctool swiftlint \
android-sdk android-ndk findbugs sonar-runner maven30 ant gradle \
splunk-mobile-upload nexus-upload \
iosbuilder crashlytics-upload-ipa \
mobile-dev-update

brew install carthage

git config --global credential.helper osxkeychain

echo '# Command prompt' >> ~/.profile
echo 'source /usr/local/etc/bash_completion'  >> ~/.profile
echo "PS1='\[\\033[01;32m\]\u@\h\[\\033[00m\]:\[\\033[01;33m\]\w\[\\033[00m\]\[\\033[01;31m\]\$(__git_ps1 \" (%s)\")\[\\033[00m\]\$ '" >> ~/.profile

showActionMessage "Installing npm packages"
npm install npm@latest -g
npm install -g appium wd npm-check-updates cordova phonegap

#==========================================================
#==== Install Additional Android SDK Components
#==========================================================
showActionMessage "Installing additional Android SDK components. \
Except Emulators, Documentation, Sources, Obsolete packages, Web Driver, Glass and Android TV"
packages=""
for package in $(android list sdk --all | \
  grep -v -e "Obsolete" -e "Sources" -e  "x86" -e  "Samples" \
  -e "ARM EABI" -e "ARM System Image" -e "API 8" -e "API 8" -e "API 10" -e "API 15" \
  -e "API 16" -e "API 17" -e "API 18"  -e "API 20" -e "rc" \
  -e  "Documentation" -e  "MIPS" -e "Android TV" \
  -e "Build-tools, revision 19.1" -e "Build-tools, revision 20" -e "Build-tools, revision 21.1.2" \
  -e  "Glass" -e  "XML" -e  "URL" -e  "Packages available" \
  -e  "Fetch" -e  "Web Driver" | \
  cut -d'-' -f1)
do
    packages=$(printf "${packages},${package}")
done

( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --all --no-ui --filter "$packages"
( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --all --no-ui --filter platform-tools


showMessage "Done!"

