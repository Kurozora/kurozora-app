//
//  KView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

/// A themed object that manages the content for a rectangular area on the screen.
class KView: UIView {
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
	/// The shared settings used to initialize the view.
	func sharedInit() {
		self.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}
}
