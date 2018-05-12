//
//  NewMessageController.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 11.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    let cellId = "cellId"
    
    var users = [UserData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
                let user = UserData()
                // user.setValuesForKeys(dict)
                // ^^^ this class is not key value coding-compliant for the key name.'

                user.name = dict["name"] as? String
                user.email = dict["email"] as? String
                user.profileImageUrl = dict["profileImageUrl"] as? String
                self.users.append(user)
                
                self.tableView.reloadData()
                
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.tableView.reloadData()
//                })
//                  ^^^ Brian says this should be dispatched ... could not find the swift 4 equivalent
            }
        })
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.imageView?.image = UIImage(named: "venetian500x500") // default
        
        if let profileImageUrl = user.profileImageUrl {
            let url = NSURL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data!)
                }
            }).resume()
        }
        
        return cell
    }
}

class UserCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
