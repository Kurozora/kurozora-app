//
//  PersonDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// Set of available person information types.
enum PersonDetail {}

// MARK: - Ratings
extension PersonDetail {
	/// List of available show rating types.
	enum Rating: Int, CaseIterable {
		case average = 0
		case sentiment
		case bar

		// MARK: - Properties
		/// The cell identifier string of a show rating section.
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
extension PersonDetail {
	/// List of available show rate & review types.
	enum RateAndReview: Int, CaseIterable {
		case tapToRate = 0
		case writeAReview

		// MARK: - Properties
		/// The cell identifier string of a show rate & review section.
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
extension PersonDetail {
	enum Information: Int, CaseIterable {
		// MARK: - Cases
		case aliases = 0
		case age
		case websites

		// MARK: - Properties
		/// The string value of a person information type.
		var stringValue: String {
			switch self {
			case .aliases:
				return Trans.aliases
			case .age:
				return Trans.age
			case .websites:
				return Trans.websites
			}
		}

		/// The image value of a person information type.
		var imageValue: UIImage? {
			switch self {
			case .aliases:
				return UIImage(systemName: "person")
			case .age:
				return UIImage(systemName: "calendar")
			case .websites:
				return UIImage(systemName: "safari")
			}
		}

		/// The cell identifier string of a person information type.
		var identifierString: String {
			switch self {
			case .aliases:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .age:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .websites:
				return R.reuseIdentifier.informationButtonCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/// Returns the required information from the given object.
		///
		/// - Parameter person: The object used to extract the information from.
		///
		/// Returns: the required information from the given object.
		func information(from person: Person) -> String? {
			switch self {
			case .aliases:
				var aliases = "Name: \(person.attributes.fullName)"
				if let givenName = person.attributes.fullGivenName {
					aliases += "\nGiven Name: \(givenName)"
				}

				if let alternativeNames = person.attributes.alternativeNames?.filter({ !$0.isEmpty }), !alternativeNames.isEmpty {
					aliases += "\nNicknames: \(alternativeNames.joined(separator: ", "))"
				}
				return aliases
			case .age:
				if let age = person.attributes.age, !age.isEmpty {
					return age
				}
			case .websites:
				return person.attributes.websiteURLs?.joined(separator: ", ") ?? "-"
			}
			return nil
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter person: The object used to extract the information from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from person: Person) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter person: The object used to extract the information from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from person: Person) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter person: The object used to extract the information from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from person: Person) -> UIImage? {
			switch self {
			default: return nil
			}
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter person: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from person: Person) -> String? {
			switch self {
			case .age:
				var ageFootnote = ""
				if let birthdate = person.attributes.birthdate {
					ageFootnote += birthdate.formatted(date: .long, time: .omitted)
				}

				if let astrologicalSign = person.attributes.astrologicalSign {
					ageFootnote += ageFootnote.isEmpty ? astrologicalSign : " \(astrologicalSign)"
				}
				return ageFootnote.isEmpty ? nil : ageFootnote
			default: return nil
			}
		}
	}
}
