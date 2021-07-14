//
//  ShowAttributes+UIKit.swift
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

	/**
		Returns a string containing all the necessary information of a show. If one of the informations is missing then that particular part is ommitted.

		```
		"TV · R15+ · 25 episodes · 25 minutes · Spring 2016"
		```
	*/
	var informationString: String {
		var informationString = "\(self.type.name) · \(self.tvRating.name)"

		// Add the episode count
		if self.episodeCount != 0 {
			informationString += " · \(self.episodeCount) \(self.episodeCount == 1 ? "episode" : "episodes")"
		}

		// Add the runtime
		informationString += " · \(self.runtime)"

		// Add the year
		if let airYear = self.firstAired?.year {
			informationString += " · "
			if let airSeason = self.airSeason {
				informationString += "\(airSeason) "
			}
			informationString += "\(airYear)"
		}

		return informationString
	}

	/**
		Returns a short version of the shows information. If one of the informations is missing then that particular part is ommitted.

		```
		"TV · ✓ 10/25 · ☆ 5"
		```
	*/
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

	/// Returns the date the show will be broadcasted on.
	var broadcastDate: Date? {
		guard let airDay = self.airDay, let airTime = airTime else { return nil }
		return Date(from: "\(airDay) at \(airTime)")
	}
}
