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
export PASSWORD="osx_user_password"
export APPLE_USERNAME="apple.developer@mail.com"
export APPLE_PASSWORD="secret"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/xfreebird/mobile-dev-bootstrap/master/mobile-dev-bootstrap.sh)"
```

At the end you will have:

* **Android** and **iOS** 📱 developemnt ready environment


# Why ?

**To save time**

# What do you get ?

OS X optimised mobile Android and iOS development.

## Android
* Latest [`Android SDK`](https://developer.android.com/sdk/index.html) and [`NDK`](https://developer.android.com/ndk/index.html) with build tools, emulators etc.
* [`Gradle`](http://gradle.org)
* [`Maven 3.0.x`](https://maven.apache.org)
* [`Ant`](http://ant.apache.org)
* [`findbugs`](http://findbugs.sourceforge.net)

## iOS
* Latest [Xcode](https://developer.apple.com/xcode/download/)
* [`xctool`](https://github.com/facebook/xctool)
* [fastlane](https://github.com/KrauseFx/fastlane) bundle [`fastlane`](https://github.com/KrauseFx/fastlane) [`deliver`](https://github.com/KrauseFx/deliver) [`snapshot`](https://github.com/KrauseFx/snapshot) [`frameit`](https://github.com/fastlane/frameit) [`pem`](https://github.com/fastlane/PEM) [`sigh`](https://github.com/KrauseFx/sigh) [`produce`](https://github.com/fastlane/produce) [`cert`](https://github.com/fastlane/cert) [`codes`](https://github.com/fastlane/codes) [`spaceship`](https://github.com/fastlane/spaceship) [`pilot`](https://github.com/fastlane/pilot) [`gym`](https://github.com/fastlane/gym)
* [nomad-cli](http://nomad-cli.com) bundle [`ios`](https://github.com/nomad/Cupertino) [`apn`](https://github.com/nomad/Houston) [`pk`](https://github.com/nomad/Dubai) [`iap`](https://github.com/nomad/Venice) [`ipa`](https://github.com/nomad/Shenzhen)
* Dependency management tools [`Cocoapods`](http://cocoapods.org) and [`Carthage`](https://github.com/Carthage/Carthage)
* Code quality tools [`oclint`](http://oclint.org) [`lcov`](http://ltp.sourceforge.net/coverage/lcov.php) [`gcovr`](http://gcovr.com) [`slather`](https://github.com/venmo/slather) [`cloc`](http://cloc.sourceforge.net) [`swiftlint`](https://github.com/realm/SwiftLint)
* XCTest utilities [`ocunit2junit`](https://github.com/ciryon/OCUnit2JUnit)  [`xcpretty`](https://github.com/supermarin/xcpretty) 
* Simulator utility [`ios-sim`](https://github.com/phonegap/ios-sim)
* Other utilities [`splunk-mobile-upload`](https://github.com/xfreebird/splunk-mobile-upload) [`nexus-upload`](https://github.com/xfreebird/nexus-upload) [`crashlytics-upload-ipa`](https://github.com/xfreebird/crashlytics-upload-ipa) [`iosbuilder`](https://github.com/xfreebird/iosbuilder)

## UI Automation

* [`Appium`](http://appium.io)
* [`Calabash`](http://calaba.sh)

## Web based frameworks

* [`Phonegap`](http://phonegap.com)
* [`Cordova`](http://cordova.apache.org)

## Other tools
* [`brew`](http://brew.sh)
* [`rbenv`](https://github.com/sstephenson/rbenv)
* [`Node.js`](https://nodejs.org/en/)
* [`Go`](https://golang.org)
* [`JDK 7`](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html)
* [`JDK 8`](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
* [`xcode-install`](https://github.com/neonichu/xcode-install)
* [`Sonar runner`](https://github.com/SonarSource/sonar-runner)


# Upgrading installed software

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
xcode-install install 7.1
sudo xcodebuild -license accept
```

### Brew packages

Update all packages:

```shell
brew update
brew upgrade
```

⚠️ Warning: If ```android-sdk``` was updated also run the steps from the ```Android SDK```.

### Gem packages

⚠️ Don't use ```sudo``` when updating Ruby packages, because we are using [`rbenv`](https://github.com/sstephenson/rbenv).
Update all packages:

```shell
gem update -p
```

### Npm packages

Update all packages:

```shell
npm update -g
```

