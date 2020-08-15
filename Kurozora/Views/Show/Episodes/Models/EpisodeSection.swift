//
//  EpisodeSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

class EpisodeDetail {
	/**
		Set of available episode detail sections.
	*/
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		/// The header section of the episode detail view.
		case header

		/// The synopsis section of the episode detail view.
		case synopsis

		/// The rating section of the episode detail view.
		case rating

		/// The infomration section of the episode detail view.
		case information

		// MARK: - Properties
		/// The string value of an episode section.
		var stringValue: String {
			switch self {
			case .header:
				return "Header"
			case .synopsis:
				return "Synopsis"
			case .rating:
				return "Rating"
			case .information:
				return "Information"
			}
		}

		/// The cell identifier string of a show section.
		var identifierString: String {
			switch self {
			case .header:
				return R.reuseIdentifier.episodeLockupCollectionViewCell.identifier
			case .synopsis:
				return R.reuseIdentifier.textViewCollectionViewCell.identifier
			case .rating:
				return R.reuseIdentifier.ratingCollectionViewCell.identifier
			case .information:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Information
extension EpisodeDetail {
	/**
		Set of available episode informations.
	*/
	enum Information: Int, CaseIterable {
		// MARK: - Cases
		/// The id of the episode.
		case id

		/// The number of the episode.
		case number

		/// The duration of the episode.
		case duration

		/// The air date of the episode.
		case airDate

		// MARK: - Properties
		/// The string value of an information type.
		var stringValue: String {
			switch self {
			case .id:
				return "ID"
			case .number:
				return "Number"
			case .duration:
				return "Duration"
			case .airDate:
				return "Aired"
			}
		}

		// MARK: - Functions
		/**
			Returns the required information from the given object.

			- Parameter episodeElement: The object used to extract the infromation from.

			Returns: the required information from the given object.
		*/
		func information(from episode: Episode) -> String {
			switch self {
			case .id:
				return "\(episode.id)"
			case .number:
				return "\(episode.attributes.number)"
			case .duration:
				return "\(episode.attributes.duration)"
			case .airDate:
				return episode.attributes.firstAired ?? "TBA"
			}
		}
	}
}
