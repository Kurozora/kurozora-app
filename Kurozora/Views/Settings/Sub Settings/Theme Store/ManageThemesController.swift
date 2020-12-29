//
//  ManageThemesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ManageThemesCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var themes: [[Theme]] = [[], []] {
		didSet {
			self.configureDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
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

	// Default theme
	var defaultThemes = ThemeResponse(from:
	"""
	{
		"data": [
			{
			  "id": 1,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Default",
				"backgroundColor": "#353A50",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 2,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Day",
				"backgroundColor": "#E6E5E5",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 3,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Night",
				"backgroundColor": "#333333",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 4,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Grass",
				"backgroundColor": "#E5EFAC",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 5,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Sky",
				"backgroundColor": "#E5EFAC",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 6,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Sakura",
				"backgroundColor": "#E5EFAC",
				"screenshot": "",
				"downloadLink": ""
			  }
			}
		]
	}
	""".data(using: .utf8)!)

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup default themes
		if let defaultThemes = self.defaultThemes?.data {
			self.themes[0].append(contentsOf: defaultThemes)
		}
	}

	// MARK: - Initializers
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Fetch themes
		DispatchQueue.global(qos: .background).async {
			self.fetchThemes()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchThemes()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.themes()!)
		emptyBackgroundView.configureLabels(title: "No Themes", detail: "Themes are not available at this moment. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches themes from the server.
	func fetchThemes() {
		KService.getThemes { [weak self] result in
			switch result {
			case .success(let themes):
				DispatchQueue.main.async {
					self?.themes[1].append(contentsOf: themes)
				}
			case .failure: break
			}
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ManageThemesCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return []
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
			if let themesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.themesCollectionViewCell, for: indexPath) {
				themesCollectionViewCell.indexPath = indexPath
				themesCollectionViewCell.theme = self.themes[indexPath.section][indexPath.item]
				return themesCollectionViewCell
			} else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.themesCollectionViewCell.identifier)")
			}
		}

		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		SectionLayoutKind.allCases.forEach {
			let itemsPerSection = ($0 == .def ? themes.first?.count : themes.last?.count) ?? 0
			snapshot.appendSections([$0])
			let itemOffset = $0.rawValue * itemsPerSection
			let itemUpperbound = itemOffset + itemsPerSection
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ManageThemesCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 170).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
		return (2.00 / columnsCount.double).cgFloat
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
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let heightFraction = self.groupHeightFraction(forSection: section, with: columns, layout: layoutEnvironment)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(heightFraction))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
	}
}

// MARK: - SectionLayoutKind
extension ManageThemesCollectionViewController {
	/**
		List of theme section layout kind.

		```
		case def = 0
		case main = 1
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case def = 0
		case main = 1
	}
}
