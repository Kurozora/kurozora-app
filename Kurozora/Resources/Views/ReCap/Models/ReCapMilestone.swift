//
//  ReCapMilestone.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A milestone shown on a Re:CAP card.
struct ReCapMilestone {
	// MARK: - Types
	/// The artwork a milestone card shows along its bottom edge.
	enum ArtworkStyle {
		case none
		case posters
		case banners
		case squares
	}

	/// An artwork of a milestone card.
	struct Artwork {
		/// The title the artwork belongs to.
		let model: KurozoraItem

		/// The color shown while the artwork loads.
		let backgroundColor: String?

		/// Loads the artwork into the given image view.
		let setImage: (UIImageView) -> Void
	}

	// MARK: - Properties
	let subtitle: String
	let count: String
	let unit: String
	let artworkStyle: ArtworkStyle
	let artworks: [Artwork]

	// MARK: - Initializers
	/// Creates the milestone of the given kind.
	///
	/// - Parameters:
	///    - recapItem: The recap the milestone is drawn from.
	///    - milestoneKind: The kind of the milestone.
	///    - models: The top titles of the recap.
	init(recapItem: RecapItem, milestoneKind: MilestoneKind, models: [KurozoraItem]) {
		let attributes = recapItem.attributes

		switch milestoneKind {
		case .minuetsWatched, .minuetsRead, .minutesPlayed:
			self.count = attributes.totalPartsDuration.formatted()
		case .episodesWatched, .chaptersRead, .gamesPlayed:
			self.count = attributes.totalPartsCount.formatted()
		case .topPercentile:
			self.count = "\(attributes.topPercentile.formatted(.number.precision(.fractionLength(0 ... 2))))%"
		}

		if milestoneKind == .topPercentile {
			let noun: String = switch attributes.recapItemType {
			case .games: L10n.gamePlayers
			case .literatures: L10n.mangaReaders
			default: L10n.animeWatchers
			}
			let percentile = attributes.topPercentile.formatted(.number.precision(.fractionLength(0 ... 2)))

			self.subtitle = L10n.recapTopPercentile(percentile, of: noun)
			self.unit = L10n.top(String(noun.capitalized(with: LanguageManager.shared.locale).dropLast()))
			self.artworkStyle = .none
			self.artworks = []
			return
		}

		self.subtitle = milestoneKind.stringValue
		self.unit = milestoneKind.unitValue

		let artworkStyle: ArtworkStyle = switch milestoneKind {
		case .episodesWatched: .banners
		case .minutesPlayed, .gamesPlayed: .squares
		default: .posters
		}
		let artworkCount = artworkStyle == .posters ? 4 : 3
		var orderedModels = artworkStyle == .banners ? Array(models.reversed()) : models

		if !orderedModels.isEmpty {
			orderedModels = Array((orderedModels + orderedModels).prefix(artworkCount))
			while orderedModels.count < artworkCount, let lastModel = models.last {
				orderedModels.append(lastModel)
			}
		}

		self.artworkStyle = orderedModels.isEmpty ? .none : artworkStyle
		self.artworks = orderedModels.compactMap { model in
			switch model {
			case let show as Show:
				if artworkStyle == .banners {
					let banner = show.attributes.banner ?? show.attributes.poster
					return Artwork(model: show, backgroundColor: banner?.backgroundColor) { show.attributes.bannerImage(imageView: $0) }
				}
				return Artwork(model: show, backgroundColor: show.attributes.poster?.backgroundColor) { show.attributes.posterImage(imageView: $0) }
			case let literature as Literature:
				return Artwork(model: literature, backgroundColor: literature.attributes.poster?.backgroundColor) { literature.attributes.posterImage(imageView: $0) }
			case let game as Game:
				return Artwork(model: game, backgroundColor: game.attributes.poster?.backgroundColor) { game.attributes.posterImage(imageView: $0) }
			default:
				return nil
			}
		}
	}
}

/// A top title of a year paired with the one of the year before.
struct ReCapComparison {
	// MARK: - Types
	/// A title of a comparison.
	struct Entry {
		let year: Int
		let model: KurozoraItem
		let detail: String?
	}

	// MARK: - Properties
	let title: String
	let entries: [Entry]
}
