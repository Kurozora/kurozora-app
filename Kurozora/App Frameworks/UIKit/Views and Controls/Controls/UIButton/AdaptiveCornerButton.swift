//
//  AdaptiveCornerButton.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// `AdaptiveCornerButton` is a specially crafted object that displays a button with adaptive corners in your interface.
///
/// `AdaptiveCornerButton` adjusts some options to achieve its design, this includes:
/// - Applying a corner radius to the button.
class AdaptiveCornerButton: UIButton {
	enum CornerStyle {
		case capsule
		case fixed(_ cornerRadius: CGFloat)

		var cornerStyle: UIButton.Configuration.CornerStyle {
			switch self {
			case .capsule: return .capsule
			case .fixed: return .fixed
			}
		}
	}

	// MARK: - Properties
	var cornerStyle: CornerStyle = .capsule {
		didSet {
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.configureCornerRadius()
			} else {
				self.setNeedsLayout()
			}
		}
	}

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
			switch self.cornerStyle {
			case .capsule:
				self.layerCornerRadius = self.bounds.height / 2
			case .fixed(let radius):
				self.layerCornerRadius = radius
			}
		}
	}

	override func setImage(_ image: UIImage?, for state: UIControl.State) {
		if state == .normal, var configuration = self.configuration {
			configuration.image = image
			self.configuration = configuration
			return
		}

		super.setImage(image, for: state)
	}

	// MARK: - Functions
	/// The shared settings used to initialize the button.
	private func sharedInit() {
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.configuration = self.configuration ?? .glass()
			self.configureCornerRadius()
		}
	}

	@available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *)
	private func configureCornerRadius() {
		self.configuration?.cornerStyle = self.cornerStyle.cornerStyle

		switch self.cornerStyle {
		case .capsule: break
		case .fixed(let cornerRadius):
			self.configuration?.background.cornerRadius = cornerRadius
		}
	}
}
