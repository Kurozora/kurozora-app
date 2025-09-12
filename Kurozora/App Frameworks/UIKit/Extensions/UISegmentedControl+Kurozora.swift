//
//  UISegmentedControl+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit

extension UISegmentedControl {
	/// An array of titles for all segments in the segmented control.
	var segmentTitles: [String] {
		get {
			let range = 0 ..< self.numberOfSegments
			return range.compactMap { self.titleForSegment(at: $0) }
		}
		set {
			self.removeAllSegments()

			for (index, title) in newValue.enumerated() {
				self.insertSegment(withTitle: title, at: index, animated: false)
			}
		}
	}
}
