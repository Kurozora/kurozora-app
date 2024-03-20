//
//  GameAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit

extension Game.Attributes {
	// MARK: - Properties
	/// Returns a string containing all the necessary information of a game. If one of the informations is missing then that particular part is ommitted.
	///
	/// ```
	/// "Manga · R15+ · 25 editions · 25 minutes · Spring 2016"
	/// ```
	var informationString: String {
		var informationString = "\(self.type.name) · \(self.tvRating.name)"

		// Add the episode count
		if self.editionCount != 0 {
			informationString += " · \(self.editionCount) \(self.editionCount == 1 ? "edition" : "editions")"
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

	/// Returns a short version of the game information. If one of the informations is missing then that particular part is ommitted.
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

		if let givenRating = self.library?.rating {
			informationString += " · ☆ \(givenRating)"
		}

		return informationString
	}

	/// Returns the date the game will be published on.
	var publicationDate: Date? {
		guard let publicationDay = self.publicationDay, let publicationTime = publicationTime else { return nil }
		return Date(from: "\(publicationDay) at \(publicationTime)")
	}

	// MARK: - Functions
	/// Set the poster.
	///
	/// If the game has no poster image, then a placeholder game poster image is used.
	///
	/// - Parameter imageView: The image view on which to set the poster image.
	func posterImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.showPoster() else { return }
		imageView.setImage(with: self.poster?.url ?? "", placeholder: placeholderImage)
	}

	/// Set the banner.
	///
	/// If the game has no banner image, then a placeholder game banner image is used.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.showBanner() else { return }
		imageView.setImage(with: self.banner?.url ?? self.poster?.url ?? "", placeholder: placeholderImage)
	}
}
