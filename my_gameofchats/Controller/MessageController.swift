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
    var messagesDictionary = [String: Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Not using the storyboard - create the accessories.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))

        checkIfUserIsLoggedIn()

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

//        observeMessages()

    }

    func observeUserMessages() {
        // here we display all messages from currentUser
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if let dict = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeys(dict)

                    if let toId = message.toId {
                        self.messagesDictionary[toId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                        })
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
           })
        }
    }

    func observeMessages() {
        // here we display all user messages
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.setValuesForKeys(dict)

                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                }

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

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.message = messages[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
//        print(message.text!, message.fromId!, message.toId!)
        guard let chatPartnerId = message.chatPartnerId() else { return }

        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
            guard let dict = snapshot.value as? [String: AnyObject] else { return}
            let user = UserData()
            user.id = chatPartnerId
            user.setValuesForKeys(dict)
            self.showChatLogControllerFor(user: user)
        })
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

        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()

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

