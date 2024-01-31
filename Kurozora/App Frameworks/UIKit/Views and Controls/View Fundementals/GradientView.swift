//
//  GradientView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

/// A UIView subclass that displays a gradient background using Core Animation's CAGradientLayer.
class GradientView: UIView {
	// MARK: - Properties
	/// The gradient layer used to render the gradient background.
	lazy var gradientLayer: CAGradientLayer? = {
		return self.layer as? CAGradientLayer
	}()

	/// Overrides the default layer class to use CAGradientLayer.
	override open class var layerClass: AnyClass {
		return CAGradientLayer.classForCoder()
	}

	/// The view's background colors.
	var backgroundColors: [Any]? {
		get {
			return self.gradientLayer?.colors
		}
		set {
			self.gradientLayer?.colors = newValue
		}
	}
}
