//
//  UIButton+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

extension UIButton {
	/// Creates a pill-shaped button with a system symbol icon.
	///
	/// - Parameters:
	///    - systemName: The SF Symbol name for the button icon.
	///    - accessibilityLabel: The accessibility label for the button.
	///    - target: The target object for the button action.
	///    - action: The selector to invoke when the button is tapped.
	///
	/// - Returns: A configured pill button.
	static func makePillButton(systemName: String, accessibilityLabel: String, target: Any?, action: Selector) -> UIButton {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let config = UIImage.SymbolConfiguration(textStyle: .callout).applying(UIImage.SymbolConfiguration(weight: .medium))
		button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
		button.theme_tintColor = KThemePicker.textColor.rawValue
		button.accessibilityLabel = accessibilityLabel
		button.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		button.layerCornerRadius = 22
		button.addTarget(target, action: action, for: .touchUpInside)
		return button
	}

	/// Creates a pill-shaped button with a text title.
	///
	/// - Parameters:
	///    - title: The text title for the button.
	///    - accessibilityLabel: The accessibility label for the button.
	///    - target: The target object for the button action.
	///    - action: The selector to invoke when the button is tapped.
	///
	/// - Returns: A configured pill button.
	static func makePillButton(title: String, accessibilityLabel: String, target: Any?, action: Selector) -> UIButton {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle(title, for: .normal)
		button.titleLabel?.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: .systemFont(ofSize: 14, weight: .semibold))
		button.titleLabel?.adjustsFontForContentSizeCategory = true
		button.theme_tintColor = KThemePicker.textColor.rawValue
		button.accessibilityLabel = accessibilityLabel
		button.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		button.layerCornerRadius = 22
		button.addTarget(target, action: action, for: .touchUpInside)
		return button
	}

	/// Sets up the image view of the button with the given image url and placeholder. The downloaded image is also saved in the cache storage, so subsequent requests will load from the cache if the image is found.
	///
	/// - Parameters:
	///    - urlString: The url string from where the image should be downloaded.
	///    - placeholder: The placeholder to show until the downloaded image is loaded or in case the url is dead.
	func setImage(with urlString: String, placeholder: UIImage) {
		if !urlString.isEmpty, let imageURL = URL(string: urlString) {
			KF.url(imageURL)
				.transition(.fade(0.2))
				.placeholder(placeholder)
				.loadDiskFileSynchronously()
				.lowDataModeSource(.network(imageURL))
				.onProgress { _, _ in } // receivedSize, totalSize
				.onSuccess { _ in } // result
				.onFailure { _ in } // error
				.set(to: self, for: .normal)
		} else {
			self.setImage(placeholder.withRenderingMode(.alwaysOriginal), for: .normal)
		}
	}

	/// Adds a blur effect to the button.
	///
	/// - Parameters:
	///    - style: The style of the blur view added to the button.
	///    - cornerRadius: The corner radius applied to the blur view.
	///    - padding: The padding between the blur view and the button's frame.
	func addBlurEffect(style: UIBlurEffect.Style = .regular, cornerRadius: CGFloat = 0, padding: CGFloat = 0) {
		self.backgroundColor = .clear
		let blurView = KVisualEffectView()
		blurView.isUserInteractionEnabled = false
		if cornerRadius > 0 {
			blurView.layerCornerRadius = cornerRadius
			blurView.layer.masksToBounds = true
		}
		self.insertSubview(blurView, at: 0)

		blurView.translatesAutoresizingMaskIntoConstraints = false
		self.leadingAnchor.constraint(equalTo: blurView.leadingAnchor, constant: padding).isActive = true
		self.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -padding).isActive = true
		self.topAnchor.constraint(equalTo: blurView.topAnchor, constant: padding).isActive = true
		self.bottomAnchor.constraint(equalTo: blurView.bottomAnchor, constant: -padding).isActive = true

		if let imageView = self.imageView {
			imageView.backgroundColor = .clear
			self.bringSubviewToFront(imageView)
		}
	}
}
