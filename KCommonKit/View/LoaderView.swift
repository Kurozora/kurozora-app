//
//  LoaderView.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

public class LoaderView: UIView {
	let rectShape = CAShapeLayer()
	let diameter = 20

	var parentView: UIView!
	public var animating: Bool = false

	convenience public init(parentView: UIView) {
		self.init(frame: CGRect.zero)
		self.parentView = parentView
		configure()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func configure() {
		backgroundColor = UIColor.clear

		rectShape.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
		rectShape.position = CGPoint(x: CGFloat(diameter/2), y: CGFloat(diameter/2))
		rectShape.cornerRadius = bounds.width / 2
		rectShape.path = UIBezierPath(ovalIn: rectShape.bounds).cgPath
		rectShape.fillColor = UIColor.belizeHole().cgColor

		translatesAutoresizingMaskIntoConstraints = false

		parentView.addSubview(self)

		let viewsDictionary = ["view": self]
		let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:[view(\(diameter))]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
		let constraintV = NSLayoutConstraint.constraints(withVisualFormat: "V:[view(\(diameter))]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)

		parentView.addConstraints(constraintH)
		parentView.addConstraints(constraintV)

		parentView.addConstraint(
			NSLayoutConstraint(
				item: self,
				attribute: NSLayoutConstraint.Attribute.centerY,
				relatedBy: NSLayoutConstraint.Relation.equal,
				toItem: parentView,
				attribute: NSLayoutConstraint.Attribute.centerY,
				multiplier: 1.0,
				constant: 0.0)
		)

		parentView.addConstraint(
			NSLayoutConstraint(
				item: self,
				attribute: NSLayoutConstraint.Attribute.centerX,
				relatedBy: NSLayoutConstraint.Relation.equal,
				toItem: parentView,
				attribute: NSLayoutConstraint.Attribute.centerX,
				multiplier: 1.0,
				constant: 0.0)
		)

	}

	public func startAnimating() {

		if animating {
			return
		}

		animating = true
		let timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
		let animationDuration = 0.4

		let sizingAnimation = CABasicAnimation(keyPath: "transform.scale")
		sizingAnimation.fromValue = 1
		sizingAnimation.toValue = 2
		sizingAnimation.timingFunction = timingFunction
		sizingAnimation.duration = animationDuration

		let fadeOut = CABasicAnimation(keyPath: "opacity")
		fadeOut.fromValue = 1
		fadeOut.toValue = 0
		fadeOut.timingFunction = timingFunction
		fadeOut.duration = animationDuration - 0.1
		fadeOut.isRemovedOnCompletion = false
		fadeOut.fillMode = CAMediaTimingFillMode.forwards
		fadeOut.beginTime = 0.1

		let group = CAAnimationGroup()
		group.animations = [sizingAnimation, fadeOut]
		group.duration = animationDuration * 2.0
		group.repeatCount = HUGE

		layer.addSublayer(rectShape)
		rectShape.add(group, forKey: nil)

	}

	public func stopAnimating() {

		animating = false
		rectShape.removeAllAnimations()
		rectShape.removeFromSuperlayer()
	}

}
