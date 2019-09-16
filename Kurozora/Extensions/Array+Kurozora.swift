//
//  Array+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Foundation

extension Array {
	/**
		Find the colsest match to the given predicate in an array with the given start index.

		- Parameter index: The index where the search should start from.
		- Parameter predicate: The logic which should be matched.
		- Parameter element: The element that is being checked for a match.

		- Returns: the index where a match has been found and the item that has matched the predicate.
	*/
	func closestMatch(index: Index, predicate: (_ element: Element) -> Bool) -> (Int, Element)? {
		if predicate(self[index]) {
			return (index, self[index])
		}

		var delta = 1

		while true {
			guard index + delta < count || index - delta >= 0 else {
				return nil
			}

			if index + delta < count && predicate(self[index + delta]) {
				return (index + delta, self[index + delta])
			}

			if index - delta >= 0 && predicate(self[index - delta]) {
				return (index - delta, self[index - delta])
			}

			delta += 1
		}
	}
}
