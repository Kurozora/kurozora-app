//
//  CircularButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// `CircularButton` is a specially crafted object that displays a circular button in your interface.
///
/// `CircularButton` adjusts some options to achieve its design, this includes:
/// - Applying a circular corner radius to the button.
class CircularButton: UIButton {
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		if #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0) {
			self.layerCornerRadius = self.frame.size.height / 2
		}
	}

	// MARK: - Functions
	/// The shared settings used to initialize the button.
	func sharedInit() {
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.configuration = self.configuration ?? .glass()
			self.configuration?.cornerStyle = .capsule
		}
	}
}
