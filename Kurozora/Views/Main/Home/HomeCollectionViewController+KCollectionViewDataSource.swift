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
		self.dataSource = UICollectionViewDiffableDataSource<Int, ItemKind>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, item: ItemKind) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			if indexPath.section < self.exploreCategories.count {
				// Get a cell of the desired kind.
				let exploreCategorySize = indexPath.section != 0 ? self.exploreCategories[indexPath.section].attributes.exploreCategorySize : .banner
				guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: exploreCategorySize.identifierString, for: indexPath) as? BaseLockupCollectionViewCell
				else { fatalError("Cannot dequeue reusable cell with identifier \(exploreCategorySize.identifierString)") }

				// Populate the cell with our item description.
				switch item {
				case .show(let show):
					baseLockupCollectionViewCell.show = show
				case .genre(let genre):
					baseLockupCollectionViewCell.genre = genre
				default: break
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
			exploreSectionTitleCell.delegate = self
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
		self.snapshot = NSDiffableDataSourceSnapshot<Int, ItemKind>()
		var identifierOffset = 0
		var itemsPerSection = 0

		for section in 0...numberOfSections {
			snapshot.appendSections([section])

			if section < exploreCategories.count {
				let exploreCategoriesSection = exploreCategories[section]

				if let shows = exploreCategoriesSection.relationships.shows?.data {
					let showItems: [ItemKind] = shows.map { show in
						return .show(show)
					}
					snapshot.appendItems(showItems, toSection: section)
				} else if let genres = exploreCategoriesSection.relationships.genres?.data {
					let genreItems: [ItemKind] = genres.map { genre in
						return .genre(genre)
					}
					snapshot.appendItems(genreItems, toSection: section)
				}
			} else {
				// Get number of items per section
				if section == numberOfSections - 2 {
					itemsPerSection = actionsArray.first?.count ?? itemsPerSection
				} else if section == numberOfSections - 1 {
					itemsPerSection = actionsArray[1].count
				} else {
					itemsPerSection = 1
				}

				// Get max identifier
				let maxIdentifier = identifierOffset + itemsPerSection

				// Append items to section
				let otherItems: [ItemKind] = (identifierOffset..<maxIdentifier).map { index in
					return .other(index)
				}
				snapshot.appendItems(otherItems, toSection: section)

				// Update identifier offset
				identifierOffset += itemsPerSection
			}
		}

		dataSource.apply(snapshot)
	}
}
