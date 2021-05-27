# PlatyPlus-app

## 1 setup the project

### 1.1 download the repo
- `git clone <app repo url>`

### 1.2 Copy dummy key.properties
- `cp extra/key.properties android/.`

### 1.3 setup flutter
follow the get started tutorial to install all the required applications
https://flutter.dev/docs/get-started/install

### 1.4 Run the android emulator from the terminal
- add the following environment variables to your config file (ex: `~/.zshrc` or `~/.bash_rc`)
  ```
  export ANDROID_SDK=$HOME/Library/Android/sdk
  export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$PATH
  ```
- reload the terminal to apply the changes of the config file.
- list the available emulators:
  `emulator -list-avds`
- run the emulator:
  `emulator -avd <device name>`

## 2 Forking
### 2.1 Create a fork
- navigate to a newly created git repo
- connect the original repo: `git remote add upstream git@github.com:Fluufff/Platyplus-app.git`

### 2.2 Sync master branch of fork
- git fetch upstream
- git checkout master
- git rebase upstream/master
- git push origin master

## 3 Rebrand the app

### 3.1 renaming
- change the label value at `android/app/src/main/AndroidManifest.xml:11` (changes the displayed name of the android app)
- change the `applicationId` value at `android/app/build.gradle:47` (changes the android package name)
- change the `CFBundleName` at `ios/Runner/Info.plist:14` (changes the displayed name of the iOS app)
- change the `CFBundleIdentifier` at `ios/Runner/Info.plist:10` (changes the iOS bundle name)

### 3.2 Changing the assets
- All assets can be replaced and are located in the `assets/` folder
- App icons need to be 900x900

### 3.3 generate app icons
After changing the app icon images, the following command needs to be runned before the icon of the app is changed
- `flutter packages pub run flutter_launcher_icons:main`

## 4 Deploy the app
- android: https://flutter.dev/docs/deployment/android
- ios: https://flutter.dev/docs/deployment/ios

