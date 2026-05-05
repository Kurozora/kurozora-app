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
	///    - urlString: The URL string from where the image should be downloaded.
	///    - placeholder: The placeholder to show until the image is loaded or in case the URL is dead.
	func setImage(with urlString: String, placeholder: UIImage) {
		guard !urlString.isEmpty, let imageURL = URL(string: urlString) else {
			self.image = placeholder.withRenderingMode(.alwaysOriginal)
			return
		}

		KF.url(imageURL)
			.transition(.fade(0.2))
			.lowDataModeSource(.network(imageURL))
			.onProgress { _, _ in }
			.onSuccess { _ in }
			.onFailure { [weak self] _ in
				guard let self else { return }
				self.image = placeholder.withRenderingMode(.alwaysOriginal)
			}
			.set(to: self)
	}

	/// Loads the image from the given URL string into this image view.
	///
	/// - Parameters:
	///    - urlString: The URL string from where the image should be downloaded.
	///    - placeholder: The placeholder to show until the image is loaded or in case the URL is dead.
	///    - faceDetectionContext: The media kind and CDN URL routed to `FaceDetectionService` on a successful load.
	func setImage(with urlString: String, placeholder: UIImage, faceDetectionContext: FaceDetectionContext) {
		guard !urlString.isEmpty, let imageURL = URL(string: urlString) else {
			self.image = placeholder.withRenderingMode(.alwaysOriginal)
			return
		}

		KF.url(imageURL)
			.transition(.fade(0.2))
			.lowDataModeSource(.network(imageURL))
			.onProgress { _, _ in }
			.onSuccess { result in
				#if DEBUG
				FaceDetectionService.shared.process(
					image: result.image,
					mediaURL: faceDetectionContext.mediaURL,
					kind: faceDetectionContext.kind
				)
				#endif
			}
			.onFailure { [weak self] _ in
				guard let self else { return }
				self.image = placeholder.withRenderingMode(.alwaysOriginal)
			}
			.set(to: self)
	}
}
