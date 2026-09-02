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
	let viewModel: SearchViewModel
	@Binding var isPresented: Bool
	@State private var attributes: [WatchFilterAttribute] = []

	// MARK: - Body
	var body: some View {
		NavigationStack {
			List {
				ForEach(self.$attributes) { $attribute in
					Picker(attribute.name, selection: $attribute.selectedValue) {
						Text("Any").tag(nil as Int?)
						ForEach(attribute.options) { option in
							Text(option.label).tag(option.value as Int?)
						}
					}
					.font(.caption)
				}

				Section {
					Button("Apply") {
						self.applyFilter()
					}
					Button("Reset", role: .destructive) {
						self.resetFilter()
					}
				}
			}
			.navigationTitle("Filters")
			.onAppear {
				self.attributes = Self.filterAttributes(for: self.viewModel.selectedTab)
			}
		}
	}

	// MARK: - Private
	private func applyFilter() {
		if let filter = Self.buildFilter(from: self.attributes, for: self.viewModel.selectedTab) {
			self.viewModel.activeFilters[self.viewModel.selectedTab] = filter
		}
		self.isPresented = false
		Task { await self.viewModel.submitSearch() }
	}

	private func resetFilter() {
		self.viewModel.activeFilters.removeValue(forKey: self.viewModel.selectedTab)
		self.isPresented = false
		Task { await self.viewModel.submitSearch() }
	}

	// MARK: - Filter Attribute Definitions
	/// Returns the filterable attributes (single-selection only) for the given search type.
	static func filterAttributes(for type: SearchType) -> [WatchFilterAttribute] {
		switch type {
		case .shows:
			return [
				WatchFilterAttribute(id: "mediaType", name: "Media Type", options: showTypeOptions),
				WatchFilterAttribute(id: "status", name: "Status", options: showStatusOptions),
				WatchFilterAttribute(id: "tvRating", name: "TV Rating", options: tvRatingOptions),
				WatchFilterAttribute(id: "source", name: "Source", options: sourceTypeOptions),
				WatchFilterAttribute(id: "airDay", name: "Air Day", options: dayOfWeekOptions),
				WatchFilterAttribute(id: "airSeason", name: "Air Season", options: seasonOfYearOptions),
			]
		case .literatures:
			return [
				WatchFilterAttribute(id: "mediaType", name: "Media Type", options: literatureTypeOptions),
				WatchFilterAttribute(id: "status", name: "Status", options: literatureStatusOptions),
				WatchFilterAttribute(id: "tvRating", name: "TV Rating", options: tvRatingOptions),
				WatchFilterAttribute(id: "source", name: "Source", options: sourceTypeOptions),
				WatchFilterAttribute(id: "publicationDay", name: "Publication Day", options: dayOfWeekOptions),
				WatchFilterAttribute(id: "publicationSeason", name: "Publication Season", options: seasonOfYearOptions),
			]
		case .games:
			return [
				WatchFilterAttribute(id: "mediaType", name: "Media Type", options: gameTypeOptions),
				WatchFilterAttribute(id: "status", name: "Status", options: gameStatusOptions),
				WatchFilterAttribute(id: "tvRating", name: "TV Rating", options: tvRatingOptions),
				WatchFilterAttribute(id: "source", name: "Source", options: sourceTypeOptions),
				WatchFilterAttribute(id: "publicationDay", name: "Publication Day", options: dayOfWeekOptions),
				WatchFilterAttribute(id: "publicationSeason", name: "Publication Season", options: seasonOfYearOptions),
			]
		case .episodes:
			return [
				WatchFilterAttribute(id: "tvRating", name: "TV Rating", options: tvRatingOptions),
				WatchFilterAttribute(id: "isFiller", name: "Fillers", options: shownHiddenOptions),
				WatchFilterAttribute(id: "isPremiere", name: "Premieres", options: shownHiddenOptions),
				WatchFilterAttribute(id: "isFinale", name: "Finales", options: shownHiddenOptions),
				WatchFilterAttribute(id: "isSpecial", name: "Specials", options: shownHiddenOptions),
			]
		case .characters:
			return [
				WatchFilterAttribute(id: "status", name: "Status", options: characterStatusOptions),
				WatchFilterAttribute(id: "astrologicalSign", name: "Astrological Sign", options: astrologicalSignOptions),
			]
		case .people:
			return [
				WatchFilterAttribute(id: "astrologicalSign", name: "Astrological Sign", options: astrologicalSignOptions),
			]
		case .studios:
			return [
				WatchFilterAttribute(id: "type", name: "Type", options: studioTypeOptions),
				WatchFilterAttribute(id: "tvRating", name: "TV Rating", options: tvRatingOptions),
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
		WatchFilterOption(id: 0, label: "TV", value: 0),
		WatchFilterOption(id: 1, label: "OVA", value: 1),
		WatchFilterOption(id: 2, label: "ONA", value: 2),
		WatchFilterOption(id: 3, label: "Special", value: 3),
		WatchFilterOption(id: 4, label: "Movie", value: 4),
	]

	static let showStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: "Currently Airing", value: 0),
		WatchFilterOption(id: 1, label: "Finished Airing", value: 1),
		WatchFilterOption(id: 2, label: "Not Yet Aired", value: 2),
	]

	static let literatureTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: "Manga", value: 0),
		WatchFilterOption(id: 1, label: "Light Novel", value: 1),
		WatchFilterOption(id: 2, label: "One Shot", value: 2),
	]

	static let literatureStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: "Currently Publishing", value: 0),
		WatchFilterOption(id: 1, label: "Finished Publishing", value: 1),
		WatchFilterOption(id: 2, label: "Not Yet Published", value: 2),
	]

	static let gameTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: "Console", value: 0),
		WatchFilterOption(id: 1, label: "PC", value: 1),
		WatchFilterOption(id: 2, label: "Mobile", value: 2),
	]

	static let gameStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: "Currently Publishing", value: 0),
		WatchFilterOption(id: 1, label: "Finished Publishing", value: 1),
		WatchFilterOption(id: 2, label: "Not Yet Published", value: 2),
	]

	static let tvRatingOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: "G", value: 1),
		WatchFilterOption(id: 2, label: "PG", value: 2),
		WatchFilterOption(id: 3, label: "PG-13", value: 3),
		WatchFilterOption(id: 4, label: "R - 17+", value: 4),
		WatchFilterOption(id: 5, label: "R+", value: 5),
	]

	static let sourceTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: "Original", value: 1),
		WatchFilterOption(id: 2, label: "Manga", value: 2),
		WatchFilterOption(id: 3, label: "Light Novel", value: 3),
		WatchFilterOption(id: 4, label: "Visual Novel", value: 4),
		WatchFilterOption(id: 5, label: "Game", value: 5),
		WatchFilterOption(id: 6, label: "Novel", value: 6),
		WatchFilterOption(id: 7, label: "Other", value: 7),
	]

	static let dayOfWeekOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: "Monday", value: 1),
		WatchFilterOption(id: 2, label: "Tuesday", value: 2),
		WatchFilterOption(id: 3, label: "Wednesday", value: 3),
		WatchFilterOption(id: 4, label: "Thursday", value: 4),
		WatchFilterOption(id: 5, label: "Friday", value: 5),
		WatchFilterOption(id: 6, label: "Saturday", value: 6),
		WatchFilterOption(id: 7, label: "Sunday", value: 7),
	]

	static let seasonOfYearOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 0, label: "Winter", value: 0),
		WatchFilterOption(id: 1, label: "Spring", value: 1),
		WatchFilterOption(id: 2, label: "Summer", value: 2),
		WatchFilterOption(id: 3, label: "Fall", value: 3),
	]

	static let characterStatusOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: "Alive", value: 1),
		WatchFilterOption(id: 2, label: "Deceased", value: 2),
		WatchFilterOption(id: 3, label: "Missing", value: 3),
		WatchFilterOption(id: 4, label: "Unknown", value: 4),
	]

	static let astrologicalSignOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: "Aries ♈", value: 1),
		WatchFilterOption(id: 2, label: "Taurus ♉", value: 2),
		WatchFilterOption(id: 3, label: "Gemini ♊", value: 3),
		WatchFilterOption(id: 4, label: "Cancer ♋", value: 4),
		WatchFilterOption(id: 5, label: "Leo ♌", value: 5),
		WatchFilterOption(id: 6, label: "Virgo ♍", value: 6),
		WatchFilterOption(id: 7, label: "Libra ♎", value: 7),
		WatchFilterOption(id: 8, label: "Scorpio ♏", value: 8),
		WatchFilterOption(id: 9, label: "Sagittarius ♐", value: 9),
		WatchFilterOption(id: 10, label: "Capricorn ♑", value: 10),
		WatchFilterOption(id: 11, label: "Aquarius ♒", value: 11),
		WatchFilterOption(id: 12, label: "Pisces ♓", value: 12),
	]

	static let shownHiddenOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: "Shown", value: 1),
		WatchFilterOption(id: 0, label: "Hidden", value: 0),
	]

	static let studioTypeOptions: [WatchFilterOption] = [
		WatchFilterOption(id: 1, label: "Anime Studio", value: 1),
		WatchFilterOption(id: 2, label: "Sound Studio", value: 2),
		WatchFilterOption(id: 3, label: "Network", value: 3),
	]
}
