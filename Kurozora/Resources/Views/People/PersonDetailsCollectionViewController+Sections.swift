//
//  PersonDetailsCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension PersonDetailsCollectionViewController {
	/// List of person section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		case header = 0
		case about
		case rating
		case rateAndReview
		case reviews
		case information
		case characters
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
			case .characters:
				return L10n.characters
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
			case .characters:
				return .charactersListSegue
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
		/// Indicates the item kind contains a `Person` object.
		case person(_: Person)

		/// Indicates the item kind contains the person's about text.
		case about

		/// Indicates the item kind contains a rating row.
		case rating(_: PersonDetail.Rating)

		/// Indicates the item kind contains a rate and review row.
		case rateAndReview(_: PersonDetail.RateAndReview)

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		/// Indicates the item kind contains an information row.
		case information(_: PersonDetail.Information)

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity)

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
		case .characterIdentity(let id): return id as? Element
		default: return nil
		}
	}
}
