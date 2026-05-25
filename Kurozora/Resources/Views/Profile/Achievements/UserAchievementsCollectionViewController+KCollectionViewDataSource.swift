//
//  UserAchievementsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension UserAchievementsCollectionViewController {
	override func configureDataSource() {
		let achievementCellRegistration = UICollectionView.CellRegistration<AchievementLockupCollectionViewCell, Achievement> { cell, _, achievement in
			cell.configure(using: achievement)
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Achievement>(collectionView: self.collectionView) { collectionView, indexPath, achievement in
			return collectionView.dequeueConfiguredReusableCell(using: achievementCellRegistration, for: indexPath, item: achievement)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Achievement>()
		self.snapshot.appendSections([.main])
		self.snapshot.appendItems(self.achievements, toSection: .main)
		self.dataSource.apply(self.snapshot)
	}
}
