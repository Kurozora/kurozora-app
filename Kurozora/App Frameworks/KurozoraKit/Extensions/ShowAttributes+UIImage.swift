//
//  ShowAttributes+UIImage.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension Show.Attributes {
	/**
		Returns a `UIImage` with the poster.

		If the show has no poster image, then a placeholder show poster image is returned.
	*/
	var posterImage: UIImage? {
		let posterImageView = UIImageView()
		let placeholderImage = R.image.placeholders.showPoster()!
		posterImageView.setImage(with: self.poster?.url ?? "", placeholder: placeholderImage)
		return posterImageView.image?.withRenderingMode(.alwaysOriginal)
	}

	/**
		Returns a `UIImage` with the banner.

		If the show has no banner image, then a placeholder show banner image is returned.
	*/
	var bannerImage: UIImage? {
		let bannerImageView = UIImageView()
		let placeholderImage = R.image.placeholders.showBanner()!
		bannerImageView.setImage(with: self.banner?.url ?? "", placeholder: placeholderImage)
		return bannerImageView.image?.withRenderingMode(.alwaysOriginal)
	}
}
