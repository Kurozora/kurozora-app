//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON
import WhatsNew

class HomeCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	var kSearchController: KSearchController = KSearchController()
	let actionsArray: [[[String: String]]] = [
		[["title": "About In-App Purchases", "url": "https://kurozora.app/"], ["title": "About Personalization", "url": "https://kurozora.app/"], ["title": "Welcome to Kurozora", "url": "https://kurozora.app/"]],
		[["title": "Redeem", "segueId": "RedeemSegue"], ["title": "Become a Pro User", "segueId": "SubscriptionSegue"]]
	]

	var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
	var exploreCategories: [ExploreCategory]? {
		didSet {
			configureDataSource()
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .KUserIsSignedInDidChange, object: nil)

		// Create colelction view layout
		collectionView.collectionViewLayout = createLayout()

		// Fetch explore details.
		fetchExplore()

		// Setup search bar.
		setupSearchBar()

		// Validate session.
		if User.isSignedIn {
			KService.shared.validateSession(withSuccess: { (success) in
				if !success {
					if let welcomeViewController = WelcomeViewController.instantiateFromStoryboard() {
						self.present(welcomeViewController, animated: true, completion: nil)
					}
				}
			})
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Show what's new in the app if necessary.
		showWhatsNew()
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "home", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "HomeCollectionViewController")
	}

	/// Shows what's new in the app if necessary.
	fileprivate func showWhatsNew() {
		if WhatsNew.shouldPresent() {
			let whatsNew = KWhatsNewViewController(titleText: "What's New", buttonText: "Continue", items: KWhatsNewModel.current)
			self.present(whatsNew)
		}
	}

	func gridSection(for cellStyle: HorizontalCollectionCellStyle, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
		let columns = cellStyle.columnCount(for: layoutEnvironment.container.effectiveContentSize.width)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = cellStyle.itemContentInsets

		let heightFraction = cellStyle.groupHeightFraction(for: columns)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90),
											   heightDimension: .fractionalWidth(heightFraction))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
													   subitem: item, count: columns)
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
		section.contentInsets = cellStyle.sectionContentInsets
		return section
	}

	func listSection(for cellStyle: VerticalCollectionCellStyle, layoutEnvironment: NSCollectionLayoutEnvironment, numberOfItems: Int) -> NSCollectionLayoutSection {
		let columns = cellStyle.columnCount(for: layoutEnvironment.container.effectiveContentSize.width, numberOfItems: numberOfItems)
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											  heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = cellStyle.itemContentInsets

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
											   heightDimension: .absolute(55))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
													   subitem: item, count: columns)
		let section = NSCollectionLayoutSection(group: group)
		section.contentInsets = cellStyle.sectionContentInsets(for: layoutEnvironment.container.effectiveContentSize.width, numberOfItems: numberOfItems)
		return section
	}

	/**
		Returns the layout that should be used for the collection view.

		- Returns: the layout that should be used for the collection view.
	*/
	func createLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { section, layoutEnvironment -> NSCollectionLayoutSection? in
			let exploreCategoriesCount = self.exploreCategories?.count ?? 0
			switch section {
			case let section where section < exploreCategoriesCount:
				// Configure section.
				let horizontalCollectionCellStyleString = self.exploreCategories?[section].size ?? "small"
				let horizontalCollectionCellStyle: HorizontalCollectionCellStyle = section != 0 ? HorizontalCollectionCellStyle(rawValue: horizontalCollectionCellStyleString) ?? .small : .banner
				let gridSection = self.gridSection(for: horizontalCollectionCellStyle, layoutEnvironment: layoutEnvironment)

				// If it's the first section (featured shows) then return without adding a header view.
				guard section != 0 else {
					return gridSection
				}

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
															  heightDimension: .estimated(44))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				gridSection.boundarySupplementaryItems = [sectionHeader]

				return gridSection
			default:
				var verticalCollectionCellStyle: VerticalCollectionCellStyle = .actionList
				switch section {
				case let section where section == exploreCategoriesCount + 1:
					verticalCollectionCellStyle = .actionButton
				case let section where section == exploreCategoriesCount + 2:
					verticalCollectionCellStyle = .legal
				default: break
				}

				let numberOfItems = self.collectionView.numberOfItems(inSection: section)
				let listSection = self.listSection(for: verticalCollectionCellStyle, layoutEnvironment: layoutEnvironment, numberOfItems: numberOfItems)

				// Lists are 3 sections. This makes sure that only the top most section gets a header view (Quick Links).
				guard section == exploreCategoriesCount else {
					return listSection
				}

				// Add header supplementary view.
				let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
															  heightDimension: .estimated(44))
				let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
					layoutSize: headerFooterSize,
					elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
				listSection.boundarySupplementaryItems = [sectionHeader]
				return listSection
			}
		}
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
		KService.shared.getExplore(withSuccess: { (explore) in
			DispatchQueue.main.async {
				self.exploreCategories = explore?.categories
			}
		})
	}

	/// Reload the data on the view.
	@objc private func reloadData() {
		fetchExplore()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetailsSegue" {
			// Show detail for explore cell
			if let showDetailViewController = segue.destination as? ShowDetailViewController {
				if let selectedCell = sender as? ExploreBaseCollectionViewCell {
					showDetailViewController.exploreBaseCollectionViewCell = selectedCell
					showDetailViewController.showDetailsElement = selectedCell.showDetailsElement
				} else if let showID = sender as? Int {
					showDetailViewController.showID = showID
				}
			}
		}
	}
}

