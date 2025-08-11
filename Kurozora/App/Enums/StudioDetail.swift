//
//  StudioDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum StudioDetail {}

// MARK: - Badge
extension StudioDetail {
	/// List of available studio badge types.
	enum Badge: Int, CaseIterable {
		case rating = 0
		case rank
		case tvRating
		case successor

		// MARK: - Properties
		/// The string value of a badge type.
		var stringValue: String {
			switch self {
			case .rating:
				return Trans.rating
			case .rank:
				return Trans.rank
			case .tvRating:
				return Trans.tvRating
			case .successor:
				return Trans.successor
			}
		}

		/// The cell identifier string of a studio information section.
		var identifierString: String {
			switch self {
			case .rating:
				return R.reuseIdentifier.ratingBadgeCollectionViewCell.identifier
			default:
				return R.reuseIdentifier.badgeCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/// Returns the required primary information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from studio: Studio) -> String? {
			switch self {
			case .rating:
				return nil
			case .rank:
				let rank = studio.attributes.stats?.rankTotal ?? 0
				return rank > 0 ? "#\(rank)" : "-"
			case .tvRating:
				return studio.attributes.tvRating.name
			case .successor:
				return studio.attributes.successor ?? "-"
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from studio: Studio? = nil) -> String? {
			switch self {
			case .rating:
				let ratingCount = studio?.attributes.stats?.ratingCount ?? 0
				return ratingCount != 0 ? "\(ratingCount.kkFormatted(precision: 0)) Ratings" : "Not enough ratings"
			case .rank:
				return Trans.chart
			case .tvRating:
				return "Rated"
			case .successor:
				return Trans.successor
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from studio: Studio? = nil) -> UIImage? {
			switch self {
			case .rating:
				return nil
			case .rank:
				return UIImage(systemName: "chart.bar.fill")
			case .tvRating:
				switch studio?.attributes.tvRating.name.lowercased() {
				default:
					return UIImage(systemName: "tv.fill")
				}
			case .successor:
				return UIImage(systemName: "building.2.fill")
			}
		}
	}
}

// MARK: - Ratings
extension StudioDetail {
	/// List of available studio rating types.
	enum Rating: Int, CaseIterable {
		case average = 0
		case sentiment
		case bar

		// MARK: - Properties
		/// The cell identifier string of a studio rating section.
		var identifierString: String {
			switch self {
			case .average:
				return R.reuseIdentifier.ratingCollectionViewCell.identifier
			case .sentiment:
				return R.reuseIdentifier.ratingSentimentCollectionViewCell.identifier
			case .bar:
				return R.reuseIdentifier.ratingBarCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Rating & Review
extension StudioDetail {
	/// List of available studio rate & review types.
	enum RateAndReview: Int, CaseIterable {
		case tapToRate = 0
		case writeAReview

		// MARK: - Properties
		/// The cell identifier string of a studio rate & review section.
		var identifierString: String {
			switch self {
			case .tapToRate:
				return R.reuseIdentifier.tapToRateCollectionViewCell.identifier
			case .writeAReview:
				return R.reuseIdentifier.writeAReviewCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Information
extension StudioDetail {
	/// List of available studio information types.
	enum Information: Int, CaseIterable {
		// MARK: - Cases
		/// The aliases of the studio.
		case aliases = 0

		/// The date in which the studio was founded.
		case founded

		/// The date in which the studio is defunct.
		case defunct

		/// The headquarters of the studio.
		case headquarters

		/// The rating of the studio.
		case rating

		/// The socials of the studio.
		case socials

		/// The website of the studio.
		case websites

		// MARK: - Properties
		/// The string value of a studio information type.
		var stringValue: String {
			switch self {
			case .aliases:
				return Trans.aliases
			case .founded:
				return Trans.founded
			case .defunct:
				return Trans.defunct
			case .headquarters:
				return Trans.headquarters
			case .rating:
				return Trans.rating
			case .socials:
				return Trans.socials
			case .websites:
				return Trans.websites
			}
		}

		/// The image value of a studio infomration type.
		var imageValue: UIImage? {
			switch self {
			case .aliases:
				return UIImage(systemName: "person")
			case .founded:
				return UIImage(systemName: "calendar")
			case .defunct:
				return UIImage(systemName: "calendar.badge.exclamationmark")
			case .headquarters:
				return UIImage(systemName: "building.2")
			case .rating:
				return R.image.symbols.pgTv()
			case .socials:
				return UIImage(systemName: "globe")
			case .websites:
				return UIImage(systemName: "safari")
			}
		}

		/// The cell identifier string of a studio information type.
		var identifierString: String {
			switch self {
			case .socials, .websites:
				return R.reuseIdentifier.informationButtonCollectionViewCell.identifier
			default:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/// Returns the required information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required information from the given object.
		func information(from studio: Studio) -> String {
			switch self {
			case .aliases:
				var aliases: String?

				if let givenName = studio.attributes.japaneseName {
					aliases = "Japanese: \(givenName)"
				}

				if let alternativeNames = studio.attributes.alternativeNames?.filter({ !$0.isEmpty }), !alternativeNames.isEmpty {
					if let unwrappedAliases = aliases {
						aliases = "\(unwrappedAliases)\nSynonyms: \(alternativeNames.joined(separator: ", "))"
					} else {
						aliases = "Synonyms: \(alternativeNames.joined(separator: ", "))"
					}
				}

				return aliases ?? "-"
			case .founded:
				return studio.attributes.foundedAt?.formatted(date: .abbreviated, time: .omitted) ?? "-"
			case .defunct:
				return studio.attributes.defunctAt?.formatted(date: .abbreviated, time: .omitted) ?? "-"
			case .headquarters:
				return studio.attributes.address ?? "-"
			case .rating:
				return studio.attributes.tvRating.name
			case .socials:
				return studio.attributes.socialURLs?.joined(separator: "\n") ?? "-"
			case .websites:
				return studio.attributes.websiteURLs?.joined(separator: "\n") ?? "-"
			}
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from studio: Studio) -> String? {
			return nil
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from studio: Studio) -> String? {
			return nil
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from studio: Studio) -> UIImage? {
			return nil
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter studio: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from studio: Studio) -> String? {
			switch self {
			case .founded:
				guard let foundedAt = studio.attributes.foundedAt else { return nil }

				let calendar = Calendar.current
				guard let years = calendar.dateComponents([.year], from: foundedAt, to: .now).year else { return nil }

				return "The studio was founded \(years) years ago."
			case .defunct:
				guard let defunctAt = studio.attributes.defunctAt else { return nil }

				let calendar = Calendar.current
				guard let years = calendar.dateComponents([.year], from: defunctAt, to: .now).year else { return nil }

				return "The studio has been defunct for \(years) years."
			case .rating:
				return studio.attributes.tvRating.description
			default:
				return nil
			}
		}
	}
}
