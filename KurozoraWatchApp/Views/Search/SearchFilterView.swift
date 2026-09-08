//
//  SearchFilterView.swift
//  Kurozora Watch App
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import SwiftUI

// MARK: - WatchFilterOption
/// A single selectable filter option.
struct WatchFilterOption: Identifiable {
	let id: Int
	let label: String
	let value: Int
}

// MARK: - WatchFilterAttribute
/// A filter attribute with its available options on watchOS.
struct WatchFilterAttribute: Identifiable {
	let id: String
	let name: String
	let options: [WatchFilterOption]
	var selectedValue: Int?
}

// MARK: - SearchFilterView
struct SearchFilterView: View {
	// MARK: - Properties
	let kind: LibraryKind

	/// The filter currently applied, whose selections the sheet opens with.
	let filter: SearchFilter?

	@Binding var isPresented: Bool

	/// Receives the built filter on apply, or `nil` on reset.
	let onApply: (SearchFilter?) -> Void

	@State private var attributes: [WatchFilterAttribute] = []

	// MARK: - Body
	var body: some View {
		NavigationStack {
			List {
				ForEach(self.$attributes) { $attribute in
					Picker(attribute.name, selection: $attribute.selectedValue) {
						Text(L10n.any).tag(nil as Int?)
						ForEach(attribute.options) { option in
							Text(option.label).tag(option.value as Int?)
						}
					}
					.font(.caption)
				}

				Section {
					Button(L10n.apply) {
						self.applyFilter()
					}
					Button(L10n.reset, role: .destructive) {
						self.resetFilter()
					}
				}
			}
			.navigationTitle(L10n.filters)
			.onAppear {
				let selectedValues = Self.selectedValues(in: self.filter)

				self.attributes = Self.filterAttributes(for: self.kind.searchType).map { attribute in
					var attribute = attribute
					attribute.selectedValue = selectedValues[attribute.id]
					return attribute
				}
			}
		}
	}

	// MARK: - Private
	/// Returns the applied filter's selections keyed by attribute identifier.
	private static func selectedValues(in filter: SearchFilter?) -> [String: Int] {
		guard let filter else { return [:] }

		let values: [String: Int?]

		switch filter {
		case .show(let show):
			values = [
				"airDay": show.airDay,
				"airSeason": show.airSeason,
				"mediaType": show.mediaType,
				"source": show.source,
				"status": show.status,
				"tvRating": show.tvRating
			]
		case .literature(let literature):
			values = [
				"publicationDay": literature.publicationDay,
				"publicationSeason": literature.publicationSeason,
				"mediaType": literature.mediaType,
				"source": literature.source,
				"status": literature.status,
				"tvRating": literature.tvRating
			]
		case .game(let game):
			values = [
				"publicationDay": game.publicationDay,
				"publicationSeason": game.publicationSeason,
				"mediaType": game.mediaType,
				"source": game.source,
				"status": game.status,
				"tvRating": game.tvRating
			]
		default:
			return [:]
		}

		return values.compactMapValues { $0 }
	}

	private func applyFilter() {
		self.isPresented = false
		self.onApply(Self.buildFilter(from: self.attributes, for: self.kind.searchType))
	}

	private func resetFilter() {
		self.isPresented = false
		self.onApply(nil)
	}

