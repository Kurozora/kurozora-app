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
	/// List of available episode section types.
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
				return Trans.header
			case .synopsis:
				return Trans.synopsis
			case .rating:
				return Trans.rating
			case .information:
				return Trans.information
			}
		}

		/// The cell identifier string of a show section type.
		var identifierString: String {
			switch self {
			case .header:
				return R.reuseIdentifier.episodeDetailHeaderCollectionViewCell.identifier
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
	/// List of available episode information types.
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
				return Trans.number
			case .duration:
				return Trans.duration
			case .airDate:
				return Trans.aired
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
		/// Returns the required information from the given object.
		///
		/// - Parameter episode: The object used to extract the infromation from.
		///
		/// Returns: the required information from the given object.
		func information(from episode: Episode) -> String? {
			switch self {
			case .number:
				return "\(episode.attributes.numberTotal)"
			case .duration:
				return episode.attributes.duration
			case .airDate:
				return episode.attributes.startedAt?.formatted(date: .abbreviated, time: .omitted) ?? Trans.tba
			}
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter episode: The object used to extract the infromation from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from episode: Episode) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter episode: The object used to extract the infromation from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from episode: Episode) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter episode: The object used to extract the infromation from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from episode: Episode) -> UIImage? {
			switch self {
			default: return nil
			}
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter episode: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from episode: Episode) -> String? {
			switch self {
			case .number:
				return "#\(episode.attributes.number) in the current season."
			case .duration:
				return nil
			case .airDate:
				if let isInFuture = episode.attributes.startedAt?.isInFuture {
					return isInFuture ? "The episode will air on the announced date." : "The episode has finished airing."
				}
				return "A release date has yet to be announced."
			}
		}
	}
}
