//
//  KActivityIndicatorView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A themed view that shows that a task is in progress.

	You control when an activity indicator animates by setting the `prefersHidden` property to true, and to stop animating you set `prefersHidden` to false. The activity indicator is automatically hidden when animation stops.
*/
class KActivityIndicatorView: UIActivityIndicatorView {
	// MARK: - Properties
	/// Indicates whether the activity indicator is hidden or visible.
	var prefersHidden: Bool = false {
		didSet {
			if prefersHidden {
				self.stopAnimating()
			} else {
				self.startAnimating()
			}
		}
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	override init(style: UIActivityIndicatorView.Style) {
		super.init(style: style)
		self.sharedInit()
	}

	required init(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the activity indicator.
	private func sharedInit() {
		// Configure activity indicator view.
		if #available(iOS 13.0, *) {
			self.style = .large
		}
		self.theme_color = KThemePicker.tintColor.rawValue
		self.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin]
		self.hidesWhenStopped = true
	}
}
