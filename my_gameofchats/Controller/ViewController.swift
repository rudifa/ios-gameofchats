//
//  ViewController.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 09.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Not using the storyboard - create the accessories.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }

    @objc func handleLogout() {
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
}

