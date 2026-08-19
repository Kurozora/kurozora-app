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
		case literature(_: Literature, id: UUID = UUID())

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		/// Indicates the item kind contains the literature's editorial endorsement.
		case editorial(_: Editorial, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame, id: UUID = UUID())

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .literature(let literature, let id):
				hasher.combine(literature)
				hasher.combine(id)
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			case .editorial(let editorial, let id):
				hasher.combine(editorial)
				hasher.combine(id)
			case .literatureIdentity(let literatureIdentity, let id):
				hasher.combine(literatureIdentity)
				hasher.combine(id)
			case .relatedLiterature(let relatedLiterature, let id):
				hasher.combine(relatedLiterature)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			case .relatedGame(let relatedGame, let id):
				hasher.combine(relatedGame)
				hasher.combine(id)
			case .characterIdentity(let characterIdentity, let id):
				hasher.combine(characterIdentity)
				hasher.combine(id)
			case .personIdentity(let personIdentity, let id):
				hasher.combine(personIdentity)
				hasher.combine(id)
			case .castIdentity(let castIdentity, let id):
				hasher.combine(castIdentity)
				hasher.combine(id)
			case .studioIdentity(let studioIdentity, let id):
				hasher.combine(studioIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.literature(let literature1, let id1), .literature(let literature2, let id2)):
				return literature1 == literature2 && id1 == id2
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			case (.editorial(let editorial1, let id1), .editorial(let editorial2, let id2)):
				return editorial1 == editorial2 && id1 == id2
			case (.literatureIdentity(let literatureIdentity1, let id1), .literatureIdentity(let literatureIdentity2, let id2)):
				return literatureIdentity1 == literatureIdentity2 && id1 == id2
			case (.relatedLiterature(let relatedLiterature1, let id1), .relatedLiterature(let relatedLiterature2, let id2)):
				return relatedLiterature1 == relatedLiterature2 && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1 == relatedShow2 && id1 == id2
			case (.relatedGame(let relatedGame1, let id1), .relatedGame(let relatedGame2, let id2)):
				return relatedGame1 == relatedGame2 && id1 == id2
			case (.characterIdentity(let characterIdentity1, let id1), .characterIdentity(let characterIdentity2, let id2)):
				return characterIdentity1 == characterIdentity2 && id1 == id2
			case (.personIdentity(let personIdentity1, let id1), .personIdentity(let personIdentity2, let id2)):
				return personIdentity1 == personIdentity2 && id1 == id2
			case (.castIdentity(let castIdentity1, let id1), .castIdentity(let castIdentity2, let id2)):
				return castIdentity1 == castIdentity2 && id1 == id2
			case (.studioIdentity(let studioIdentity1, let id1), .studioIdentity(let studioIdentity2, let id2)):
				return studioIdentity1 == studioIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .castIdentity(let id, _): return id as? Element
		case .characterIdentity(let id, _): return id as? Element
		case .literatureIdentity(let id, _): return id as? Element
		case .personIdentity(let id, _): return id as? Element
		case .studioIdentity(let id, _): return id as? Element
		default: return nil
		}
	}
}
