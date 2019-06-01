//
//  UIView+Animation.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

extension UIView {
    public func animateFadeIn() {
        alpha = 0.0
        transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options:[UIView.AnimationOptions.allowUserInteraction, UIView.AnimationOptions.curveEaseOut], animations: { () -> Void in
            self.alpha = 1.0
            self.transform = .identity
        }, completion: nil)
    }
    
    public func animateFadeOut() {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.alpha = 0.0
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85)
        }, completion: nil)
    }
    
    public func animateBounce(growth: CGFloat = 1.25) {
        transform = .identity
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.transform = self.transform.scaledBy(x: growth, y: growth)
        }) { completion in
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: [.curveEaseIn, .allowUserInteraction], animations: { () -> Void in
                self.transform = .identity
            }, completion: nil)
        }
    }
}

