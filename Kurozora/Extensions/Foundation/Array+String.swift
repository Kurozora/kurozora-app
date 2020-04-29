//
//  Array+String.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

extension Array where Element == String {
	// MARK: - Functions
	/**
		Find and return all elements matching the given regex within the array.

		- Parameter regex: The regex used to find a match within the array.

		- Returns: the elements where a match has been found.
	*/
	func matching(regex: String) -> ([Element]) {
		let matches = self.filter { element in
			do {
				let regex = try NSRegularExpression(pattern: regex)

				let matches = regex.matches(in: element, range: NSRange(location: 0, length: element.count))
				return !matches.isEmpty
			} catch { }

			return false
		}

		return matches
	}
}
