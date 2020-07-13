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
		- Parameter cacheKey: The string referencing the image in the cache storage. If not specified, the `urlString` is used as the key.
		- Parameter placeholder: The placeholder to show until the downloaded image is loaded or in case the url is dead.
	*/
	func setImage(with urlString: String, cacheKey: String? = nil, placeholder: UIImage, completionHandler: (() -> Void)? = nil) {
		if !urlString.isEmpty, let imageURL = URL(string: urlString) {
			let resource = ImageResource(downloadURL: imageURL, cacheKey: cacheKey ?? urlString)
			var options: KingfisherOptionsInfo = [.transition(.fade(0.2))]

			if cacheKey != nil {
				options.append(contentsOf: [.memoryCacheExpiration(.never), .diskCacheExpiration(.never)])
			}

			self.kf.setImage(with: resource, for: .normal, placeholder: placeholder.original, options: options, progressBlock: nil) { _ in
				completionHandler?()
			}
		} else {
			self.setImage(placeholder.original, for: .normal)
		}
	}
}