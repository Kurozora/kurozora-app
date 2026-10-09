//
//  LocalTrackable+Filtering.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

// MARK: - Filtering
extension LocalTrackable {
	// MARK: - Functions
	/// Whether the trackable satisfies the given filter.
	///
	/// - Parameter filter: The filter the user applied.
	///
	/// - Returns: `true` when every set attribute of the filter matches.
	func matches(_ filter: SearchFilter) -> Bool {
		return filter.values.allSatisfy { key, value in
			self.matches(value, for: key)
		}
	}

	/// Whether the trackable satisfies the given attribute.
	///
	/// - Parameters:
	///    - value: The value the user chose.
	///    - key: The attribute the value belongs to.
	///
	/// - Returns: `true` when the trackable's own value satisfies the choice.
	private func matches(_ value: FilterValue, for key: FilterKey) -> Bool {
		guard !value.isEmpty else { return true }

		switch value {
		case .selection(let selection):
			guard let actual = self.number(for: key) else { return selection.included.isEmpty }

			return Self.matches(selection, actual)
		case .textSelection(let selection):
			guard let actual = self.text(for: key) else { return selection.included.isEmpty }

			return Self.matches(selection, actual)
		case .range(let range):
			guard let actual = self.number(for: key) else { return false }

			return range.contains(actual)
		case .boolean(let expected):
			return self.number(for: key).map { $0 == 1 } == expected
		case .date(let expected):
			guard let actual = self.date(for: key) else { return false }

			return Calendar.current.isDate(actual, inSameDayAs: Date(timeIntervalSince1970: expected))
		case .text, .rating:
			return true
		}
	}

	/// The trackable's numeric value for the given attribute.
	///
	/// - Parameter key: The attribute to read.
	///
	/// - Returns: The trackable's value.
	private func number(for key: FilterKey) -> Int? {
		switch key {
		case .mediaType: return self.mediaTypeID?.intValue
		case .status: return self.statusID?.intValue
		case .tvRating: return self.tvRatingID?.intValue
		case .source: return self.sourceID?.intValue
		case .isNSFW: return self.isNSFW.map { $0.boolValue ? 1 : 0 }
		case .airDay, .publicationDay: return self.displayedScheduleDay
		case .airSeason, .publicationSeason: return self.scheduleSeason?.intValue
		case .airTime, .publicationTime: return self.displayedDayPart
		case .duration: return self.durationCount?.intValue
		case .seasonCount, .volumeCount: return self.seasonCount?.intValue
		case .episodeCount, .chapterCount, .editionCount: return self.episodeCount?.intValue
		default: return nil
		}
	}

	/// The trackable's textual value for the given attribute.
	///
	/// - Parameter key: The attribute to read.
	///
	/// - Returns: The trackable's value.
	private func text(for key: FilterKey) -> String? {
		switch key {
		case .countryOfOrigin: return self.countryOfOrigin
		default: return nil
		}
	}

	/// The trackable's date for the given attribute.
	///
	/// - Parameter key: The attribute to read.
	///
	/// - Returns: The trackable's value.
	private func date(for key: FilterKey) -> Date? {
		switch key {
		case .startedAt, .publishedAt: return self.firstAired
		case .endedAt: return self.lastAired
		default: return nil
		}
	}

	// MARK: - Helpers
	/// The weekday the trackable's schedule reads in the current time zone.
	private var displayedScheduleDay: Int? {
		guard let airingDate = self.airingDate else { return self.scheduleDay?.intValue }

		return Calendar.current.component(.weekday, from: airingDate) - 1
	}

	/// The part of the day the trackable's schedule reads in the current time zone.
	private var displayedDayPart: Int? {
		guard let airingDate = self.airingDate else { return nil }

		let hour = Calendar.current.component(.hour, from: airingDate)

		return DayPart.allCases.first { $0.contains(hour: hour) }?.rawValue
	}

	private static func matches<Value>(_ selection: FilterSelection<Value>, _ actual: Value) -> Bool {
		if selection.excluded.contains(actual) {
			return false
		}

		return selection.included.isEmpty || selection.included.contains(actual)
	}
}
