//
//  SplashscreenView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol SplashscreenViewDelegate: AnyObject {}

final class SplashscreenView: UIView {
	// MARK: - IBOutlets
	@IBOutlet private weak var logoImageView: UIImageView!

	// MARK: - Properties
	public weak var viewDelegate: SplashscreenViewDelegate?

	// MARK: - XIB loaded
	override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	// MARK: - Display
	func animateLogo(completion: ((Bool) -> Void)?) {
		// Start with the logo scaled down and transparent
		self.logoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		self.logoImageView.alpha = 0.0

		// Fade in and grow slightly
		UIView.animate(withDuration: 0.5, animations: { [weak self] in
			guard let self = self else { return }
			self.logoImageView.alpha = 1.0
			self.logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
		}) { _ in
			// Rotate slightly while scaling down
			UIView.animate(withDuration: 0.3, animations: { [weak self] in
				guard let self = self else { return }
				self.logoImageView.transform = CGAffineTransform(rotationAngle: .pi / 8).scaledBy(x: 1.0, y: 1.0)
			}) { _ in
				// Bounce back to original size and position
				UIView.animate(
					withDuration: 0.6,
					delay: 0.0,
					usingSpringWithDamping: 0.4,
					initialSpringVelocity: 0.7,
					options: [.curveEaseInOut],
					animations: { [weak self] in
						guard let self = self else { return }
						self.logoImageView.transform = .identity
					},
					completion: completion
				)
			}
		}
	}
}

// MARK: - Setup
private extension SplashscreenView {
	func setup() {
		self.setupViews()
	}

	// MARK: - View setup
	func setupViews() {
		self.setupView()
		self.setupLogoImageView()
	}

	func setupView() {
		self.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}

	func setupLogoImageView() {
		self.logoImageView.alpha = 0.0
		self.logoImageView.theme_tintColor = KThemePicker.textColor.rawValue
	}
}
