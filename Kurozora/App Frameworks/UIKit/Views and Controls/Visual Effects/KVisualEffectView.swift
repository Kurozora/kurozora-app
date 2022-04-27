//
//  KVisualEffectView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A themed object that implements some complex visual effects.
///
/// Depending on the desired effect, the effect may affect content layered behind the view or content added to the visual effect view’s contentView. Apply a visual effect view to an existing view and then apply a UIBlurEffect or UIVibrancyEffect object to apply a blur or vibrancy effect to the existing view. After you add the visual effect view to the view hierarchy, add any subviews to the contentView property of the visual effect view. Do not add subviews directly to the visual effect view itself.
class KVisualEffectView: UIVisualEffectView {
	// MARK: - Initializers
	override init(effect: UIVisualEffect?) {
		super.init(effect: effect)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the visual effect view.
	func sharedInit() {
		// Configure properties
		self.theme_effect = KThemePicker.visualEffect.effectValue()
		self.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
	}
}
