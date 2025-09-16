//
//  CastListCollectionViewController+KCollectionViewDelegateLayout.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension CastListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount: Int

		switch self.castKind {
		case .show, .game:
			columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		case .literature:
			columnCount = Int((width / 140.0).rounded())
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.castSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}
