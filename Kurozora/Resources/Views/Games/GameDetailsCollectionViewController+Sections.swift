//
//  GameDetailsCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension GameDetailsCollectionViewController {
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
		case relatedGames
		case relatedShows
		case relatedLiteratures
		case sosumi

		// MARK: - Properties
		/// The string value of a game section type.
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
			case .relatedGames:
				return L10n.relatedGames
			case .relatedShows:
				return L10n.relatedShows
			case .relatedLiteratures:
				return L10n.relatedLiteratures
			case .sosumi:
				return L10n.copyright
			}
		}

		/// The string value of a game section type segue identifier.
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
				return .gamesListSegue
			case .relatedGames:
				return .gamesListSegue
			case .relatedShows:
				return .showsListSegue
			case .relatedLiteratures:
				return .literaturesListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Game` object.
		case game(_: Game)

		/// Indicates the item kind contains a badge row.
		case badge(_: GameDetail.Badge)

		/// Indicates the item kind contains the game's synopsis.
		case synopsis

		/// Indicates the item kind contains a rating row.
		case rating(_: GameDetail.Rating)

		/// Indicates the item kind contains a rate and review row.
		case rateAndReview(_: GameDetail.RateAndReview)

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		/// Indicates the item kind contains the game's editorial endorsement.
		case editorial(_: Editorial)

		/// Indicates the item kind contains an information row.
		case information(_: GameDetail.Information)

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity)

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame)

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow)

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature)

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity)

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity)

		/// Indicates the item kind contains the game's copyright.
		case sosumi
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .castIdentity(let id): return id as? Element
		case .characterIdentity(let id): return id as? Element
		case .personIdentity(let id): return id as? Element
		case .gameIdentity(let id): return id as? Element
		case .studioIdentity(let id): return id as? Element
		default: return nil
		}
	}
}
