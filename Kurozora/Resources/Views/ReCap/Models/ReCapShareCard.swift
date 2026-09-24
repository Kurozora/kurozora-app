//
//  ReCapShareCard.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// The content of a shareable Re:CAP image.
enum ReCapShareCard {
	// MARK: - Types
	/// The artwork of a title shown on a share card.
	struct Artwork {
		/// The shape an artwork is drawn in.
		enum Shape {
			case poster
			case book
			case square
			case circle
		}

		// MARK: - Properties
		let url: String?
		let color: UIColor?
		let shape: Shape

		/// The image drawn when the model has no artwork.
		let placeholder: UIImage

		// MARK: - Initializers
		/// Creates the artwork of the given model in the shape of its media.
		///
		/// - Parameter model: The model whose artwork to show.
		init(model: KurozoraItem) {
			let media: Media?

			switch model {
			case let show as Show:
				media = show.attributes.poster
				self.shape = .poster
			case let literature as Literature:
				media = literature.attributes.poster
				self.shape = .book
			case let game as Game:
				media = game.attributes.poster
				self.shape = .square
			case let character as Character:
				media = character.attributes.profile
				self.shape = .circle
			case let person as Person:
				media = person.attributes.profile
				self.shape = .circle
			default:
				media = nil
				self.shape = .poster
			}

			self.url = media?.url
			self.color = media?.backgroundColor.flatMap { UIColor(hexString: $0) }
			self.placeholder = self.shape == .circle ? .Placeholders.personPoster : .Placeholders.showPoster
		}
	}

	/// A ranked genre or theme with the time spent on it.
	struct RankedItem {
		let name: String
		let detail: String?
	}

	/// A year's top title on a comparison card.
	struct ComparisonEntry {
		let year: String
		let name: String
		let detail: String?
		let artwork: Artwork
	}

	/// A section of top titles on a summary card.
	struct Section {
		let title: String
		let items: [String]
		let artwork: Artwork
	}

	// MARK: - Cases
	/// The top genres or themes of a period.
	case genres(title: String, subtitle: String, items: [RankedItem])

	/// A year's top title beside the year before's.
	case comparison(title: String, subtitle: String, entries: [ComparisonEntry])

	/// The total time and top titles of a period.
	case summary(period: String, total: String?, sections: [Section])

	// MARK: - Properties
	/// The title of the card.
	var title: String {
		switch self {
		case .genres(let title, _, _), .comparison(let title, _, _):
			return title
		case .summary:
			return L10n.reCAP
		}
	}

	/// The artwork the card shows.
	var artworks: [Artwork] {
		switch self {
		case .genres:
			return []
		case .comparison(_, _, let entries):
			return entries.map(\.artwork)
		case .summary(_, _, let sections):
			return sections.map(\.artwork)
		}
	}
}
