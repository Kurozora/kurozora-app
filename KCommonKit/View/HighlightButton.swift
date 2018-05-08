//
//  HighlightButton.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

class HighlightButton: UIButton {
    
    let rectShape = CAShapeLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTarget(self, action: #selector(buttonHighlight), for: .touchDown)
        addTarget(self, action: #selector(buttonNormal), for: .touchUpInside)
        addTarget(self, action: #selector(buttonNormal), for: .touchDragExit)
        addTarget(self, action: #selector(buttonHighlight), for: .touchDragEnter)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configure()
    }
    
    func configure() {
        rectShape.opacity = 0.5
        rectShape.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        rectShape.position = CGPoint(x: bounds.midX, y: bounds.midY)
        rectShape.cornerRadius = bounds.height / 2
        rectShape.path = UIBezierPath(ovalIn: rectShape.bounds).cgPath
        rectShape.fillColor = UIColor.midnightBlue().cgColor
    }
    
    @objc func buttonHighlight(sender: UIButton) {
        
        layer.insertSublayer(rectShape, at: 0)
        
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        let animationDuration = 0.25
        
        let sizingAnimation = CABasicAnimation(keyPath: "transform.scale")
        sizingAnimation.fromValue = 1
        sizingAnimation.toValue = 20
        sizingAnimation.timingFunction = timingFunction
        sizingAnimation.duration = animationDuration
        sizingAnimation.isRemovedOnCompletion = false
        sizingAnimation.fillMode = kCAFillModeForwards
        
        rectShape.add(sizingAnimation, forKey: nil)
    }
    
    @objc func buttonNormal(sender: UIButton) {
        
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        let animationDuration = 0.25
        
        let sizingAnimation = CABasicAnimation(keyPath: "transform.scale")
        sizingAnimation.fromValue = 20
        sizingAnimation.toValue = 0
        sizingAnimation.timingFunction = timingFunction
        sizingAnimation.duration = animationDuration
        sizingAnimation.isRemovedOnCompletion = false
        sizingAnimation.fillMode = kCAFillModeForwards
        
        rectShape.add(sizingAnimation, forKey: nil)
    }
    
    
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
