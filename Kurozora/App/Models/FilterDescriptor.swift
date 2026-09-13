//
//  FilterDescriptor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import UIKit

// MARK: - FilterDescriptor
/// A filter the user can set on a search.
struct FilterDescriptor {
	// MARK: - Properties
	/// The attribute the filter writes.
	let key: FilterKey

	/// The name shown for the filter.
	let title: String

	/// The control the filter is set with.
	let control: FilterControl
}

// MARK: - Chips
extension FilterDescriptor {
	/// The chips standing for the given value.
	///
	/// - Parameter value: The value the user set.
	///
	/// - Returns: One chip per choice the user made.
	func chips(for value: FilterValue) -> [FilterChip] {
		switch (self.control, value) {
		case (.numberPills(let options), .selection(let selection)):
			return options.compactMap { option in
				let state = selection.state(of: option.value)
				guard state != .neutral else { return nil }

				return self.chip(option.title, isExcluded: state == .excluded, removal: .number(option.value))
			}
		case (.textPills(let options), .textSelection(let selection)):
			return options.compactMap { option in
				let state = selection.state(of: option.value)
				guard state != .neutral else { return nil }

				return self.chip(option.title, isExcluded: state == .excluded, removal: .text(option.value))
			}
		case (.booleanPills(let trueTitle, let falseTitle), .boolean(let boolean)):
			return [self.chip(boolean ? trueTitle : falseTitle, isExcluded: false, removal: .wholeKey)]
		case (.buckets(let buckets), .range(let range)):
			guard let bucket = buckets.first(where: { $0.range == range }) else { return [] }

			return [self.chip(bucket.title, isExcluded: false, removal: .wholeKey)]
		case (.duration, .range(let range)):
			guard let maximum = range.maximum else { return [] }

			let parts = SearchFilterDurationCollectionViewCell.parts(of: TimeInterval(maximum))
			return [self.chip(L10n.underDuration("\(parts.0) \(parts.1)"), isExcluded: false, removal: .wholeKey)]
		case (.date, .date(let timeInterval)):
			let date = Self.dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval))
			return [self.chip(date, isExcluded: false, removal: .wholeKey)]
		case (.text, .text(let text)):
			return [self.chip(text, isExcluded: false, removal: .wholeKey)]
		default:
			return []
		}
	}

	/// Whether a choice needs the filter's name to stand on its own.
	var needsTitleInChip: Bool {
		switch self.control {
		case .booleanPills, .buckets, .date, .text:
			return true
		case .numberPills, .textPills, .duration:
			return false
		}
	}

	/// Returns a chip carrying the given choice.
	///
	/// - Parameters:
	///    - optionTitle: The name of the choice.
	///    - isExcluded: Whether a result is rejected for the choice.
	///    - removal: What the chip clears.
	///
	/// - Returns: The chip standing for the choice.
	private func chip(_ optionTitle: String, isExcluded: Bool, removal: FilterChipRemoval) -> FilterChip {
		return FilterChip(
			key: self.key,
			optionTitle: optionTitle,
			filterTitle: self.title,
			isExcluded: isExcluded,
			removal: removal,
			needsTitle: self.needsTitleInChip
		)
	}

	/// The names of every choice the filter offers.
	var optionTitles: [String] {
		switch self.control {
		case .numberPills(let options):
			return options.map { $0.title }
		case .textPills(let options):
			return options.map { $0.title }
		case .booleanPills(let trueTitle, let falseTitle):
			return [trueTitle, falseTitle]
		case .buckets(let buckets):
			return buckets.map { $0.title }
		case .duration, .date, .text:
			return []
		}
	}

	/// The formatter that writes a chosen date.
	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = LanguageManager.shared.locale
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
}

// MARK: - FilterControl
/// The control a filter is set with.
enum FilterControl {
	// MARK: - Cases
	/// Indicates a row of pills over numeric options.
	case numberPills([FilterOption<Int>])

	/// Indicates a row of pills over textual options.
	case textPills([FilterOption<String>])

	/// Indicates a pair of pills over a yes or no choice.
	case booleanPills(trueTitle: String, falseTitle: String)

	/// Indicates a menu of named number ranges.
	case buckets([FilterBucket])

	/// Indicates a clock of durations in seconds.
	case duration([TimeInterval])

	/// Indicates a row presenting a date picker.
	case date

	/// Indicates a free text field.
	case text

	// MARK: - Properties
	/// Whether the control is presented as a row inside the details card.
	var isRow: Bool {
		switch self {
		case .buckets, .date, .text:
			return true
		case .numberPills, .textPills, .booleanPills, .duration:
			return false
		}
	}
}

// MARK: - FilterOption
/// A single choice within a filter.
struct FilterOption<Value: Hashable & Comparable & Sendable> {
	// MARK: - Properties
	/// The name shown for the choice.
	let title: String

	/// The detail shown under the name.
	let subtitle: String?

	/// The value the choice writes.
	let value: Value

	// MARK: - Initializers
	init(title: String, subtitle: String? = nil, value: Value) {
		self.title = title
		self.subtitle = subtitle
		self.value = value
	}
}

// MARK: - FilterBucket
/// A named range of numbers within a filter.
struct FilterBucket {
	// MARK: - Properties
	/// The name shown for the range.
	let title: String

	/// The range the name covers.
	let range: FilterRange

	// MARK: - Initializers
	init(title: String, minimum: Int? = nil, maximum: Int? = nil) {
		self.title = title
		self.range = FilterRange(minimum: minimum, maximum: maximum)
	}
}
