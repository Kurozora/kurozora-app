//
//  FilterDescriptor.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

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
