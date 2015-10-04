#!/bin/bash
# Created by Nicolae Ghimbovschi 2015
# https://github.com/xfreebird

function showActionMessage() { echo "⏳`tput setaf 12` $1 `tput op`"; }

function showMessage() {
	showActionMessage "$1"
	osascript -e "display notification \"$1\" with title \"Installer\""
}

function abort() { echo "!!! $@" >&2; exit 1; }

USERNAME=$(whoami)

[ "$USERNAME" = "root" ] && abort "Run as yourself, not root."
groups | grep -q admin || abort "Add $USERNAME to the admin group."

[[ "$PASSWORD" == "" ]] && abort "Set PASSWORD env variable with the passowrd of the $USERNAME."
[[ "$APPLE_USERNAME" == "" ]] && abort "Set APPLE_USERNAME env variable with the email of an Apple Developer Account."
[[ "$APPLE_PASSWORD" == "" ]] && abort "Set APPLE_PASSWORD env variable with the passowrd of an Apple Developer Account."

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
echo 'export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_79.jdk/Contents/Home' >> ~/.profile
echo 'export FINDBUGS_HOME=/usr/local/Cellar/findbugs/3.0.1/libexec' >> ~/.profile
echo 'export SONAR_RUNNER_HOME=/usr/local/Cellar/sonar-runner/2.4/libexec' >> ~/.profile
echo 'export M2_HOME=/usr/local/Cellar/maven30/3.0.5/libexec' >> ~/.profile
echo 'export M2=/usr/local/Cellar/maven30/3.0.5/libexec/bin' >> ~/.profile
echo 'export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:$ANDROID_HOME/bin:$PATH:$GOPATH:$GOPATH/bin' >> ~/.profile
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.profile
source ~/.profile

#==========================================================
#==== Update OSX
#==========================================================
showActionMessage "Updating the operating system"
sudo softwareupdate -i -a -v 

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
ocunit2junit nomad-cli cocoapods xcpretty xcode-install slather cloc \
fastlane deliver snapshot frameit pem sigh produce cert codes spaceship pilot gym \
calabash-cucumber calabash-android

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
xcode-install update
xcode_version_install="7"
#get the latest xcode version (non beta)
for xcode_version in $(xcode-install list | grep -v beta)
do
	xcode_version_install=$xcode_version
done

showActionMessage "Xcode $xcode_version:"
xcode-install install "$xcode_version_install"
sudo xcodebuild -license accept

#==========================================================
#==== Install Brew packages
#==========================================================
showActionMessage "Installing brew packages"
brew cask install oclint java java7

brew install \
lcov gcovr ios-sim \
node go xctool swiftlint \
android-sdk android-ndk findbugs sonar-runner maven30 ant gradle \
splunk-mobile-upload nexus-upload \
iosbuilder crashlytics-upload-ipa

brew install carthage

showActionMessage "Installing npm packages"
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

