//
//  UIImageView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
	// MARK: - Functions
	/// Sets up the image view with the given image url and placeholder. The downloaded image is also saved in the cache storage, so subsequent requests will load from the cache if the image is found.
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
				.set(to: self)
		} else {
			self.image = placeholder.withRenderingMode(.alwaysOriginal)
		}
	}
}
