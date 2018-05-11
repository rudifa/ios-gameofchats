//
//  LoginController+Handlers.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 11.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
