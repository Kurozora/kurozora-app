//
//  GaussianBlur.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import QuartzCore

/// A factory for `gaussianBlur` layer filters.
struct GaussianBlur {
	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Creates a `gaussianBlur` filter with the given radius.
	///
	/// - Parameter radius: The blur radius in points.
	///
	/// - Returns: The configured filter.
	static func filter(radius: CGFloat) -> NSObject? {
		guard let filterClass = NSClassFromString("CAFilter") else { return nil }

		let selector = NSSelectorFromString("filterWithName:")
		guard let unmanaged = (filterClass as AnyObject).perform(selector, with: "gaussianBlur") else { return nil }
		guard let filter = unmanaged.takeUnretainedValue() as? NSObject else { return nil }

		filter.setValue(radius, forKey: "inputRadius")
		return filter
	}
}
