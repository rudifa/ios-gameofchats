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
- close XCode, then open ```my_gameofchats.xcworkspace``` from now on

Add Firebase-related code to the project:
- in ```AppDelegate```: ```import Firebase``` and configure it.

Enable authentication:
- in Firebase Console - **Authentication - SET UP SIGN-IN METHOD - Email/Password - Enable**

Add registration code to the ```LoginController``` button:
```
let loginRegisterButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = UIColor(r: 100, g: 121, b: 181)
    button.setTitle("Register", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.translatesAutoresizingMaskIntoConstraints = false

    button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    return button
}()

@objc func handleRegister() {
    print("Registration ...")
    guard let email = emailTextField.text, let password = passwordTextField.text else {
        print("Registration form is incomplete.")
        return
    }

    Auth.auth().createUser(withEmail: email, password: password) {
        (user: User?, error) in
        if error != nil {
            print(error!)
            return
        }
        print("User registered successfully.")
    }
}
```

To test, register a user in the app
```
Fred
Fred@g.com
*******
```

User appears in the Firebase console **Authentication**

The app's database is [here](https://console.firebase.google.com/project/my-gameofchats/database/my-gameofchats/data) .

Before attempting to add data to the database, change **Database - RULES** to
```
// These rules require authentication
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```
otherwise permissions will be denied.

Expand the ```func handleRegister``` to add the user data to ```database/users```

### Ep3 - Logging in with Email and Password

Demonstrates more UI constraint manipulations in code
. add a SegmentedControl
. change the button text
. change vertical sizes of views

Handles Login vs. RegisterAndLogin

### Ep4 - How to Fetch Users from Database

Rename ViewController to MessageController (file and class)

Add class NewMessageController + UserData

Fetch user data from database and display in a custom UserCell, in the NewMessageController's tableView
```
Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in ...
```
Problems (workarounds found)

```
if let dict = snapshot.value as? [String: AnyObject] {
    let user = UserData()
    // user.setValuesForKeys(dict)
    // ^^^ this class is not key value coding-compliant for the key name.'
    ...
```
```
//  dispatch_async(dispatch_get_main_queue(), {
//      self.tableView.reloadData()
//  })
//  ^^^ Brian says this should be dispatched ...
// but I could not find the swift 4 equivalent

```

### Ep5 - How to Upload Images to Firebase Storage

Add tap gesture recognizer to the profile image view

```
lazy var profileImageView: UIImageView = { ...

  imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
  imageView.isUserInteractionEnabled = true

```

Can't make this to work
```
extension LoginController: UIImagePickerControllerDelegate {

    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        print("didFinishPickingMediaWithInfo", info)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
    }
}
```
fails with diagnostic:
```
2018-05-11 23:16:27.481247+0200 my_gameofchats[23729:17845021] [discovery] errors encountered while discovering extensions: Error Domain=PlugInKit Code=13 "query cancelled" UserInfo={NSLocalizedDescription=query cancelled}
```
--- in video at 9:30

However, downloaded gameofchats_05, built (after conversion to swift 4) - it works (picks and displays images)!

Added ```UINavigationControllerDelegate```in
```
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
```
