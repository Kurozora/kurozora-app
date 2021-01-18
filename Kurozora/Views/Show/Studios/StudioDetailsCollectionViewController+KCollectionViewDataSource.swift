//
//  StudioDetailsCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension StudioDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			InformationCollectionViewCell.self,
			InformationButtonCollectionViewCell.self,
			SmallLockupCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<StudioDetailsSection, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			let studioDetailsSection = StudioDetailsSection(rawValue: indexPath.section) ?? .main
			let reuseIdentifier = studioDetailsSection.identifierString(for: indexPath.item)
			let studioCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

			switch studioDetailsSection {
			case .main:
				(studioCollectionViewCell as? StudioHeaderCollectionViewCell)?.studio = self.studio
			case .about:
				let textViewCollectionViewCell = studioCollectionViewCell as? TextViewCollectionViewCell
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				textViewCollectionViewCell?.textViewContent = self.studio.attributes.about
			case .information:
				if let informationCollectionViewCell = studioCollectionViewCell as? InformationCollectionViewCell {
					informationCollectionViewCell.studioDetailsInformationSection = StudioDetailsInformationSection(rawValue: indexPath.item) ?? .founded
					informationCollectionViewCell.studio = self.studio
				} else if let informationButtonCollectionViewCell = studioCollectionViewCell as? InformationButtonCollectionViewCell {
					informationButtonCollectionViewCell.studioDetailsInformationSection = StudioDetailsInformationSection(rawValue: indexPath.item) ?? .website
					informationButtonCollectionViewCell.studio = self.studio
				}
			case .shows:
				(studioCollectionViewCell as? SmallLockupCollectionViewCell)?.show = self.shows[indexPath.item]
			}

			return studioCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let studioDetailsSection = StudioDetailsSection(rawValue: indexPath.section) ?? .main
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.segueID = studioDetailsSection.segueIdentifier
			titleHeaderCollectionReusableView.indexPath = indexPath
			titleHeaderCollectionReusableView.title = studioDetailsSection.stringValue
			return titleHeaderCollectionReusableView
		}

		var snapshot = NSDiffableDataSourceSnapshot<StudioDetailsSection, Int>()
		StudioDetailsSection.allCases.forEach {
			snapshot.appendSections([$0])
			let rowCount = $0 == .shows ? self.shows.count : $0.rowCount
			let itemOffset = $0.rawValue * rowCount
			let itemUpperbound = itemOffset + rowCount
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
	}
}
