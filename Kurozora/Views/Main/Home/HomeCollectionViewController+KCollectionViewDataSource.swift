//
//  HomeCollectionViewController+KCollectionViewDataSource.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension HomeCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			SmallLockupCollectionViewCell.self,
			MediumLockupCollectionViewCell.self,
			LargeLockupCollectionViewCell.self,
			VideoLockupCollectionViewCell.self,
			LegalCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			if indexPath.section < self.exploreCategories.count {
				// Get a cell of the desired kind.
				let exploreCategorySize = indexPath.section != 0 ? self.exploreCategories[indexPath.section].attributes.exploreCategorySize : .banner
				guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCategorySize.identifierString, for: indexPath) as? BaseLockupCollectionViewCell
				else { fatalError("Cannot dequeue reusable cell with identifier \(exploreCategorySize.identifierString)") }

				// Populate the cell with our item description.
				let exploreCategoriesSection = self.exploreCategories[indexPath.section]
				if let shows = exploreCategoriesSection.relationships.shows?.data {
					baseLockupCollectionViewCell.show = shows[indexPath.row]
				} else {
					baseLockupCollectionViewCell.genre = exploreCategoriesSection.relationships.genres?.data[indexPath.row]
				}

				// Return the cell.
				return baseLockupCollectionViewCell
			}

			var verticalCollectionCellStyle: VerticalCollectionCellStyle = .actionList
			var actionsArray = self.actionsArray.first

			switch indexPath.section {
			case let section where section == collectionView.numberOfSections - 1: // If last section
				return self.createExploreCell(with: .legal, for: indexPath)
			case let section where section == collectionView.numberOfSections - 2: // If before last section
				verticalCollectionCellStyle = .actionButton
				actionsArray = self.actionsArray[1]
			default: break
			}

			let actionBaseExploreCollectionViewCell = self.createExploreCell(with: verticalCollectionCellStyle, for: indexPath) as? ActionBaseExploreCollectionViewCell
			actionBaseExploreCollectionViewCell?.actionItem = actionsArray?[indexPath.item]
			return actionBaseExploreCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let exploreCategoriesCount = self.exploreCategories.count

			// Get a supplementary view of the desired kind.
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			exploreSectionTitleCell.indexPath = indexPath

			if indexPath.section < exploreCategoriesCount {
				let sectionTitle = self.exploreCategories[indexPath.section].attributes.title
				if sectionTitle.contains("categories", caseSensitive: false) || sectionTitle.contains("genres", caseSensitive: false) {
					exploreSectionTitleCell.segueID = R.segue.homeCollectionViewController.genresSegue.identifier
				} else {
					exploreSectionTitleCell.segueID = R.segue.homeCollectionViewController.showsListSegue.identifier
				}
				exploreSectionTitleCell.title = self.exploreCategories[indexPath.section].attributes.title
			} else {
				exploreSectionTitleCell.segueID = ""
				exploreSectionTitleCell.title = "Quick Links"
			}

			// Return the view.
			return exploreSectionTitleCell
		}
	}

	override func updateDataSource() {
		let numberOfSections: Int = exploreCategories.count + 2

		// Initialize data
		self.snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
		var identifierOffset = 0
		var itemsPerSection = 0

		for section in 0...numberOfSections {
			if section < exploreCategories.count {
				let exploreCategoriesSection = exploreCategories[section]
				itemsPerSection = exploreCategoriesSection.relationships.shows?.data.count ?? 0
				if itemsPerSection == 0 {
					itemsPerSection = exploreCategoriesSection.relationships.genres?.data.count ?? 0
				}
			} else if section == numberOfSections - 2 {
				itemsPerSection = actionsArray.first?.count ?? itemsPerSection
			} else if section == numberOfSections - 1 {
				itemsPerSection = actionsArray[1].count
			} else {
				itemsPerSection = 1
			}

			snapshot.appendSections([section])
			let maxIdentifier = identifierOffset + itemsPerSection
			snapshot.appendItems(Array(identifierOffset..<maxIdentifier))
			identifierOffset += itemsPerSection
		}

		dataSource.apply(snapshot)
	}
}
