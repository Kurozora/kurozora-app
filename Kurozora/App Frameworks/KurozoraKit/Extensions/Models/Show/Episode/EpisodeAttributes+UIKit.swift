//
//  EpisodeAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/12/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit

extension Episode.Attributes {
	/// Set the poster.
	///
	/// If the episode has no poster image, then a placeholder episode poster image is ysed.
	///
	/// - Parameter imageView: The image view on which to set the poster image.
	func posterImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.showPoster() else { return }
		imageView.setImage(with: self.poster?.url ?? "", placeholder: placeholderImage)
	}

	/// Set the banner.
	///
	/// If the episode has no banner image, then a placeholder episode banner image is ysed.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.episodeBanner() else { return }
		imageView.setImage(with: self.banner?.url ?? self.poster?.url ?? "", placeholder: placeholderImage)
	}
}
