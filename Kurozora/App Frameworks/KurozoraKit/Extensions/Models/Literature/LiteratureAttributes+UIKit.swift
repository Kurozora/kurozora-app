//
//  LiteratureAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit

extension Literature.Attributes {
	// MARK: - Properties
	/// Returns a string containing all the necessary information of a literature. If one of the informations is missing then that particular part is ommitted.
	///
	/// ```
	/// "Manga · R15+ · 25 volumes · 25 minutes · Spring 2016"
	/// ```
	var informationString: String {
		var informationString = "\(self.type.name) · \(self.tvRating.name)"

		// Add the episode count
		if self.volumeCount != 0 {
			informationString += " · \(self.volumeCount) \(self.volumeCount == 1 ? "volume" : "volumes")"
		}

		// Add the duration
		informationString += " · \(self.duration)"

		// Add the year
		if let publicationYear = self.startedAt?.year {
			informationString += " · "
			if let publicationSeason = self.publicationSeason {
				informationString += "\(publicationSeason) "
			}
			informationString += "\(publicationYear)"
		}

		return informationString
	}

	/// Returns a short version of the literature information. If one of the informations is missing then that particular part is ommitted.
	///
	/// ```
	/// "TV · ✓ 10/25 · ☆ 5"
	/// ```
	var informationStringShort: String {
		var informationString = ""
		informationString += "\(self.type.name)"

//		if let watchedEpisodesCount = self.watchedEpisodesCount {
//			informationString += " · ✓ \(watchedEpisodesCount)/\(self.episodeCount)"
//		}

		if let givenRating = self.givenRating {
			informationString += " · ☆ \(givenRating)"
		}

		return informationString
	}

	/// Returns the date the literature will be published on.
	var publicationDate: Date? {
		guard let publicationDay = self.publicationDay, let publicationTime = publicationTime else { return nil }
		return Date(from: "\(publicationDay) at \(publicationTime)")
	}

	// MARK: - Functions
	/// Set the poster.
	///
	/// If the literature has no poster image, then a placeholder literature poster image is returned.
	///
	/// - Parameter imageView: The image view on which to set the poster image.
	func posterImage(imageView: UIImageView) {
		let placeholderImage = R.image.placeholders.showPoster()!
		imageView.setImage(with: self.poster?.url ?? "", placeholder: placeholderImage)
	}

	/// Set the banner.
	///
	/// If the literature has no banner image, then a placeholder literature banner image is returned.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
		let placeholderImage = R.image.placeholders.showBanner()!
		imageView.setImage(with: self.banner?.url ?? self.poster?.url ?? "", placeholder: placeholderImage)
	}
}
