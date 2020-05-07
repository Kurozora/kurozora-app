//
//  SeparatorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	An object that manages the content for a rectangular area on the screen.

	Views are the fundamental building blocks of your app's user interface, and the `SeparatorView` class defines the behaviors that are common to separators.
	A view object renders content within its bounds rectangle and handles any interactions with that content. However, the `SeparatorView` class is a concrete class that you can only instantiate and use to display a separator view.
*/
class SeparatorView: UIView {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Fucntions
	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.theme_backgroundColor = KThemePicker.separatorColor.rawValue
	}
}
