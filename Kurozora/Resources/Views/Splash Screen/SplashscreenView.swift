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
		// Fade in and grow slightly
		Animation.shared.playAnimation(on: self.logoImageView, completion: completion)
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
