//
//  MuseumHallLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A horizontal compositional layout that caps its content height at the hall's column height.
class MuseumHallLayout: UICollectionViewCompositionalLayout {
	// MARK: - Properties
	/// Returns the hall's current column height.
	var columnHeightProvider: (() -> CGFloat)?

	// MARK: - Functions
	override var collectionViewContentSize: CGSize {
		var contentSize = super.collectionViewContentSize

		if let columnHeight = self.columnHeightProvider?() {
			contentSize.height = min(contentSize.height, columnHeight)
		}

		return contentSize
	}
}
