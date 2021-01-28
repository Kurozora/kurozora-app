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
	/**
		Sets up the image view of the button with the given image url and placeholder. The downloaded image is also saved in the cache storage, so subsequent requests will load from the cache if the image is found.

		- Parameter urlString: The url string from where the image should be downloaded.
		- Parameter placeholder: The placeholder to show until the downloaded image is loaded or in case the url is dead.
	*/
	func setImage(with urlString: String, placeholder: UIImage) {
		if !urlString.isEmpty, let imageURL = URL(string: urlString) {
			KF.url(imageURL)
				.transition(.fade(0.2))
				.placeholder(placeholder)
				.loadDiskFileSynchronously()
				.cacheMemoryOnly()
				.lowDataModeSource(.network(imageURL))
				.onProgress { _, _ in } // receivedSize, totalSize
				.onSuccess { _ in } // result
				.onFailure { _ in } // error
				.set(to: self, for: .normal)
		} else {
			self.setImage(placeholder.original, for: .normal)
		}
	}
}
