//
//  User.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 11.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit
import Firebase

@objcMembers class UserData: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
}

@objcMembers class Message: NSObject {
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?

    func chatPartnerId() -> String? {
        return self.fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
