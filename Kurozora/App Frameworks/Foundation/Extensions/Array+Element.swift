//
//  Array+Element.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
	/// Adds the elements of a sequence to the end of the array if they are not already present.
	///
	/// Use this method to append the unique elements of a sequence to the end of this array.
	/// This example appends the elements of a `Range<Int>` instance to an array of integers.
	///
	/// ```swift
	/// var numbers = [1, 2, 3]
	/// numbers.appendDistinct(contentsOf: 1...5)
	/// print(numbers)
	/// // Prints "[1, 2, 3, 4, 5]"
	/// ```
	///
	/// - Parameter newElements: The elements to append to the array.
	///
	/// - Complexity: O(*n+m*),  where *n* is the length of the array and *m* is the length of `newElements`.
	@inlinable public mutating func appendDistinct<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
		// Track elements already in the array
		var existingElements = Set(self) // O(n)

		// Append new elements that are not already present
		newElements.forEach { element in
			if existingElements.insert(element).inserted { // O(1) on average
				self.append(element) // O(1) amortized
			}
		}
	}
}
