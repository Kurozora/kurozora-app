//
//  EpisodeAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/12/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Episode.Attributes {
	// MARK: - Properties
	/// Returns a string containing all the necessary information of a show. If one of the informations is missing then that particular part is omitted.
	///
	/// ```swift
	/// "PG-12 · 50 minutes · S1E1 · April 4, 2016"
	/// ```
	var informationString: String {
		var informationString = "\(self.tvRating?.name ?? "PG-12") · \(self.duration)"

		// Add the season and episode number
		informationString += " · S\(self.seasonNumber)E\(self.number)"

		// Add the start date
		if let startedAt = self.startedAt {
			informationString += " · \(startedAt.formatted(.dateTime.month(.wide).day().year()))"
		}

		return informationString
	}

	// MARK: - Functions
	/// Set the poster.
	///
	/// If the episode has no poster image, then a placeholder episode poster image is ysed.
	///
	/// - Parameter imageView: The image view on which to set the poster image.
	func posterImage(imageView: UIImageView) {
        let placeholderImage = UIImage.Placeholders.showPoster
		imageView.setImage(with: self.poster?.url ?? "", placeholder: placeholderImage)
	}

	/// Set the banner.
	///
	/// If the episode has no banner image, then a placeholder episode banner image is ysed.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
        let placeholderImage = UIImage.Placeholders.episodeBanner
		imageView.setImage(with: self.banner?.url ?? self.poster?.url ?? "", placeholder: placeholderImage)
	}
}
