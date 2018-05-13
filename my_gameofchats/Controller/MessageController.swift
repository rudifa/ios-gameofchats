//
//  ViewController.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 09.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Not using the storyboard - create the accessories.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))

//        checkIfUserIsLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserIsLoggedIn()
    }

    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetNavbarTitle()
        }
    }
    
    func fetchUserAndSetNavbarTitle() {
        // get user info
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dict["name"] as? String
            }
        }, withCancel: nil)

    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
}