	// MARK: - Filter Attribute Definitions
	/// Returns the filterable attributes (single-selection only) for the given search type.
	static func filterAttributes(for type: SearchType) -> [WatchFilterAttribute] {
		switch type {
		case .shows:
			return [
				WatchFilterAttribute(id: "mediaType", name: L10n.mediaType, options: showTypeOptions),
				WatchFilterAttribute(id: "status", name: L10n.status, options: showStatusOptions),
				WatchFilterAttribute(id: "tvRating", name: L10n.tvRating, options: tvRatingOptions),
				WatchFilterAttribute(id: "source", name: L10n.source, options: sourceTypeOptions),
				WatchFilterAttribute(id: "airDay", name: L10n.airDay, options: dayOfWeekOptions),
				WatchFilterAttribute(id: "airSeason", name: L10n.airSeason, options: seasonOfYearOptions),
			]
		case .literatures:
			return [
				WatchFilterAttribute(id: "mediaType", name: L10n.mediaType, options: literatureTypeOptions),
				WatchFilterAttribute(id: "status", name: L10n.status, options: literatureStatusOptions),
				WatchFilterAttribute(id: "tvRating", name: L10n.tvRating, options: tvRatingOptions),
				WatchFilterAttribute(id: "source", name: L10n.source, options: sourceTypeOptions),
				WatchFilterAttribute(id: "publicationDay", name: L10n.publicationDay, options: dayOfWeekOptions),
				WatchFilterAttribute(id: "publicationSeason", name: L10n.publicationSeason, options: seasonOfYearOptions),
			]
		case .games:
			return [
				WatchFilterAttribute(id: "mediaType", name: L10n.mediaType, options: gameTypeOptions),
				WatchFilterAttribute(id: "status", name: L10n.status, options: gameStatusOptions),
				WatchFilterAttribute(id: "tvRating", name: L10n.tvRating, options: tvRatingOptions),
				WatchFilterAttribute(id: "source", name: L10n.source, options: sourceTypeOptions),
				WatchFilterAttribute(id: "publicationDay", name: L10n.publicationDay, options: dayOfWeekOptions),
				WatchFilterAttribute(id: "publicationSeason", name: L10n.publicationSeason, options: seasonOfYearOptions),
			]
		case .episodes:
			return [
				WatchFilterAttribute(id: "tvRating", name: L10n.tvRating, options: tvRatingOptions),
				WatchFilterAttribute(id: "isFiller", name: L10n.fillers, options: shownHiddenOptions),
				WatchFilterAttribute(id: "isPremiere", name: L10n.premieres, options: shownHiddenOptions),
				WatchFilterAttribute(id: "isFinale", name: L10n.finales, options: shownHiddenOptions),
				WatchFilterAttribute(id: "isSpecial", name: L10n.specials, options: shownHiddenOptions),
			]
		case .characters:
			return [
				WatchFilterAttribute(id: "status", name: L10n.status, options: characterStatusOptions),
				WatchFilterAttribute(id: "astrologicalSign", name: L10n.astrologicalSign, options: astrologicalSignOptions),
			]
		case .people:
			return [
				WatchFilterAttribute(id: "astrologicalSign", name: L10n.astrologicalSign, options: astrologicalSignOptions),
			]
		case .studios:
			return [
				WatchFilterAttribute(id: "type", name: L10n.type, options: studioTypeOptions),
				WatchFilterAttribute(id: "tvRating", name: L10n.tvRating, options: tvRatingOptions),
			]
		case .songs, .users:
			return []
		}
	}

	/// Constructs a `SearchFilter` from the current attribute selections.
	static func buildFilter(from attributes: [WatchFilterAttribute], for type: SearchType) -> SearchFilter? {
		let selected = attributes.filter { $0.selectedValue != nil }
		guard !selected.isEmpty else { return nil }

		func value(for id: String) -> Int? {
			attributes.first(where: { $0.id == id })?.selectedValue
		}

		switch type {
		case .shows:
			return .show(ShowFilter(
				airDay: value(for: "airDay"),
				airSeason: value(for: "airSeason"),
				mediaType: value(for: "mediaType"),
				source: value(for: "source"),
				status: value(for: "status"),
				tvRating: value(for: "tvRating")
			))
		case .literatures:
			return .literature(LiteratureFilter(
				publicationDay: value(for: "publicationDay"),
				publicationSeason: value(for: "publicationSeason"),
				mediaType: value(for: "mediaType"),
				source: value(for: "source"),
				status: value(for: "status"),
				tvRating: value(for: "tvRating")
			))
		case .games:
			return .game(GameFilter(
				publicationDay: value(for: "publicationDay"),
				publicationSeason: value(for: "publicationSeason"),
				mediaType: value(for: "mediaType"),
				source: value(for: "source"),
				status: value(for: "status"),
				tvRating: value(for: "tvRating")
			))
		case .episodes:
			return .episode(EpisodeFilter(
				isFiller: value(for: "isFiller").map { $0 == 1 },
				isSpecial: value(for: "isSpecial").map { $0 == 1 },
				isPremiere: value(for: "isPremiere").map { $0 == 1 },
				isFinale: value(for: "isFinale").map { $0 == 1 },
				tvRating: value(for: "tvRating")
			))
		case .characters:
			return .character(CharacterFilter(
				astrologicalSign: value(for: "astrologicalSign"),
				status: value(for: "status")
			))
		case .people:
			return .person(PersonFilter(
				astrologicalSign: value(for: "astrologicalSign")
			))
		case .studios:
			return .studio(StudioFilter(
				type: value(for: "type"),
				tvRating: value(for: "tvRating")
			))
		case .songs:
			return nil
		case .users:
			return nil
		}
	}
}

