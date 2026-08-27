//
//  ShowDetailsCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ShowDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates badges section layout type.
		case badges

		/// Indicates a synopsis section layout type.
		case synopsis

		/// Indicates rating section layout type.
		case rating

		/// Indicates rate and review section layout type.
		case rateAndReview

		/// Indicates reviews section layout type.
		case reviews

		/// Indicates information section layout type.
		case information

		/// Indicates seasons section layout type.
		case seasons

		/// Indicates cast section layout type.
		case cast

		/// Indicates songs section layout type.
		case songs

		/// Indicates studios section layout type.
		case studios

		/// Indicates more by studio section layout type.
		case moreByStudio

		/// Indicates related shows section layout type.
		case relatedShows

		/// Indicates related literatures section layout type.
		case relatedLiteratures

		/// Indicates related games section layout
		case relatedGames

		/// Indicates copyright section layout type
		case sosumi

		// MARK: - Properties
		/// The string value of a show section type.
		var stringValue: String {
			switch self {
			case .header:
				return L10n.header
			case .badges:
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
			case .seasons:
				return L10n.seasons
			case .cast:
				return L10n.cast
			case .songs:
				return L10n.songs
			case .studios:
				return L10n.studios
			case .moreByStudio:
				return L10n.moreBy
			case .relatedShows:
				return L10n.relatedShows
			case .relatedLiteratures:
				return L10n.relatedLiteratures
			case .relatedGames:
				return L10n.relatedGames
			case .sosumi:
				return L10n.copyright
			}
		}

		/// The string value of a show section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badges, .synopsis, .rateAndReview, .reviews, .information, .sosumi:
				return nil
			case .rating:
				return .reviewsListSegue
			case .seasons:
				return .seasonsListSegue
			case .cast:
				return .castListSegue
			case .songs:
				return .songsListSegue
			case .studios:
				return .studiosListSegue
			case .moreByStudio:
				return .showsListSegue
			case .relatedShows:
				return .showsListSegue
			case .relatedLiteratures:
				return .literaturesListSegue
			case .relatedGames:
				return .gamesListSegue
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show)

		/// Indicates the item kind contains a badge row.
		case badge(_: ShowDetail.Badge)

		/// Indicates the item kind contains the show's synopsis.
		case synopsis

		/// Indicates the item kind contains a rating row.
		case rating(_: ShowDetail.Rating)

		/// Indicates the item kind contains a rate and review row.
		case rateAndReview(_: ShowDetail.RateAndReview)

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		/// Indicates the item kind contains the show's editorial endorsement.
		case editorial(_: Editorial)

		/// Indicates the item kind contains an information row.
		case information(_: ShowDetail.Information)

		/// Indicates the item kind contains a `SeasonIdentity` object.
		case seasonIdentity(_: SeasonIdentity)

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity)

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow)

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature)

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame)

		/// Indicates the item kind contains a `ShowSong` object.
		case showSong(_: ShowSong)

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity)

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity)

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity)

		/// Indicates the item kind contains the show's copyright.
		case sosumi
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .castIdentity(let id): return id as? Element
		case .characterIdentity(let id): return id as? Element
		case .personIdentity(let id): return id as? Element
		case .seasonIdentity(let id): return id as? Element
		case .showIdentity(let id): return id as? Element
		case .studioIdentity(let id): return id as? Element
		default: return nil
		}
	}
}
