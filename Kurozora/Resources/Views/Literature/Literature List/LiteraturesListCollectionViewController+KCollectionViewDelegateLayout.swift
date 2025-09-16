//
//  LiteraturesListCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

extension LiteraturesListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)

			if self.literaturesListFetchType == .upcoming {
				return Layouts.upcomingSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
			}

			return Layouts.smallSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}