// MARK: - Filter Option Constants
private extension SearchFilterView {
	static let showTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: L10n.tv, value: 0),
		WatchFilterOption(id: 1, label: L10n.ova, value: 1),
		WatchFilterOption(id: 2, label: L10n.ona, value: 2),
		WatchFilterOption(id: 3, label: L10n.special, value: 3),
		WatchFilterOption(id: 4, label: L10n.movie, value: 4),
	]

	static let showStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: L10n.currentlyAiring, value: 0),
		WatchFilterOption(id: 1, label: L10n.finishedAiring, value: 1),
		WatchFilterOption(id: 2, label: L10n.notYetAired, value: 2),
	]

	static let literatureTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: L10n.manga, value: 0),
		WatchFilterOption(id: 1, label: L10n.lightNovel, value: 1),
		WatchFilterOption(id: 2, label: L10n.oneShot, value: 2),
	]

	static let literatureStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: L10n.currentlyPublishing, value: 0),
		WatchFilterOption(id: 1, label: L10n.finishedPublishing, value: 1),
		WatchFilterOption(id: 2, label: L10n.notYetPublished, value: 2),
	]

	static let gameTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: L10n.console, value: 0),
		WatchFilterOption(id: 1, label: L10n.pc, value: 1),
		WatchFilterOption(id: 2, label: L10n.mobile, value: 2),
	]

	static let gameStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: L10n.currentlyPublishing, value: 0),
		WatchFilterOption(id: 1, label: L10n.finishedPublishing, value: 1),
		WatchFilterOption(id: 2, label: L10n.notYetPublished, value: 2),
	]

	static let tvRatingOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: L10n.ratingG, value: 1),
		WatchFilterOption(id: 2, label: L10n.ratingPG, value: 2),
		WatchFilterOption(id: 3, label: L10n.ratingPG13, value: 3),
		WatchFilterOption(id: 4, label: L10n.ratingR17, value: 4),
		WatchFilterOption(id: 5, label: L10n.ratingRPlus, value: 5),
	]

	static let sourceTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: L10n.original, value: 1),
		WatchFilterOption(id: 2, label: L10n.manga, value: 2),
		WatchFilterOption(id: 3, label: L10n.lightNovel, value: 3),
		WatchFilterOption(id: 4, label: L10n.visualNovel, value: 4),
		WatchFilterOption(id: 5, label: L10n.game, value: 5),
		WatchFilterOption(id: 6, label: L10n.novel, value: 6),
		WatchFilterOption(id: 7, label: L10n.other, value: 7),
	]

	static var dayOfWeekOptions: [WatchFilterOption] {
		// The API numbers days Monday through Sunday, while the calendar's symbols start on Sunday.
		let symbols = Calendar.current.standaloneWeekdaySymbols

		return (1...7).map { day in
			WatchFilterOption(id: day, label: symbols[day % 7], value: day)
		}
	}

	static let seasonOfYearOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: L10n.winter, value: 0),
		WatchFilterOption(id: 1, label: L10n.spring, value: 1),
		WatchFilterOption(id: 2, label: L10n.summer, value: 2),
		WatchFilterOption(id: 3, label: L10n.fall, value: 3),
	]

	static let characterStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: L10n.alive, value: 1),
		WatchFilterOption(id: 2, label: L10n.deceased, value: 2),
		WatchFilterOption(id: 3, label: L10n.missing, value: 3),
		WatchFilterOption(id: 4, label: L10n.unknown, value: 4),
	]

	static let astrologicalSignOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: L10n.aries, value: 1),
		WatchFilterOption(id: 2, label: L10n.taurus, value: 2),
		WatchFilterOption(id: 3, label: L10n.gemini, value: 3),
		WatchFilterOption(id: 4, label: L10n.cancer, value: 4),
		WatchFilterOption(id: 5, label: L10n.leo, value: 5),
		WatchFilterOption(id: 6, label: L10n.virgo, value: 6),
		WatchFilterOption(id: 7, label: L10n.libra, value: 7),
		WatchFilterOption(id: 8, label: L10n.scorpio, value: 8),
		WatchFilterOption(id: 9, label: L10n.sagittarius, value: 9),
		WatchFilterOption(id: 10, label: L10n.capricorn, value: 10),
		WatchFilterOption(id: 11, label: L10n.aquarius, value: 11),
		WatchFilterOption(id: 12, label: L10n.pisces, value: 12),
	]

	static let shownHiddenOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: L10n.shown, value: 1),
		WatchFilterOption(id: 0, label: L10n.hidden, value: 0),
	]

	static let studioTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: L10n.animeStudio, value: 1),
		WatchFilterOption(id: 2, label: L10n.soundStudio, value: 2),
		WatchFilterOption(id: 3, label: L10n.network, value: 3),
	]
}
