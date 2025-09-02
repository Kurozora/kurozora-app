//
//  ShowAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

extension Show.Attributes {
	// MARK: - Properties
	/// Returns a string containing all the necessary information of a show. If one of the informations is missing then that particular part is ommitted.
	///
	/// ```
	/// "TV · R15+ · 25 episodes · 25 minutes · Spring 2016"
	/// ```
	var informationString: String {
		var informationString = "\(self.type.name) · \(self.tvRating.name)"

		// Add the episode count
		if self.episodeCount != 0 {
			informationString += " · \(self.episodeCount) \(self.episodeCount == 1 ? "episode" : "episodes")"
		}

		// Add the duration
		informationString += " · \(self.duration)"

		// Add the year
		if let airYear = self.startedAt?.year {
			informationString += " · "
			if let airSeason = self.airSeason {
				informationString += "\(airSeason) "
			}
			informationString += "\(airYear)"
		}

		return informationString
	}

	/// Returns a short version of the shows information. If one of the informations is missing then that particular part is ommitted.
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

	/// A string describing when the show is next broadcasted.
	var broadcastString: String? {
		let date: Date?

		if let nextBroadcastAt = self.nextBroadcastAt {
			date = nextBroadcastAt
		} else if let airTime = self.airTime {
			date = self.startedAt?.settingTime(from: airTime)
		} else {
			date = self.startedAt
		}

		guard let broadcastAt = date else { return nil }
		let dateFormatter = DateFormatter.app
		dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")

		let timeString = DateFormatter.broadcastTime.string(from: broadcastAt)
		let weekdayString = dateFormatter.string(from: broadcastAt)

		return "\(weekdayString) at \(timeString)"
	}

	// MARK: - Functions
	/// Set the poster.
	///
	/// If the show has no poster image, then a placeholder show poster image is used.
	///
	/// - Parameter imageView: The image view on which to set the poster image.
	func posterImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.showPoster() else { return }
		imageView.setImage(with: self.poster?.url ?? "", placeholder: placeholderImage)
	}

	/// Set the banner.
	///
	/// If the show has no banner image, then a placeholder show banner image is used.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.showBanner() else { return }
		imageView.setImage(with: self.banner?.url ?? self.poster?.url ?? "", placeholder: placeholderImage)
	}
}
