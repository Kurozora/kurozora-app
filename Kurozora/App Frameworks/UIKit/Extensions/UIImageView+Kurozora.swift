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
	/**
		Sets up the image view with the given image url and placeholder. The downloaded image is also saved in the cache storage, so subsequent requests will load from the cache if the image is found.

		- Parameter urlString: The url string from where the image should be downloaded.
		- Parameter placeholder: The placeholder to show until the downloaded image is loaded or in case the url is dead.
	*/
	func setImage(with urlString: String, placeholder: UIImage, completionHandler: (() -> Void)? = nil) {
		if !urlString.isEmpty, let imageURL = URL(string: urlString) {
			let resource = ImageResource(downloadURL: imageURL, cacheKey: urlString)
			let options: KingfisherOptionsInfo = [.transition(.fade(0.2))]

			self.kf.indicatorType = .activity
			self.kf.setImage(with: resource, placeholder: placeholder, options: options, progressBlock: nil) { _ in
				completionHandler?()
			}
		} else {
			self.image = placeholder
		}
	}
}
