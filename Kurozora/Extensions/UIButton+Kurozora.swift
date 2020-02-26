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
