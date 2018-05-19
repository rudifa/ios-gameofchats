//
//  ChatMessageCell.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 19.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {

    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)

        // x, y, width, height constraints
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
