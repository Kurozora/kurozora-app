//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView
import SwiftyJSON
import WhatsNew

class HomeCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var kSearchController: KSearchController = KSearchController()
	var genreID: Int? = nil
	let actionsArray: [[[String: String]]] = [
		[["title": "About In-App Purchases", "url": "https://kurozora.app/"], ["title": "About Personalization", "url": "https://kurozora.app/"], ["title": "Welcome to Kurozora", "url": "https://kurozora.app/"]],
		[["title": "Redeem", "segueId": R.segue.homeCollectionViewController.redeemSegue.identifier], ["title": "Become a Pro User", "segueId": R.segue.homeCollectionViewController.subscriptionSegue.identifier]]
	]

	var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
	var exploreCategories: [ExploreCategory]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			configureDataSource()
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
	override func viewWillReload() {
		super.viewWillReload()

		fetchExplore()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		collectionView.register(nib: UINib(nibName: "SectionHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: SectionHeaderReusableView.self)

		// Fetch explore details.
		DispatchQueue.global(qos: .background).async {
			self.fetchExplore()
		}

		// Setup search bar.
		setupSearchBar()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Show what's new in the app if necessary.
		showWhatsNew()
	}

	// MARK: - Functions
	/// Shows what's new in the app if necessary.
	fileprivate func showWhatsNew() {
		if WhatsNew.shouldPresent() {
			let whatsNew = KWhatsNewViewController(titleText: "What's New", buttonText: "Continue", items: KWhatsNewModel.current)
			self.present(whatsNew)
		}
	}

	/**
		Returns a grid described by compositional layout.

		- Parameter section: The section for which the layout is being described.
		- Parameter layoutEnvironment: The layout environment in which the layout is being described.

		- Returns: a grid described by compositional layout.
	*/
	func gridSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let heightFraction = self.groupHeightFraction(forSection: section, with: columns)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90),
											   heightDimension: .fractionalWidth(heightFraction))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
													   subitem: item, count: columns)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	/**
		Returns a list described by compositional layout.

		- Parameter section: The section for which the layout is being described.
		- Parameter layoutEnvironment: The layout environment in which the layout is being described.

		- Returns: a list described by compositional layout.
	*/
	func listSection(for section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .absolute(55))
		let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
													   subitem: item, count: columns)
		let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
		layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
		return layoutSection
	}

	/// Sets up the search bar and starts the placeholder timer.
	fileprivate func setupSearchBar() {
		// Configure search bar
		kSearchController.viewController = self
		kSearchController.searchScope = .show

		// Add search bar to navigation controller
		navigationItem.searchController = kSearchController
	}

	/// Fetches the explore page from the server.
	fileprivate func fetchExplore() {
		KService.getExplore(genreID, withSuccess: { (explore) in
			DispatchQueue.main.async {
				self.exploreCategories = explore?.categories
			}
		})
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.homeCollectionViewController.showDetailsSegue.identifier {
			// Show detail for explore cell
			if let showDetailCollectionViewController = segue.destination as? ShowDetailCollectionViewController {
				if let selectedCell = sender as? BaseLockupCollectionViewCell {
					showDetailCollectionViewController.showDetailsElement = selectedCell.showDetailsElement
				} else if let showID = sender as? Int {
					showDetailCollectionViewController.showID = showID
				}
			}
		} else if segue.identifier == R.segue.homeCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				if let indexPath = sender as? IndexPath {
					showsListCollectionViewController.exploreCategory = exploreCategories?[indexPath.section]
				}
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension HomeCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		guard let exploreCategoriesCount = exploreCategories?.count else { return }
		if indexPath.section < exploreCategoriesCount {
			let cell = collectionView.cellForItem(at: indexPath)
			UIView.animate(withDuration: 0.5,
						   delay: 0.0,
						   usingSpringWithDamping: 0.8,
						   initialSpringVelocity: 0.2,
						   options: [.beginFromCurrentState],
						   animations: {
							cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			}, completion: nil)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		guard let exploreCategoriesCount = exploreCategories?.count else { return }
		if indexPath.section < exploreCategoriesCount {
			let cell = collectionView.cellForItem(at: indexPath)
			UIView.animate(withDuration: 0.5,
						   delay: 0.0,
						   usingSpringWithDamping: 0.4,
						   initialSpringVelocity: 0.2,
						   options: [.beginFromCurrentState],
						   animations: {
							cell?.transform = CGAffineTransform.identity
			}, completion: nil)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			if exploreCategories?[indexPath.section].genres?.count == 0 {
				performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
			}
		} else if let legalCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LegalCollectionViewCell {
			performSegue(withIdentifier: R.segue.homeCollectionViewController.legalSegue, sender: legalCollectionViewCell)
		}
	}
}

