//
//  LoginController+Handlers.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 11.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleTest() {
        print("Testing...")
        let name = "Fred Q"
        let email = "Fred@Q.com"
        let password = "Freddie"
        Auth.auth().signIn(withEmail: email, password: password) {
            (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            let uid = Auth.auth().currentUser?.uid
            print("user:", uid!)
            
            // upload image to storage, get its url and add user to users
            let storageRef = Storage.storage().reference().child("myImage.png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print(metadata!)
                    
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting download URL: \(error)")
                            return
                        }
                        print("URL:", url?.absoluteString as Any)
                        let values = ["name": name, "email": email, "profileImageUrl": url?.absoluteString]
                        self.registerUserIntoDatabase(uid: uid!, values: values as [String : AnyObject])
                    }
                })
            }

            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        print("Registration ...")
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            print("*** Registration form is incomplete.")
            return
        }
        
        // register user with the Firebase project admin
        Auth.auth().createUser(withEmail: email, password: password) { (user: User?, error) in
            if error != nil {
                print(error!)
                return
            }
            
            // get user id
            guard let uid = user?.uid else {
                print("*** Failed to get user uid.")
                return
            }
            print("User registered successfully:", uid)

            // upload image to storage, get its url and add user to users
            let imageName = NSUUID().uuidString + ".jpg"
            let storageRef = Storage.storage().reference().child("profile_images").child(imageName)

            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
//                    print(metadata!)
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting download URL: \(error)")
                            return
                        }
                        let profileImageUrl = url?.absoluteString
                        print("profileImageUrl:", profileImageUrl as Any)
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDatabase(uid: uid, values: values as [String : AnyObject])
                    }
               })
            }
        }
    }
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]) {
        // add user to the list of users in our database
        let ref = Database.database().reference(fromURL: self.databaseUrl)
        let userRef = ref.child("users").child(uid)
        userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "")
                return
            }
            print("User added to users.")
            
            self.messageController?.navigationItem.title = values["name"] as? String
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print((editedImage).size)
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"]  as? UIImage {
            print((originalImage).size)
            selectedImage = originalImage
        }
        if let selected = selectedImage {
            profileImageView.image = selected
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
