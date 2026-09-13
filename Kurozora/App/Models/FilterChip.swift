//
//  FilterChip.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

// MARK: - FilterChip
/// A single choice the user has applied to a search.
struct FilterChip {
	// MARK: - Properties
	/// The attribute the choice belongs to.
	let key: FilterKey

	/// The name of the choice.
	let optionTitle: String

	/// The name of the attribute.
	let filterTitle: String

	/// Whether a result is rejected for the choice.
	let isExcluded: Bool

	/// What the chip clears.
	let removal: FilterChipRemoval

	/// Whether the choice needs the attribute's name to stand on its own.
	let needsTitle: Bool

	// MARK: - Functions
	/// The chip's text.
	///
	/// - Parameter includesFilterTitle: Whether the attribute's name leads the text.
	///
	/// - Returns: The text the chip shows.
	func title(includesFilterTitle: Bool) -> NSAttributedString {
		let title = NSMutableAttributedString()

		if includesFilterTitle {
			title.append(NSAttributedString(string: "\(self.filterTitle): "))
		}

		title.append(NSAttributedString(string: self.optionTitle, attributes: self.isExcluded ? [
			.strikethroughStyle: NSUnderlineStyle.single.rawValue
		] : [:]))

		return title
	}
}

// MARK: - FilterChipRemoval
/// What tapping a chip clears.
enum FilterChipRemoval: Hashable {
	// MARK: - Cases
	/// Indicates the whole attribute is cleared.
	case wholeKey

	/// Indicates one numeric choice is cleared.
	case number(Int)

	/// Indicates one textual choice is cleared.
	case text(String)
}
