//
//  SecondarySeparatorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// An object that manages the content for a rectangular area on the screen.
///
/// Views are the fundamental building blocks of your app's user interface, and the `SecondarySeparatorView` class defines the behaviors that are common to inter-item separators.
/// A view object renders content within its bounds rectangle and handles any interactions with that content. However, the `SecondarySeparatorView` class is a concrete class that you can only instantiate and use to display an inter-item separator view.
class SecondarySeparatorView: UIView {
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
		self.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
	}
}
