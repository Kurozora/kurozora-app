//
//  FavoriteShowsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class FavoriteShowsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [[ShowDetailsElement]]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.collectionView.reloadData()
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

	// MARK: - Views
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true

		// Create colelction view layout
		collectionView.collectionViewLayout = createLayout()
		collectionView.register(nib: UINib(nibName: "SectionHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: SectionHeaderReusableView.self)

		DispatchQueue.global(qos: .background).async {
			self.fetchUserLibrary()
		}
	}

	// MARK: - Functions
	func fetchUserLibrary() {

	}
}

// MARK: - UICollectionViewDataSource
extension FavoriteShowsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Library.Section.all.count + 1
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		}
		guard let showsCount = shows?[section - 1].count else { return 0 }
		return showsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if indexPath.section == 0 {
			let libraryStatisticsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryStatisticsCollectionViewCell", for: indexPath)
			return libraryStatisticsCollectionViewCell
		}
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
		return cell
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: SectionHeaderReusableView.self, for: indexPath)
		return supplementaryView
	}
}

// MARK: - UICollectionViewDelegate
extension FavoriteShowsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		if let sectionHeaderReusableView = view as? SectionHeaderReusableView {
			sectionHeaderReusableView.title = Library.Section.all[indexPath.section - 1].stringValue
			sectionHeaderReusableView.segueID = "LibraryListSegue"
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension FavoriteShowsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		if section == 0 {
			return 1
		}

		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = (width / 374).rounded().int
		if columnCount < 0 {
			columnCount = 1
		} else if columnCount > 5 {
			columnCount = 5
		}
		return columnCount
	}

	func heightDimension(forSection section: Int, with columnsCount: Int) -> NSCollectionLayoutDimension {
		if section == 0 {
			return .absolute(80)
		}

		let heightFraction = (0.60 / columnsCount.double).cgFloat
		return .fractionalWidth(heightFraction)
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

			let heightDimension = self.heightDimension(forSection: section, with: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: heightDimension)
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)

			// If it's the first section (statistics) then return without adding a header view.
			guard section != 0 else {
				return layoutSection
			}

			// Add header supplementary view.
			let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
														  heightDimension: .estimated(52))
			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
			layoutSection.boundarySupplementaryItems = [sectionHeader]

			return layoutSection
		}
		return layout
	}
}
