//
//  Extensions.swift
//  my_gameofchats
//
//  Created by Rudolf Farkas on 13.05.18.
//  Copyright © 2018 Rudolf Farkas. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {

    func loadImageCachingFrom(imageUrl: String) {        
        self.image = nil
        if let image = imageCache.object(forKey: imageUrl as NSString) as? UIImage {
            self.image = image
            return
        }
        
        let url = NSURL(string: imageUrl)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: imageUrl as NSString)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
    
}


extension UIView {

    func printSubviews(indent: String = "") {
        print("\(indent)\(self)")
        let indent = indent + "| "
        for sub in self.subviews {
            sub.printSubviews(indent: indent)
        }
    }

}
