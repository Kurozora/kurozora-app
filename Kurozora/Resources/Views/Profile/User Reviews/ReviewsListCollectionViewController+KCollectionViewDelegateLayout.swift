//
//  ReviewsListCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

extension ReviewsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0
		if width >= 414.0 {
			columnCount = (width / 384.0).rounded().int
		} else {
			columnCount = (width / 284.0).rounded().int
		}
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.usersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
		return layout
	}
}
