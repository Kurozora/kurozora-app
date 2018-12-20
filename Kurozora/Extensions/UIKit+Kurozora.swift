//
//  UIKit+Kurozora.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 04/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton: UIButton {
}

@IBDesignable class DesignableLabel: UILabel {
}

@IBDesignable class DesignableTextView: UITextView {
}

@IBDesignable class DesignableTableView: UITableViewCell {
}

@IBDesignable class DesignableView: UIView {
}

@IBDesignable class DesignableImageView: UIImageView {
    @IBInspectable var topLeftRadius : CGFloat = 0 {
        didSet {
            self.applyMask()
        }
    }

    @IBInspectable var topRightRadius : CGFloat = 0 {
        didSet {
            self.applyMask()
        }
    }
    @IBInspectable var bottomRightRadius : CGFloat = 0 {
        didSet {
            self.applyMask()
        }
    }

    @IBInspectable var bottomLeftRadius : CGFloat = 0 {
        didSet {
            self.applyMask()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyMask()
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    /*override func draw(_ rect: CGRect) {
     super.draw(rect)

     }*/

    func applyMask() {
        let shapeLayer = CAShapeLayer(layer: self.layer)
        shapeLayer.path = self.pathForCornersRounded(rect:self.bounds).cgPath
        shapeLayer.frame = self.bounds
        shapeLayer.masksToBounds = true
        self.layer.mask = shapeLayer
    }

    func pathForCornersRounded(rect:CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0 + topLeftRadius, y: 0))
        path.addLine(to: CGPoint(x: rect.size.width - topRightRadius , y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.size.width , y: topRightRadius), controlPoint: CGPoint(x: rect.size.width, y: 0))
        path.addLine(to: CGPoint(x: rect.size.width , y: rect.size.height - bottomRightRadius))
        path.addQuadCurve(to: CGPoint(x: rect.size.width - bottomRightRadius , y: rect.size.height), controlPoint: CGPoint(x: rect.size.width, y: rect.size.height))
        path.addLine(to: CGPoint(x: bottomLeftRadius , y: rect.size.height))
        path.addQuadCurve(to: CGPoint(x: 0 , y: rect.size.height - bottomLeftRadius), controlPoint: CGPoint(x: 0, y: rect.size.height))
        path.addLine(to: CGPoint(x: 0 , y: topLeftRadius))
        path.addQuadCurve(to: CGPoint(x: 0 + topLeftRadius , y: 0), controlPoint: CGPoint(x: 0, y: 0))
        path.close()

        return path
    }
}

@IBDesignable class DesignableTextField: UITextField {
//extension UITextField {
    //	Placeholder color
    @IBInspectable var placeholderColor: UIColor? {
		didSet {
			if (placeholderColor != nil) {
				self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[.foregroundColor: placeholderColor!])
			}
		}
    }

	//	TextField image
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }

    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }

    @IBInspectable var leftPadding: CGFloat = 5

    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }

    func updateView() {
        if let image = leftImage {
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = .never
            leftView = nil
        }
    }

	//	TextField padding
    var padding: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: 0, left: paddingValue, bottom: 0, right: paddingValue)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    @IBInspectable var paddingValue: CGFloat = 8
}

extension UIView {
	//	Border
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

	//	Corner
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

	//	Shadow
    @IBInspectable var shadowBackgroundColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    @IBInspectable var shadowBackgroundOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
}
