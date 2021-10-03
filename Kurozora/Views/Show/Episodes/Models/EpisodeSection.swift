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
		List of available episode section types.
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
		/// The string value of an episode section type.
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

		/// The cell identifier string of a show section type.
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
		List of available episode information types.
	*/
	enum Information: Int, CaseIterable {
		// MARK: - Cases
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
			case .number:
				return "Number"
			case .duration:
				return "Duration"
			case .airDate:
				return "Aired"
			}
		}

		/// The image value of a studio infomration type.
		var imageValue: UIImage? {
			switch self {
			case .number:
				return UIImage(systemName: "number")
			case .duration:
				return UIImage(systemName: "hourglass")
			case .airDate:
				return UIImage(systemName: "calendar")
			}
		}

		// MARK: - Functions
		/**
			Returns the required information from the given object.

			- Parameter episode: The object used to extract the infromation from.

			Returns: the required information from the given object.
		*/
		func information(from episode: Episode) -> String? {
			switch self {
			case .number:
				return "\(episode.attributes.numberTotal)"
			case .duration:
				return episode.attributes.duration
			case .airDate:
				return episode.attributes.firstAired?.formatted(date: .abbreviated, time: .omitted) ?? "TBA"
			}
		}

		/**
			Returns the required primary information from the given object.

			- Parameter episode: The object used to extract the infromation from.

			- Returns: the required primary information from the given object.
		*/
		func primaryInformation(from episode: Episode) -> String? {
			switch self {
			default: return nil
			}
		}

		/**
			Returns the required secondary information from the given object.

			- Parameter episode: The object used to extract the infromation from.

			- Returns: the required secondary information from the given object.
		*/
		func secondaryInformation(from episode: Episode) -> String? {
			switch self {
			default: return nil
			}
		}

		/**
			Returns the required primary image from the given object.

			- Parameter episode: The object used to extract the infromation from.

			- Returns: the required primary image from the given object.
		*/
		func primaryImage(from episode: Episode) -> UIImage? {
			switch self {
			default: return nil
			}
		}

		/**
			Returns the footnote from the given object.

			- Parameter episode: The object used to extract the footnote from.

			- Returns: the footnote from the given object.
		*/
		func footnote(from episode: Episode) -> String? {
			switch self {
			case .number:
				return "#\(episode.attributes.number) in the current season."
			case .duration:
				return nil
			case .airDate:
				if let isInFuture = episode.attributes.firstAired?.isInFuture {
					return isInFuture ? "The episode will air on the announced date." : "The episode has finished airing."
				}
				return "A release date has yet to be announced."
			}
		}
	}
}
