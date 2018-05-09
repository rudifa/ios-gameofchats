//
//  LoginController.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 09.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151, alpha: 1)
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}
