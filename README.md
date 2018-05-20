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
Problem:

```
if let dict = snapshot.value as? [String: AnyObject] {
    let user = UserData()
    // user.setValuesForKeys(dict)
    // ^^^ this class is not key value coding-compliant for the key name.'
    ...
```
*Later ...
Solution: prefix class with @objcMembers*
```
@objcMembers class UserData: NSObject {
```
Problem:

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

More importantly, the UIImagePickerControllerDelegate methods are not called.

However, downloaded gameofchats_05, built (after conversion to swift 4) - it works (picks and displays images)!

Added ```UINavigationControllerDelegate```in
```
extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
```
which fixed it.

*Next: upload image to the Firebase Storage.*

Getting there ... the completion handlers are asynchronous callbacks!


### Ep 6 - How to Load Images from Firebase Storage


[Meet the URLSession Family](https://cocoacasts.com/networking-in-swift-meet-the-urlsession-family) demonstrates the related methods, helps in converting from swift 3.

I had a problem with UserCell.profileImageView ... compiler did not recognize it as a property of UserCell() ... I must cast it to UserCell - I missed that in the video. Makes sense.

```
let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
```

Added caching of images in the app - removes the unnecessary network traffic.

Now storage, retrieval, caching and display of user images work.


### Ep 7 - Lets Fix some Bugs and Use JPEG Image Compression

Makes sure that the user name appears in the title bar.
Replaces PNG by low quality JPEG image - reduces storage space and load time.

Next: put the user image into the title bar.

Adding code in new ```func setupNavbarWith```

Something is not right, image is centered horizontally, title.View background is not red any more.

Added containerView, with image and nameLabel.


### Ep 8 - How to Send Messages

Revised ```func setupNavbarWith(user: UserData)```

Tap on user image or name in MessageView navbar works - presents the new ChatLogController.
Problem: on Back from ChatLogController, tap does not work (and the red background color of the titleView is lost temporarily); it works again after an Edit/Cancel.

Leaving that mystery open for now.

Added inputTextField + Send, sending messages to database

```
@objc func handleSend() {
    let ref = Database.database().reference().child("messages")
    let childRef = ref.childByAutoId()
    let values = ["text": inputTextField.text]
    childRef.updateChildValues(values as Any as! [AnyHashable : Any])
}
```


### Ep 9 - How to Load Messages

User opens Edit/newMassageController and selects another user.
This opens the ChatLogController, with the other user's name in the navbar title.

Added class Message, sending it to the database, retrieving from database and displaying them in the table view.

```
@objc func handleSend() {
    let ref = Database.database().reference().child("messages")
    let childRef = ref.childByAutoId()
    let toId = user?.id
    let fromId = Auth.auth().currentUser?.uid
    let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
    let values = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
    childRef.updateChildValues(values as Any as! [AnyHashable : Any])
}
```

```

    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dict)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
           }
        })
    }
```

### EP 10 - How to Group Messages Per User

It looks like we do not need to use the ```databaseUrl```explicitly in the code. If so, how does the Firebase code get it? Directly from the .plist?

```
//        let ref = Database.database().reference(fromURL: self.databaseUrl)
        let ref = Database.database().reference()
```

Moved code handling the profileImage into UserCell.

Modified observeMessages to display only the latest message from the current user to each user.

### Ep 11 - How to Reduce Cost and Support Multiple Users

Consider [Client-side fan-out](https://firebase.googleblog.com/2015/10/client-side-fan-out-for-data-consistency_73.html):

*Fan-out itself is the process duplicating data in the database. When data is duplicated it eliminates slow joins and increases read performance.
Multi-path updates allow the client to update several locations with one object. We call this client-side fan-out, because data is "fanned" across several locations.*

```
@objc func handleSend() {
    let ref = Database.database().reference().child("messages")
    let childRef = ref.childByAutoId() // create a messageId
    let toId = user?.id
    let fromId = Auth.auth().currentUser?.uid
    let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
    let values = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]

    // Store message values under "messages"/messageId
    childRef.updateChildValues(values as Any as! [AnyHashable : Any]) {
        (error, ref) in
        if error != nil { return }
        self.inputTextField.text = nil
        
        let messageId = childRef.key
        let senderMessagesRef = Database.database().reference().child("user-messages").child(fromId!)
        let recipientMessagesRef = Database.database().reference().child("user-messages").child(toId!)

        // Store messageId under "user-messages"/fromId
        senderMessagesRef.updateChildValues([messageId: 1]) // id of latest message from fromId

        // Store messageId under "user-messages"/toId
        recipientMessagesRef.updateChildValues([messageId: 1]) // id of latest message to toId
  }
}
```

So, under the node ```"user-messages"``` the app can look up ```messageId``` of all messages where a given user is either sender or receiver, then recover the actual message values (data) from the node ```"messages"```.

### Ep 12 - How to Load Entire Chat Log per User

In ChatLogController add ChatMessageCell and populate from the chat.

### EP 13 - How to Create Chat Bubbles using Constraints

Adds the bubbleView to the ChatMessageCell and adjusts its size to the message text.

### Ep 14 - Gray Chat Bubbles and Main Messages Bug Fix