extension HomeCollectionViewController {
	func createExploreCell(with verticalCollectionCellStyle: VerticalCollectionCellStyle, for indexPath: IndexPath) -> UICollectionViewCell {
		switch verticalCollectionCellStyle {
		case .legal:
			guard let legalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: verticalCollectionCellStyle.identifierString, for: indexPath) as? LegalExploreCollectionViewCell else {
				fatalError("Cannot create new \(verticalCollectionCellStyle.identifierString)")
			}
			return legalExploreCollectionViewCell
		default:
			guard let actionBaseExploreCollectionViewCell = collectionView.dequeueReusableCell(
				withReuseIdentifier: verticalCollectionCellStyle.identifierString, for: indexPath) as? ActionBaseExploreCollectionViewCell else {
					fatalError("Cannot create new \(verticalCollectionCellStyle.identifierString)")
			}
			return actionBaseExploreCollectionViewCell
		}
	}

	func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			if indexPath.section < self.exploreCategories?.count ?? 0 {
				// Get a cell of the desired kind.
				let cellStyle = self.exploreCategories?[indexPath.section].size ?? "small"
				var horizontalCollectionCellStyle: HorizontalCollectionCellStyle = HorizontalCollectionCellStyle(rawValue: cellStyle) ?? .small
				if indexPath.section == 0 {
					horizontalCollectionCellStyle = .banner
				}
				guard let exploreBaseCollectionViewCell = collectionView.dequeueReusableCell(
					withReuseIdentifier: horizontalCollectionCellStyle.identifierString, for: indexPath) as? ExploreBaseCollectionViewCell
					else { fatalError("Cannot create new \(horizontalCollectionCellStyle.identifierString)") }

				// Populate the cell with our item description.
				let exploreCategoriesSection = self.exploreCategories?[indexPath.section]
				if let shows = exploreCategoriesSection?.shows, shows.count != 0 {
					exploreBaseCollectionViewCell.showDetailsElement = shows[indexPath.row]
				} else {
					exploreBaseCollectionViewCell.genreElement = exploreCategoriesSection?.genres?[indexPath.row]
				}

				// Return the cell.
				return exploreBaseCollectionViewCell
			}

			var verticalCollectionCellStyle: VerticalCollectionCellStyle = .actionList
			var actionsArray = self.actionsArray[0]

			switch indexPath.section {
			case let section where section == collectionView.numberOfSections - 1: // If last section
				return self.createExploreCell(with: .legal, for: indexPath)
			case let section where section == collectionView.numberOfSections - 2: // If before last section
				verticalCollectionCellStyle = .actionButton
				actionsArray = self.actionsArray[1]
			default: break
			}

			let actionBaseExploreCollectionViewCell = self.createExploreCell(with: verticalCollectionCellStyle, for: indexPath) as? ActionBaseExploreCollectionViewCell
			actionBaseExploreCollectionViewCell?.actionItem = actionsArray[indexPath.item]
			return actionBaseExploreCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let exploreCategoriesCount = self.exploreCategories?.count ?? 0

			// Get a supplementary view of the desired kind.
			guard let exploreSectionTitleCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ExploreSectionTitleCell", for: indexPath) as? ExploreSectionTitleCell else {
				fatalError("Cannot create new ExploreSectionTitleCell")
			}

			if indexPath.section < exploreCategoriesCount {
				exploreSectionTitleCell.exploreCategory = self.exploreCategories?[indexPath.section]
			} else {
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
				itemsPerSection = actionsArray[0].count
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

		dataSource.apply(snapshot, animatingDifferences: false)
	}
}
