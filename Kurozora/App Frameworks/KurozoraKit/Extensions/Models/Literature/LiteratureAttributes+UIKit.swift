//
//  LiteratureAttributes+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Literature.Attributes {
	// MARK: - Properties
	/// Returns a string containing all the necessary information of a literature. If one of the informations is missing then that particular part is omitted.
	///
	/// ```swift
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
		if let publicationYear = self.startedAt?.components.year {
			informationString += " · "
			if let publicationSeason = self.publicationSeason {
				informationString += "\(publicationSeason) "
			}
			informationString += "\(publicationYear)"
		}

		return informationString
	}

	/// Returns a short version of the literature information. If one of the informations is missing then that particular part is omitted.
	///
	/// ```swift
	/// "Manga · ✓ 10/25 · ☆ 5"
	/// ```
	var informationStringShort: String {
		var informationString = ""
		informationString += "\(self.type.name)"

		// TODO: Add read chapters count to the short information string
//		if let readChaptersCount = self.readChaptersCount {
//			informationString += " · ✓ \(readChaptersCount)/\(self.episodeCount)"
//		}

		if let givenRating = self.library?.rating {
			informationString += " · ☆ \(givenRating)"
		}

		return informationString
	}

	/// Returns the date the literature will be published on.
	var publicationDate: Date? {
		guard let publicationDay = self.publicationDay, let publicationTime = self.publicationTime else { return nil }
		return Date(from: "\(publicationDay) at \(publicationTime)")
	}

	/// A string describing when the literature is next published.
	var publicationString: String? {
		let date: Date?

		if let nextPublicationAt = self.nextPublicationAt {
			date = nextPublicationAt
		} else if let publicationTime = self.publicationTime {
			date = self.startedAt?.settingTime(from: publicationTime)
		} else {
			date = self.startedAt
		}

		guard let publicationAt = date else { return nil }
		let dateFormatter = DateFormatter.app
		dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")

		let timeString = DateFormatter.broadcastTime.string(from: publicationAt)
		let weekdayString = dateFormatter.string(from: publicationAt)

		return "\(weekdayString) at \(timeString)"
	}

	// MARK: - Functions
	/// Set the poster.
	///
	/// If the literature has no poster image, then a placeholder literature poster image is used.
	///
	/// - Parameter imageView: The image view on which to set the poster image.
	func posterImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.showPoster() else { return }
		imageView.setImage(with: self.poster?.url ?? "", placeholder: placeholderImage)
	}

	/// Set the banner.
	///
	/// If the literature has no banner image, then a placeholder literature banner image is used.
	///
	/// - Parameter imageView: The image view on which to set the banner image.
	func bannerImage(imageView: UIImageView) {
		guard let placeholderImage = R.image.placeholders.showBanner() else { return }
		imageView.setImage(with: self.banner?.url ?? self.poster?.url ?? "", placeholder: placeholderImage)
	}
}
