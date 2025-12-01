//
//  Array+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension Array {
	// MARK: - Functions
	/// Find the colsest match to the given predicate in an array with the given start index.
	///
	/// - Parameters:
	///    - index: The index where the search should start from.
	///    - predicate: The logic which should be matched.
	///    - element: The element that is being checked for a match.
	///
	/// - Returns: the index where a match has been found and the item that has matched the predicate.
	func closestMatch(index: Index, predicate: (_ element: Element) -> Bool) -> (Int, Element)? {
		if predicate(self[index]) {
			return (index, self[index])
		}

		var delta = 1

		while true {
			guard index + delta < self.count || index - delta >= 0 else {
				return nil
			}

			if index + delta < self.count, predicate(self[index + delta]) {
				return (index + delta, self[index + delta])
			}

			if index - delta >= 0, predicate(self[index - delta]) {
				return (index - delta, self[index - delta])
			}

			delta += 1
		}
	}

	/// Rotate the collection by the given places.
	///
	/// ```swift
	/// [1, 2, 3, 4].rotate(by: 1) -> [4,1,2,3]
	/// [1, 2, 3, 4].rotate(by: 3) -> [2,3,4,1]
	/// [1, 2, 3, 4].rotated(by: -1) -> [2,3,4,1]
	/// ```
	///
	/// - Parameter places: The number of places that the array should be rotated.
	///
	///     If the value is positive, the end becomes the start. If the value is negative, the start becomes the end.
	///
	/// - Returns: self after rotating.
	mutating func rotate(by places: Int) -> Self {
		guard places != 0 else { return self }
		let placesToMove = places % count

		if placesToMove > 0 {
			let range = self.index(endIndex, offsetBy: -placesToMove)...
			let slice = self[range]

			self.removeSubrange(range)
			self.insert(contentsOf: slice, at: startIndex)
		} else {
			let range = startIndex ..< self.index(startIndex, offsetBy: -placesToMove)
			let slice = self[range]

			self.removeSubrange(range)
			self.append(contentsOf: slice)
		}

		return self
	}

	/// Removes the first element of the collection which satisfies the given predicate.
	///
	/// ```swift
	/// [1, 2, 2, 3, 4, 2, 5].removeFirst { $0 % 2 == 0 } -> [1, 2, 3, 4, 2, 5]
	/// ["h", "e", "l", "l", "o"].removeFirst { $0 == "e" } -> ["h", "l", "l", "o"]
	/// ```
	///
	/// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
	///
	/// - Returns: The first element for which predicate returns true, after removing it. If no elements in the
	/// collection satisfy the given predicate, returns `nil`.
	@discardableResult
	mutating func removeFirst(where predicate: (Element) throws -> Bool) rethrows -> Element? {
		guard let index = try firstIndex(where: predicate) else { return nil }
		return remove(at: index)
	}

	/// Splits the collection into consecutive chunks of the given size.
	///
	/// ```swift
	/// [1, 2, 3, 4, 5].chunked(into: 2)
	/// // [[1, 2], [3, 4], [5]]
	/// ```
	///
	/// - Parameter size: The maximum number of elements in each chunk.
	///   If `size` is less than or equal to zero, the entire collection is
	///   returned as a single chunk.
	///
	/// - Returns: An array of arrays, where each inner array contains up to
	///   `size` elements from the original collection, in order.
	///
	/// - Complexity: O(n)
	@inlinable
	func chunked(into size: Int) -> [[Element]] {
		guard size > 0 else { return [self] }
		return stride(from: 0, to: count, by: size).map {
			Array(self[$0 ..< Swift.min($0 + size, count)])
		}
	}
}

// MARK: - Hashable
public extension Array where Element: Hashable {
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
	@inlinable
	mutating func appendDistinct<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
		// Track elements already in the array
		var existingElements = Set(self) // O(n)

		// Append new elements that are not already present
		for element in newElements where existingElements.insert(element).inserted { // O(1) on average
			self.append(element) // O(1) amortized
		}
	}
}

// MARK: - Equatable
extension Array where Element: Equatable {
	/// Remove all duplicate elements from Array.
	///
	/// ```swift
	/// [1, 2, 2, 3, 4, 5].removeDuplicates() -> [1, 2, 3, 4, 5]
	/// ["h", "e", "l", "l", "o"]. removeDuplicates() -> ["h", "e", "l", "o"]
	/// ```
	///
	/// - Returns: Return array with all duplicate elements removed.
	@discardableResult
	mutating func removeDuplicates() -> [Element] {
		// Thanks to https://github.com/sairamkotha for improving the method
		self = reduce(into: [Element]()) {
			if !$0.contains($1) {
				$0.append($1)
			}
		}
		return self
	}
}

// MARK: - String
extension Array where Element == String {
	// MARK: - Functions
	/// Find and return all elements matching the given regex within the array.
	///
	/// - Parameter regex: The regex used to find a match within the array.
	///
	/// - Returns: the elements where a match has been found.
	func matching(regex: String) -> ([Element]) {
		return self.filter { element in
			do {
				let regex = try NSRegularExpression(pattern: regex)

				let matches = regex.matches(in: element, range: NSRange(location: 0, length: element.count))
				return !matches.isEmpty
			} catch {}

			return false
		}
	}

	/// Constructs a formatted string from an array of strings that uses the list format specific to the current locale.
	///
	/// - Returns: A formatted string that joins together a list of strings using a locale-specific list format.
	func localizedJoined() -> String {
		return ListFormatter.localizedString(byJoining: self)
	}
}
