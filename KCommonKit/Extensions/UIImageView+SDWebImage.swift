//
//  UIImageView+SDWebImage.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
//import SDWebImage

extension UIImageView {
    
//    public func setImageFrom(urlString:String!, animated:Bool = false, options: SDWebImageOptions? = nil) {
//        if let url = URL(string: urlString) {
//            if !animated {
//                if let options = options {
//                    self.sd_setImageWithURL(url, placeholderImage: nil, options: options)
//                } else {
//                    self.sd_setImageWithURL(url, placeholderImage: nil)
//                }
//            } else {
//                self.layer.removeAllAnimations()
//                self.sd_cancelCurrentImageLoad()
//
//                if let options = options {
//                    self.sd_setImageWithURL(url, placeholderImage: nil, options: options, completed: { (image, error, cacheType, url) -> Void in
//                        self.alpha = 0
//                        UIView.transitionWithView(self, duration: 0.5, options: [], animations: { () -> Void in
//                            self.image = image
//                            self.alpha = 1
//                        }, completion: nil)
//                    })
//                } else {
//                    self.sd_setImageWithURL(url, placeholderImage: nil, completed: { (image, error, cacheType, url) -> Void in
//                        self.alpha = 0
//                        UIView.transitionWithView(self, duration: 0.5, options: [], animations: { () -> Void in
//                            self.image = image
//                            self.alpha = 1
//                        }, completion: nil)
//                    })
//                }
//            }
//        }
//    }
}
