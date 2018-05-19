//
//  ChatLogController.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 14.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {

    let cellId = "cellId"

    var user: UserData? {
        didSet {
            navigationItem.title = user?.name

            observeMessages()
        }
    }

    var messages = [Message]()

    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
//            print(snapshot)
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot)
                guard let dict = snapshot.value as? [String: AnyObject] else { return }
                let message = Message()
                message.setValuesForKeys(dict)
                print(message.text!)
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            })

        })
    }

    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.title = "Chat Log"

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)

        setupInputComponents()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        return cell
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }

    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    func setupInputComponents() {

        let containerView = UIView()
        view.addSubview(containerView)
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        // x, y, width, height constraints
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let sendButton = UIButton(type: .system)
        containerView.addSubview(sendButton)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        // x, y, width, height constraints
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)
        // x, y, width, height constraints
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        containerView.addSubview(separatorLineView)
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }

    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId() // create a messageId
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(values as Any as! [AnyHashable : Any]) {
            (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.inputTextField.text = nil
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1]) // id of latest message from fromId

            let recipientMessagesRef = Database.database().reference().child("user-messages").child(toId!)
            recipientMessagesRef.updateChildValues([messageId: 1]) // id of latest message to toId
      }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
