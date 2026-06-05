//
//  KLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

/// A themed view that displays one or more lines of read-only text, often used in conjunction with controls to describe their intended purpose.
///
/// The color of the labels is pre-configured with the currently selected theme.
/// You can add labels to your interface programmatically or by using Interface Builder.
class KLabel: UILabel {
	// MARK: - Properties
	override var text: String? {
		didSet {
			self.registerLocalizationBinding(forKey: "text", assignedValue: self.text) { [weak self] value in
				self?.text = value
			}
		}
	}

	override var accessibilityLabel: String? {
		didSet {
			self.registerLocalizationBinding(forKey: "accessibilityLabel", assignedValue: self.accessibilityLabel) { [weak self] value in
				self?.accessibilityLabel = value
			}
		}
	}

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
		self.theme_textColor = KThemePicker.textColor.rawValue
	}
}
