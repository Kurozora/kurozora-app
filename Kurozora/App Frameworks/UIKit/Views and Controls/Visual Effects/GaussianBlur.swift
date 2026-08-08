//
//  GaussianBlur.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Obfuscation
import QuartzCore

/// A factory for blur layer filters.
struct GaussianBlur {
	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Creates a `gaussianBlur` filter with the given radius.
	///
	/// - Parameters:
	///    - radius: The blur radius in points.
	///    - normalizesEdges: Whether the kernel clamps at the layer's bounds.
	///
	/// - Returns: The configured filter.
	static func filter(radius: CGFloat, normalizesEdges: Bool = false) -> NSObject? {
		guard let filterClass = NSClassFromString("CAFilter") else { return nil }

		let selector = NSSelectorFromString("filterWithName:")
		guard let unmanaged = (filterClass as AnyObject).perform(selector, with: "gaussianBlur") else { return nil }
		guard let filter = unmanaged.takeUnretainedValue() as? NSObject else { return nil }

		filter.setValue(radius, forKey: "inputRadius")

		if normalizesEdges {
			filter.setValue(true, forKey: #obfuscated("inputNormalizeEdges"))
		}

		return filter
	}
}
