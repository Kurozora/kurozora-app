//
//  Collection+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation

extension Collection {
	/// Safe protects the array from out of bounds by use of optional.
	///
	/// ```swift
	/// let arr = [1, 2, 3, 4, 5]
	/// arr[safe: 1] -> 2
	/// arr[safe: 10] -> nil
	/// ```
	///
	/// - Parameter index: index of element to access element.
	///
	/// - Returns: <Element> at index if it exists, otherwise nil.
	subscript(safe index: Index) -> Element? {
		return self.indices.contains(index) ? self[index] : nil
	}
}
