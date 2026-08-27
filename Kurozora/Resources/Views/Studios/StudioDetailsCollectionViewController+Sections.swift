//
//  StudioDetailsCollectionViewController+Sections.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension StudioDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates badges section layout type.
		case badges

		/// Indicates an about section layout type.
		case about

		/// Indicates rating section layout type.
		case rating

		/// Indicates rate and review section layout type.
		case rateAndReview

		/// Indicates reviews section layout type.
		case reviews

		/// Indicates an information section layout type.
		case information

		/// Indicates shows section layout type.
		case shows

		/// Indicates literatures section layout type.
		case literatures

		/// Indicates games section layout type.
		case games

		// MARK: - Properties
		/// The string value of a studio section type.
		var stringValue: String {
			switch self {
			case .header:
				return L10n.header
			case .badges:
				return L10n.badges
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
			case .shows:
				return L10n.shows
			case .literatures:
				return L10n.literatures
			case .games:
				return L10n.games
			}
		}

		/// The string value of a studio section type segue identifier.
		var segueIdentifier: SegueIdentifiers? {
			switch self {
			case .header, .badges, .about, .rateAndReview, .reviews, .information:
				return nil
			case .rating:
				return .reviewsListSegue
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
		/// Indicates the item kind contains a `Studio` object.
		case studio(_: Studio)

		/// Indicates the item kind contains a badge row.
		case badge(_: StudioDetail.Badge)

		/// Indicates the item kind contains the studio's about text.
		case about

		/// Indicates the item kind contains a rating row.
		case rating(_: StudioDetail.Rating)

		/// Indicates the item kind contains a rate and review row.
		case rateAndReview(_: StudioDetail.RateAndReview)

		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		/// Indicates the item kind contains an information row.
		case information(_: StudioDetail.Information)

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
		default: return nil
		}
	}
}
