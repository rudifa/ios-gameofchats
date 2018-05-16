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

    let cellId = "cellId"

    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Not using the storyboard - create the accessories.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))

        checkIfUserIsLoggedIn()

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        observeMessages()

    }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MessageController.viewWillAppear")
        checkIfUserIsLoggedIn()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        let message = messages[indexPath.row]

        if let toId = message.toId {
            let ref = Database.database().reference().child("users").child(toId)
            ref.observe(.value, with: {
                (snapshot) in
//                print(snapshot)
                if let dict = snapshot.value as? [String: AnyObject] {
                    cell.textLabel?.text = dict["name"] as? String
                }
            })
        }
//        cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        return cell
    }

    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        print("MessageController.checkIfUserIsLoggedIn")
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetNavbarTitle()
        }
    }
    
    func fetchUserAndSetNavbarTitle() {
        print("MessageController.fetchUserAndSetNavbarTitle")
        // get user info
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
//                self.navigationItem.title = dict["name"] as? String

                let user = UserData()
                user.setValuesForKeys(dict)
                self.setupNavbarWith(user: user)
            }
        }, withCancel: nil)
    }

    func setupNavbarWith(user: UserData) {
        print("MessageController.setupNavbarWith")

        let titleView = UIView()
        self.navigationItem.titleView = titleView
        titleView.frame = CGRect(x:0, y:0, width: 100, height: 40)
//        titleView.backgroundColor = UIColor.red


        let containerView = UIView()
        titleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = UIColor.orange

        // x, y constraints
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        let profileImageView = UIImageView()
        containerView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageCachingFrom(imageUrl: profileImageUrl)
        }
        // x, y, width, height constraints
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true


        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        //        nameLabel.backgroundColor = UIColor.orange

        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // x, y, width, height constraints
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        // the tap works and the red background is present : when coming from register or login, or from edit/cancel
        // the tap does not work and the red background is missing : when comming from tap/back
        // WHY?

//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatLogControllerFor)))
        DispatchQueue.main.async {
            self.navigationItem.titleView?.printSubviews()
        }
    }

    @objc func showChatLogControllerFor(user: UserData) {
        print("showChatLogController")
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
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

