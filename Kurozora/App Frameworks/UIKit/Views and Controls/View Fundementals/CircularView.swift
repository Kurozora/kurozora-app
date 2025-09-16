//
//  CircularView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// An object that manages the content for a circular area on the screen.
///
/// Views are the fundamental building blocks of your app's user interface, and the `CircularView` class defines the behaviors that are common to all views.
/// A view object renders content within its bounds circle and handles any interactions with that content. The `CircularView` class is a concrete class that you can instantiate and use to display a fixed background color.
/// You can also subclass it to draw more sophisticated content.
class CircularView: UIView {
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
	private func sharedInit() {
		self.layerCornerRadius = self.frame.size.height / 2
	}
}
