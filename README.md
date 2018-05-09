# my_gameofchats

Built while following the video course series [Firebase Chat Messenger](https://www.letsbuildthatapp.com/course/Firebase-Chat-Messenger) by [Brian Voong](https://www.linkedin.com/in/brian-voong-2ba171a/) of [LetsBuildThatApp](https://www.letsbuildthatapp.com/) fame.

### Ep 1 - How to Build a Login Page Using iOS9 Constraint Anchors

Brian teaches how to build an initial login page, skipping the .storyboard and writing swift 3 code instead.

- to disable Main.storyboard: in **Target - Deployment Info - Main Interface**, replace *Main* by a blank line.

XCode 9 is mostly helpful in making changes from swift 3 to swift 4.

### Ep 2 - Installing SDK using Cocoapods and Saving Users into Database

Create the Firepase project:
- in [Firebase console](https://console.firebase.google.com/), **Add project** *my_gameofchats*
- get bundle ID *rudifa.my-gameofchats* from the project **Target - Identity - Bundle Identifier**
- paste it into the dialog **Add Firebase to your iOS app - iOS bundle ID**
- **Register the App**
- download the *GoogleService-Info.plist*
- copy it into the project

Install Pods for Firebase SDK into the project:
- in project directory, open terminal and run ```pod init```
- add to Podfile
```
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
```
- run ```pod install```
- close XCode, then open ```my_gameofchats.xcworkspace``` fron now on
