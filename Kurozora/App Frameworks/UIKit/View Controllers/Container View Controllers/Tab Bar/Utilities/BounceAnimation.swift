//
//  BounceAnimation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class BounceAnimation: BasicTabBarItemContentView {
	// MARK: - Properties
	var duration = 0.3

	// MARK: - Functions
	override func selectAnimation(animated: Bool, completion: (() -> Void)?) {
		self.bounceAnimation()
		completion?()
	}

	override func reselectAnimation(animated: Bool, completion: (() -> Void)?) {
		self.bounceAnimation()
		completion?()
	}

	/// The bounce animation to run when a tab bar item is selected.
	func bounceAnimation() {
		let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
		impliesAnimation.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
		impliesAnimation.duration = duration * 2
		impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
		imageView.layer.add(impliesAnimation, forKey: nil)
	}
}