// MARK: - Helper functions
extension HomeCollectionViewController {
	/**
		Dequeues and returns collection view cells for the vertical collection view cell style.

		- Parameter verticalCollectionCellStyle: The style of the collection view cell to be dequeued.
		- Parameter indexPath: The indexPath for which the collection view cell should be dequeued.

		- Returns: The dequeued collection view cell.
	*/
	func createExploreCell(with verticalCollectionCellStyle: VerticalCollectionCellStyle, for indexPath: IndexPath) -> UICollectionViewCell {
		switch verticalCollectionCellStyle {
		case .legal:
			guard let legalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: verticalCollectionCellStyle.identifierString, for: indexPath) as? LegalCollectionViewCell else {
				fatalError("Cannot dequeue reusable cell with identifier \(verticalCollectionCellStyle.identifierString)")
			}
			return legalExploreCollectionViewCell
		default:
			guard let actionBaseExploreCollectionViewCell = collectionView.dequeueReusableCell(
				withReuseIdentifier: verticalCollectionCellStyle.identifierString, for: indexPath) as? ActionBaseExploreCollectionViewCell else {
					fatalError("Cannot dequeue reusable cell with identifier \(verticalCollectionCellStyle.identifierString)")
			}
			return actionBaseExploreCollectionViewCell
		}
	}
}

