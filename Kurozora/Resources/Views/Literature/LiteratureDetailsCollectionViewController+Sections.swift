//
//  LiteratureDetailsCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LiteratureDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0
		case badge
		case synopsis
		case rating
		case rateAndReview
		case reviews
		case information
		case cast
		case studios
		case moreByStudio
		case relatedLiteratures
		case relatedShows
		case relatedGames
		case sosumi

		// MARK: - Properties
		/// The string value of a literature section type.
		var stringValue: String {
			switch self {
			case .header:
				return L10n.header
			case .badge:
				return L10n.badges
			case .synopsis:
				return L10n.synopsis
			case .rating:
				return L10n.ratingsAndReviews
			case .rateAndReview:
				return ""
			case .reviews:
				return ""
			case .information:
				return L10n.information
			case .cast:
				return L10n.cast
			case .studios:
				return L10n.studios
			case .moreByStudio:
				return L10n.moreBy
			case .relatedLiteratures:
				return L10n.relatedLiteratures
			case .relatedShows:
				return L10n.relatedShows
			case .relatedGames:
				return L10n.relatedGames
			case .sosumi:
				return L10n.copyright
			}
		}

		/// The string value of a literature section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badge, .synopsis, .rateAndReview, .reviews, .information, .sosumi:
				return nil
			case .rating:
				return .reviewsListSegue
			case .cast:
				return .castListSegue
			case .studios:
				return .studiosListSegue
			case .moreByStudio:
				return .literaturesListSegue
			case .relatedLiteratures:
				return .literaturesListSegue
			case .relatedShows:
				return .showsListSegue
			case .relatedGames:
				return .gamesListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Literature` object.
		case literature(_: Literature)

		/// Indicates the item kind contains a badge row.
		case badge(_: LiteratureDetail.Badge)

		/// Indicates the item kind contains the literature's synopsis.
		case synopsis

		/// Indicates the item kind contains a rating row.
		case rating(_: LiteratureDetail.Rating)

		/// Indicates the item kind contains a rate and review row.
		case rateAndReview(_: LiteratureDetail.RateAndReview)

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		/// Indicates the item kind contains the literature's editorial endorsement.
		case editorial(_: Editorial)

		/// Indicates the item kind contains an information row.
		case information(_: LiteratureDetail.Information)

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity)

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature)

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow)

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame)

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity)

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity)

		/// Indicates the item kind contains the literature's copyright.
		case sosumi
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .castIdentity(let id): return id as? Element
		case .characterIdentity(let id): return id as? Element
		case .literatureIdentity(let id): return id as? Element
		case .personIdentity(let id): return id as? Element
		case .studioIdentity(let id): return id as? Element
		default: return nil
		}
	}
}
