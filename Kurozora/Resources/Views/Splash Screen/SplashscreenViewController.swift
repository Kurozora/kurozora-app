//
//  SplashscreenViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

final class SplashscreenViewController: KViewController {
	// MARK: - Views
	private lazy var logoImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "kurozora_icon_monotone"))
		imageView.alpha = 0.0
		imageView.contentMode = .scaleToFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.theme_tintColor = KThemePicker.textColor.rawValue
		return imageView
	}()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.addSubview(self.logoImageView)

		NSLayoutConstraint.activate([
			self.logoImageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
			self.logoImageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
			self.logoImageView.widthAnchor.constraint(equalToConstant: 128.0),
			self.logoImageView.widthAnchor.constraint(equalTo: self.logoImageView.heightAnchor, multiplier: 21.0 / 22.0)
		])
	}

	// MARK: - Functions
	/// Plays the splash logo animation.
	///
	/// - Parameter completion: Called when the animation finishes, with a flag indicating success.
	func animateLogo(completion: ((Bool) -> Void)?) {
		Animation.shared.playAnimation(on: self.logoImageView, completion: completion)
	}
}
