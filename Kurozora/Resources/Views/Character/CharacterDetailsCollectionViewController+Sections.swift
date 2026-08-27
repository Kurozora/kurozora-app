//
//  CharacterDetailsCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension CharacterDetailsCollectionViewController {
	/// List of character section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		case header = 0
		case about
		case rating
		case rateAndReview
		case reviews
		case information
		case people
		case shows
		case literatures
		case games

		// MARK: - Properties
		/// The string value of a character section type.
		var stringValue: String {
			switch self {
			case .header:
				return L10n.header
			case .about:
				return L10n.about
			case .rating:
				return L10n.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return L10n.information
			case .people:
				return L10n.people
			case .shows:
				return L10n.shows
			case .literatures:
				return L10n.literatures
			case .games:
				return L10n.games
			}
		}

		/// The string value of a character section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .about, .rateAndReview, .reviews, .information:
				return nil
			case .rating:
				return .reviewsListSegue
			case .people:
				return .peopleListSegue
			case .shows:
				return .showsListSegue
			case .literatures:
				return .literaturesListSegue
			case .games:
				return .gamesListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Character` object.
		case character(_: Character)

		/// Indicates the item kind contains the character's about text.
		case about

		/// Indicates the item kind contains a rating row.
		case rating(_: CharacterDetail.Rating)

		/// Indicates the item kind contains a rate and review row.
		case rateAndReview(_: CharacterDetail.RateAndReview)

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		/// Indicates the item kind contains an information row.
		case information(_: CharacterDetail.Information)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity)

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity)

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity)
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .gameIdentity(let id): return id as? Element
		case .literatureIdentity(let id): return id as? Element
		case .showIdentity(let id): return id as? Element
		case .personIdentity(let id): return id as? Element
		default: return nil
		}
	}
}
