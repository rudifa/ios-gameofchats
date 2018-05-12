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
    
    func handleRegister() {
        print("Registration ...")
        guard let _ = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
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

            // upload image to storage
            let storageRef = Storage.storage().reference().child("myImage.png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print(metadata!)
                })
            } // end if
        } // end Auth
    } // end handleRegister
    
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
