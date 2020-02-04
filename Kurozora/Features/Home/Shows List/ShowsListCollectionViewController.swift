//
//  ShowsListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class ShowsListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var exploreCategory: ExploreCategory? {
		didSet {
			_prefersActivityIndicatorHidden = true
			collectionView.reloadData()
		}
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		title = exploreCategory?.title

		let cellStyle = exploreCategory?.size ?? "small"
		let horizontalCollectionCellStyle: HorizontalCollectionCellStyle = HorizontalCollectionCellStyle(rawValue: cellStyle) ?? .small

		// Create colelction view layout
		collectionView.collectionViewLayout = createLayout()
		collectionView.register(nibWithCellClass: horizontalCollectionCellStyle.classValue)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.showsListCollectionViewController.showDetailsSegue.identifier {
			// Show detail for explore cell
			if let showDetailCollectionViewController = segue.destination as? ShowDetailCollectionViewController {
				if let selectedCell = sender as? BaseLockupCollectionViewCell {
					showDetailCollectionViewController.baseLockupCollectionViewCell = selectedCell
					showDetailCollectionViewController.showDetailsElement = selectedCell.showDetailsElement
				} else if let showID = sender as? Int {
					showDetailCollectionViewController.showID = showID
				}
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ShowsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let exploreCategoryShowsCount = exploreCategory?.shows?.count else { return 0 }
		return exploreCategoryShowsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cellStyle = exploreCategory?.size ?? "small"
		let horizontalCollectionCellStyle: HorizontalCollectionCellStyle = HorizontalCollectionCellStyle(rawValue: cellStyle) ?? .small

		let collectionViewCell = collectionView.dequeueReusableCell(withClass: horizontalCollectionCellStyle.classValue, for: indexPath)
		return collectionViewCell
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = cell as? BaseLockupCollectionViewCell {
			baseLockupCollectionViewCell.showDetailsElement = exploreCategory?.shows?[indexPath.row]
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ShowsListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath)
		performSegue(withIdentifier: R.segue.showsListCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ShowsListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = (width / 374).rounded().int
		let horizontalCollectionCellStyleString = self.exploreCategory?.size ?? "small"
		let horizontalCollectionCellStyle: HorizontalCollectionCellStyle = HorizontalCollectionCellStyle(rawValue: horizontalCollectionCellStyleString) ?? .small

		switch horizontalCollectionCellStyle {
		case .banner:
			if width >= 414 {
				columnCount = (width / 562).rounded().int
			} else {
				columnCount = (width / 374).rounded().int
			}
		case .large:
			if width >= 414 {
				columnCount = (width / 500).rounded().int
			} else {
				columnCount = (width / 324).rounded().int
			}
		case .medium:
			if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
		case .small:
			if width >= 414 {
				columnCount = (width / 384).rounded().int
			} else {
				columnCount = (width / 284).rounded().int
			}
		case .video:
			if width >= 414 {
				columnCount = (width / 500).rounded().int
			} else {
				columnCount = (width / 360).rounded().int
			}
		}
		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int) -> CGFloat {
		let horizontalCollectionCellStyleString = self.exploreCategory?.size ?? "small"
		let horizontalCollectionCellStyle: HorizontalCollectionCellStyle = HorizontalCollectionCellStyle(rawValue: horizontalCollectionCellStyleString) ?? .small

		switch horizontalCollectionCellStyle {
		case .banner:
			return (0.55 / columnsCount.double).cgFloat
		case .large:
			return (0.55 / columnsCount.double).cgFloat
		case .medium:
			return (0.60 / columnsCount.double).cgFloat
		case .small:
			return (0.55 / columnsCount.double).cgFloat
		case .video:
			if columnsCount <= 1 {
				return (0.75 / columnsCount.double).cgFloat
			}
			return (0.92 / columnsCount.double).cgFloat
		}
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let heightFraction = self.groupHeightFraction(forSection: section, with: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: .fractionalWidth(heightFraction))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
	}
}
