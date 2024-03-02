//
//  KLinkView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import LinkPresentation

/// A themed rich visual representation of a link.
///
/// The color of the link view is pre-configured with the currently selected theme.
/// You can add link views to your interface programmatically.
class KLinkView: LPLinkView {
	// MARK: - Properties
	/// A Boolean value that indicates whether the view has already been laid out.
	private var didLayoutSubviewsOnce: Bool = false

	// MARK: - Initializers
	override init(url: URL) {
		super.init(url: url)
	}

	override init(metadata: LPLinkMetadata) {
		super.init(metadata: metadata)

		self.sharedInit()
	}

	// MARK: - Views
	override func layoutSubviews() {
		super.layoutSubviews()
		guard !self.didLayoutSubviewsOnce else { return }

		self.recursivelyChangeBackgroundColor(in: self)
		self.didLayoutSubviewsOnce = true
	}

	// MARK: - Functions
	/// The shared settings used to initialize the link view.
	private func sharedInit() {
		self.recursivelyChangeBackgroundColor(in: self)
	}

	/// Recursively changes the background color of the subviews to the desired color.
	///
	/// - Parameters:
	///    - view: The view whose subviews' background colors will be changed.
	private func recursivelyChangeBackgroundColor(in view: UIView) {
		for subview in view.subviews {
			if let backgroundColor = subview.backgroundColor, backgroundColor != .clear {
				subview.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
			}

			self.recursivelyChangeBackgroundColor(in: subview)
		}
	}
}
