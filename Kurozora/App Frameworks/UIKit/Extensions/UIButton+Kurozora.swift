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
