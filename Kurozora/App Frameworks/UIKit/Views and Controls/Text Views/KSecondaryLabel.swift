//
//  KSecondaryLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A themed view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.
///
/// The color of the labels is pre-configured with the currently selected theme's secondary text color.
/// You can add labels to your interface programmatically or by using Interface Builder.
class KSecondaryLabel: UILabel {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the label.
	func sharedInit() {
		self.theme_textColor = KThemePicker.subTextColor.rawValue
	}
}