// MARK: - KCollectionViewDataSource
extension HomeCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SmallLockupCollectionViewCell.self,
				MediumLockupCollectionViewCell.self,
				LargeLockupCollectionViewCell.self,
				VideoLockupCollectionViewCell.self,
				LegalCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			if indexPath.section < self.exploreCategories?.count ?? 0 {
				// Get a cell of the desired kind.
				let cellStyle = self.exploreCategories?[indexPath.section].size ?? "small"
				var horizontalCollectionCellStyle: HorizontalCollectionCellStyle = HorizontalCollectionCellStyle(rawValue: cellStyle) ?? .small
				if indexPath.section == 0 {
					horizontalCollectionCellStyle = .banner
				}
				guard let baseLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: horizontalCollectionCellStyle.identifierString, for: indexPath) as? BaseLockupCollectionViewCell
					else { fatalError("Cannot dequeue reusable cell with identifier \(horizontalCollectionCellStyle.identifierString)") }

				// Populate the cell with our item description.
				let exploreCategoriesSection = self.exploreCategories?[indexPath.section]
				if let shows = exploreCategoriesSection?.shows, shows.count != 0 {
					baseLockupCollectionViewCell.showDetailsElement = shows[indexPath.row]
				} else {
					baseLockupCollectionViewCell.genreElement = exploreCategoriesSection?.genres?[indexPath.row]
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
			let exploreCategoriesCount = self.exploreCategories?.count ?? 0

			// Get a supplementary view of the desired kind.
			let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: SectionHeaderReusableView.self, for: indexPath)
			exploreSectionTitleCell.indexPath = indexPath

			if indexPath.section < exploreCategoriesCount {
				let sectionTitle = self.exploreCategories?[indexPath.section].title ?? ""
				if sectionTitle.contains("categories", caseSensitive: false) || sectionTitle.contains("genres", caseSensitive: false) {
					exploreSectionTitleCell.segueID = R.segue.homeCollectionViewController.genresSegue.identifier
				} else {
					exploreSectionTitleCell.segueID = R.segue.homeCollectionViewController.showsListSegue.identifier
				}
				exploreSectionTitleCell.title = self.exploreCategories?[indexPath.section].title
			} else {
				exploreSectionTitleCell.segueID = ""
				exploreSectionTitleCell.title = "Quick Links"
			}

			// Return the view.
			return exploreSectionTitleCell
		}

		let numberOfSections: Int = {
			let exploreCategoriesCount = exploreCategories?.count ?? 0
			return exploreCategoriesCount + 2
		}()

		// Initialize data
		var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
		var identifierOffset = 0
		var itemsPerSection = 0

		for section in 0...numberOfSections {
			if section < exploreCategories?.count ?? 0 {
				let exploreCategoriesSection = exploreCategories?[section]
				itemsPerSection = exploreCategoriesSection?.shows?.count ?? 0
				if itemsPerSection == 0 {
					itemsPerSection = exploreCategoriesSection?.genres?.count ?? 0
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

// MARK: - KCollectionViewDelegateLayout
extension HomeCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		var columnCount = 0
		let exploreCategoriesCount = self.exploreCategories?.count ?? 0
		switch section {
		case let section where section < exploreCategoriesCount:
			let horizontalCollectionCellStyleString = self.exploreCategories?[section].size ?? "small"
			let horizontalCollectionCellStyle: HorizontalCollectionCellStyle = section != 0 ? HorizontalCollectionCellStyle(rawValue: horizontalCollectionCellStyleString) ?? .small : .banner

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
		default:
			var verticalCollectionCellStyle: VerticalCollectionCellStyle = .actionList
			switch section {
			case let section where section == exploreCategoriesCount + 1:
				verticalCollectionCellStyle = .actionButton
			case let section where section == exploreCategoriesCount + 2:
				verticalCollectionCellStyle = .legal
			default: break
			}

			var numberOfItems = self.collectionView.numberOfItems(inSection: section)
			numberOfItems = numberOfItems > 0 ? numberOfItems : 1

			switch verticalCollectionCellStyle {
			case .actionList:
				if width <= 414 {
					columnCount = 1
				} else if width <= 828 {
					columnCount = 2
				} else {
					if numberOfItems < 5 {
						columnCount = numberOfItems
					} else {
						columnCount = 5
					}
				}
			case .actionButton:
				if width <= 414 {
					columnCount = 1
				} else if width <= 828 {
					columnCount = 2
				} else {
					columnCount = (width / 414).rounded().int
				}
			case .legal:
				columnCount = 1
			}
		}

		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int) -> CGFloat {
		let horizontalCollectionCellStyleString = self.exploreCategories?[section].size ?? "small"
		let horizontalCollectionCellStyle: HorizontalCollectionCellStyle = section != 0 ? HorizontalCollectionCellStyle(rawValue: horizontalCollectionCellStyleString) ?? .small : .banner

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

	override func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let exploreCategoriesCount = self.exploreCategories?.count ?? 0

		switch section {
		case let section where section < exploreCategoriesCount:
			return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
		default:
			var verticalCollectionCellStyle: VerticalCollectionCellStyle = .actionList
			switch section {
			case let section where section == exploreCategoriesCount + 1:
				verticalCollectionCellStyle = .actionButton
			case let section where section == exploreCategoriesCount + 2:
				verticalCollectionCellStyle = .legal
			default: break
			}

			var numberOfItems = self.collectionView.numberOfItems(inSection: section)
			numberOfItems = numberOfItems > 0 ? numberOfItems : 1

			switch verticalCollectionCellStyle {
			case .actionButton:
				if width > 828 {
					let itemsWidth = (414 * numberOfItems + 20 * numberOfItems).cgFloat
					var leadingInset: CGFloat = (width - itemsWidth) / 2
					var trailingInset: CGFloat = 0

					if leadingInset < 10 {
						leadingInset = 10
						trailingInset = 10
					} else if width < 1240 {
						trailingInset = leadingInset
					}

					return NSDirectionalEdgeInsets(top: 0, leading: leadingInset, bottom: 20, trailing: trailingInset)
				}

				return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
			default:
				return NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 10)
			}
		}
	}

	override func createLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { section, layoutEnvironment -> NSCollectionLayoutSection? in
			let exploreCategoriesCount = self.exploreCategories?.count ?? 0
			switch section {
			case let section where section < exploreCategoriesCount:
				// Configure section.
				let gridSection = self.gridSection(for: section, layoutEnvironment: layoutEnvironment)

				// If it's the first section (featured shows) then return without adding a header view.
				guard section != 0 else {
					return gridSection
				}

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
															  heightDimension: .estimated(52))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				gridSection.boundarySupplementaryItems = [sectionHeader]

				return gridSection
			default:
				let listSection = self.listSection(for: section, layoutEnvironment: layoutEnvironment)

				// Lists are 3 sections. This makes sure that only the top most section gets a header view (Quick Links).
				guard section == exploreCategoriesCount else {
					return listSection
				}

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
															  heightDimension: .estimated(52))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				listSection.boundarySupplementaryItems = [sectionHeader]
				return listSection
			}
		}
	}
}
