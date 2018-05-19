//
//  UserCell.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 16.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {

    var message : Message? {
        didSet {
            setupNameAndProfileImage()
        }
    }

    private func setupNameAndProfileImage() {

        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observe(.value, with: {
                (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dict["name"] as? String

                    if let profileImageUrl = dict["profileImageUrl"] as? String  {
                        self.profileImageView.loadImageCachingFrom(imageUrl: profileImageUrl)
                    }
                }
            })
        }
        detailTextLabel?.text = message?.text
        //            timeLabel.text = message?.timestamp?.stringValue
        if let seconds = message?.timestamp?.doubleValue {
            let timestampDate = NSDate(timeIntervalSince1970: seconds)
            timeLabel.text = timestampDate.description
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)

        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }

    // add custom imageView, for better control of appearance

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)
        addSubview(timeLabel)

        // x, y, width, height constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // x, y, width, height constraints
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


