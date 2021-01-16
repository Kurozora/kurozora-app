//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import WhatsNew

class HomeCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var kSearchController: KSearchController = KSearchController()
	var genre: Genre? = nil
	let actionsArray: [[[String: String]]] = [
		[["title": "About In-App Purchases", "url": "https://kurozora.app/"], ["title": "About Personalization", "url": "https://kurozora.app/"], ["title": "Welcome to Kurozora", "url": "https://kurozora.app/"]],
		[["title": "Redeem", "segueId": R.segue.homeCollectionViewController.redeemSegue.identifier], ["title": "Become a Pro User", "segueId": R.segue.homeCollectionViewController.subscriptionSegue.identifier]]
	]

	var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<Int, Int>! = nil
	var exploreCategories: [ExploreCategory] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

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
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

//		if exploreCategories.count != 0 {
			self.handleRefreshControl()
//		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = genre?.attributes.name ?? "Explore"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Setup search bar.
		self.setupSearchBar()

		// Add Refresh Control to Collection View
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch explore details.
		DispatchQueue.global(qos: .background).async {
			self.fetchExplore()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Show what's new in the app if necessary.
		self.showWhatsNew()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		DispatchQueue.global(qos: .background).async {
			self.fetchExplore()
		}
	}

	/// Shows what's new in the app if necessary.
	fileprivate func showWhatsNew() {
		if WhatsNew.shouldPresent() {
			let whatsNew = KWhatsNewViewController(titleText: "What's New", buttonText: "Continue", items: KWhatsNewModel.current)
			self.present(whatsNew, animated: true)
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
		KService.getExplore(genre?.id) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let exploreCategories):
				self.exploreCategories = exploreCategories
			case .failure: break
			}
		}
	}

	/// Focuses on the search bar.
	@objc func toggleSearchBar() {
		self.navigationItem.searchController?.searchBar.textField?.becomeFirstResponder()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.homeCollectionViewController.showDetailsSegue.identifier {
			// Show detail for explore cell
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let showID = sender as? Int {
					showDetailCollectionViewController.showID = showID
				}
			}
		} else if segue.identifier == R.segue.homeCollectionViewController.exploreSegue.identifier {
			// Show explore view with specified genre
			if let homeCollectionViewController = segue.destination as? HomeCollectionViewController {
				if let genre = sender as? Genre {
					homeCollectionViewController.genre = genre
				}
			}
		} else if segue.identifier == R.segue.homeCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				if let indexPath = sender as? IndexPath {
					showsListCollectionViewController.title = exploreCategories[indexPath.section].attributes.title
					showsListCollectionViewController.shows = exploreCategories[indexPath.section].relationships.shows?.data ?? []
				}
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension HomeCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		if indexPath.section < exploreCategories.count {
			let cell = collectionView.cellForItem(at: indexPath)
			UIView.animate(withDuration: 0.5,
						   delay: 0.0,
						   usingSpringWithDamping: 0.8,
						   initialSpringVelocity: 0.2,
						   options: [.beginFromCurrentState, .allowUserInteraction],
						   animations: {
							cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			}, completion: nil)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		if indexPath.section < exploreCategories.count {
			let cell = collectionView.cellForItem(at: indexPath)
			UIView.animate(withDuration: 0.5,
						   delay: 0.0,
						   usingSpringWithDamping: 0.4,
						   initialSpringVelocity: 0.2,
						   options: [.beginFromCurrentState, .allowUserInteraction],
						   animations: {
							cell?.transform = CGAffineTransform.identity
			}, completion: nil)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			if self.exploreCategories[indexPath.section].relationships.shows != nil {
				performSegue(withIdentifier: R.segue.homeCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell.show?.id)
			} else {
				performSegue(withIdentifier: R.segue.homeCollectionViewController.exploreSegue, sender: baseLockupCollectionViewCell.genre)
			}
		} else if let legalCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LegalCollectionViewCell {
			performSegue(withIdentifier: R.segue.homeCollectionViewController.legalSegue, sender: legalCollectionViewCell)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			if self.exploreCategories[indexPath.section].relationships.shows != nil {
				return baseLockupCollectionViewCell.show?.contextMenuConfiguration(in: self)
			}
		}
		return nil
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
			guard let actionBaseExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: verticalCollectionCellStyle.identifierString, for: indexPath) as? ActionBaseExploreCollectionViewCell else {
					fatalError("Cannot dequeue reusable cell with identifier \(verticalCollectionCellStyle.identifierString)")
			}
			return actionBaseExploreCollectionViewCell
		}
	}
}
