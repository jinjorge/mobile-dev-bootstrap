# mobile-dev-bootstrap
Setup developer workstation for Android and iOS mobile development

# Requirements

* A fresh installed OS X 10.10+
* User with admin rights
* Apple developer account (for Xcode)
* Internet connection

# How to use ?

On your developer machine run:

```shell
bash <(curl -s https://raw.githubusercontent.com/xfreebird/mobile-dev-bootstrap/master/mobile-dev-bootstrap.sh)
```

At the end you will have:

* **Android** and **iOS** 📱 developemnt ready environment


# Why ?

**To save time**

All the process is automated, it asks the user password and Apple Developer password at the beginning.

# What do you get ?

OS X optimised mobile Android and iOS development.


## Android
* [`Android SDK`](https://developer.android.com/sdk/index.html) [`Android  NDK`](https://developer.android.com/ndk/index.html)
* [`Gradle`](http://gradle.org) [`Maven 3.0.x`](https://maven.apache.org) [`Ant`](http://ant.apache.org) [`findbugs`](http://findbugs.sourceforge.net)

## iOS
* [`Xcode`](https://developer.apple.com/xcode/download/) [`xctool`](https://github.com/facebook/xctool) [`Cocoapods`](http://cocoapods.org) [`Carthage`](https://github.com/Carthage/Carthage)
* [Fastlane](https://fastlane.tools) bundle: [`fastlane`](https://github.com/fastlane/fastlane) [`deliver`](https://github.com/fastlane/deliver) [`snapshot`](https://github.com/fastlane/snapshot) [`frameit`](https://github.com/fastlane/frameit) [`pem`](https://github.com/fastlane/pem) [`sigh`](https://github.com/fastlane/sigh) [`produce`](https://github.com/fastlane/produce) [`cert`](https://github.com/fastlane/cert) [`codes`](https://github.com/fastlane/codes) [`spaceship`](https://github.com/fastlane/spaceship) [`pilot`](https://github.com/fastlane/pilot) [`gym`](https://github.com/fastlane/gym) [`match`](https://github.com/fastlane/match)
* [nomad-cli](http://nomad-cli.com) bundle: [`ios`](https://github.com/nomad/Cupertino) [`apn`](https://github.com/nomad/Houston) [`pk`](https://github.com/nomad/Dubai) [`iap`](https://github.com/nomad/Venice) [`ipa`](https://github.com/nomad/Shenzhen)
* Code quality tools: [`oclint`](http://oclint.org) [`lcov`](http://ltp.sourceforge.net/coverage/lcov.php) [`gcovr`](http://gcovr.com) [`slather`](https://github.com/venmo/slather) [`cloc`](http://cloc.sourceforge.net) [`swiftlint`](https://github.com/realm/SwiftLint)
* XCTest utilities: [`ocunit2junit`](https://github.com/ciryon/OCUnit2JUnit)  [`xcpretty`](https://github.com/supermarin/xcpretty)
* Simulator utility: [`ios-sim`](https://github.com/phonegap/ios-sim)
* Other utilities: [`synx`](https://github.com/venmo/synx) [`splunk-mobile-upload`](https://github.com/xfreebird/splunk-mobile-upload) [`nexus-upload`](https://github.com/xfreebird/nexus-upload) [`crashlytics-upload-ipa`](https://github.com/xfreebird/crashlytics-upload-ipa) [`iosbuilder`](https://github.com/xfreebird/iosbuilder)

## UI Automation

* [`Appium`](http://appium.io) [`Calabash`](http://calaba.sh)

## Web based frameworks

* [`Phonegap`](http://phonegap.com) [`Cordova`](http://cordova.apache.org)

## Other tools
* [`brew`](http://brew.sh) [`rbenv`](https://github.com/sstephenson/rbenv) [`jenv`](https://github.com/gcuisinier/jenv) [`Go`](https://golang.org) [`Node.js`](https://nodejs.org/en/)
* [`JDK 7`](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)[`JDK 8`](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
* [`Sonar runner`](https://github.com/SonarSource/sonar-runner)
* [`xcode-install`](https://github.com/neonichu/xcode-install)

# Upgrading installed software


To update installed software you can use the ```mobile-dev-update``` utility. By default it will update the ```OSX```, ```Xcode```, ```Android SDK Componets```, ```Ruby packages```, ```Brew packages```, ```NPM packages```, ```PHP packages```.

```shell
mobile-dev-update
```

Or if you need to update specific component:

```bash
mobile-dev-update xcode
```

Available options are:
* ```osx``` - Updates the OSX.
* ```xcode``` - Installs the latest Xcode.
* ```android``` - Updates installed Android SDK
* ```brew``` - Updates installed brew packages
* ```cask``` - Updates installed Brew casks (e.g. java, java7, oclint)
* ```gem``` - Updates installed Ruby gems
* ```npm``` - Updates installed npm packages
* ```php``` - Updates installed php packages.

## Java enviroment

The Java environment is controlled by ```jenv```.

To get current java versions:
```shell
jenv version
```

To list installed java versions:
```shell
jenv versions
```

To change default java version:
```shell
jenv global 1.8
```

To change shell session default java version:
```shell
jenv shell 1.8
```

## Upgrading manually

In case you prefer upgrading the software manually.

### Android SDK

Install all updates:

```shell
packages=""
for package in $(android list sdk --no-ui | \
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

( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | android update sdk --no-ui --filter "$packages"
```

### Xcode

All installed Xcodes are following the ```Xcode-<version>.app``` naming convention.
The ```/Applications/Xcode.app``` is a symbolic link to the current default Xcode.

To install a new version of Xcode use ```xcode-install```:

```shell
export XCODE_INSTALL_USER="apple.developer@gmail.com"
XCODE_INSTALL_PASSWORD="secret"
xcversion install 7.1
sudo xcodebuild -license accept
```

### Brew packages

Update all packages:

```shell
brew update
brew upgrade
```

⚠️ Warning: If ```android-sdk``` was updated also run the steps from the ```Android SDK```.

### Brew Cask packages

Update all packages:

```shell
  brew update
  brew upgrade brew-cask
  brew cask update
```

### Gem packages

⚠️ Don't use ```sudo``` when updating Ruby packages, because we are using [`rbenv`](https://github.com/sstephenson/rbenv).
Update all packages:

```shell
gem update -p
```

⚠️ Temporary [fix for cocoapods](https://github.com/CocoaPods/CocoaPods/issues/2908)

```shell
gem uninstall psych --all
gem install psych -v 2.0.0
```

### Npm packages

Update all packages:

```shell
npm update -g
```
