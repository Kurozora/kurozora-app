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

class HomeCollectionViewController: UITableViewController {
	// MARK: - Properties
	var searchResultsTableViewController: SearchResultsTableViewController?
	var searchController: SearchController!
	var placeholderTimer: Timer?
	let placeholderArray: [String] = ["One Piece", "Shaman Asakaura", "a young girl with big ambitions", "massively multiplayer online role-playing game", "vampires"]
	let actionsArray: [[[String: String]]] = [
		[["title": "About In-App Purchases", "url": "https://kurozora.app/"], ["title": "About Personalization", "url": "https://kurozora.app/"], ["title": "Welcome to Kurozora", "url": "https://kurozora.app/"]],
		[["title": "Redeem", "segueId": "RedeemSegue"], ["title": "Become a Pro User", "segueId": "SubscriptionSegue"]]
	]

	var exploreCategories: [ExploreCategory]? {
		didSet {
			tableView.reloadData()
		}
	}
	var showID: Int?
	var collectionViewSizeChanged: Bool = false
	var collectionViewOffsets = [IndexPath: CGFloat]()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .KUserIsSignedInDidChange, object: nil)

		// Remove top space
		var frame = CGRect.zero
		frame.size.height = .leastNormalMagnitude
		let tableHeaderView = UIView(frame: frame)
		tableHeaderView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		tableView.tableHeaderView = tableHeaderView

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

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		collectionViewSizeChanged = true
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		if collectionViewSizeChanged {
			tableView.invalidateIntrinsicContentSize()
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if collectionViewSizeChanged {
			collectionViewSizeChanged = false
			DispatchQueue.main.async {
				self.tableView.performBatchUpdates({}) { _ in
					NotificationCenter.default.post(name: .KEDidInvalidateContentSize, object: nil)
				}
			}
		}
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
			let whatsNew = KWhatsNewViewController(items: [
				WhatsNewItem.image(title: "Very Sleep", subtitle: "Easy on your eyes with the dark theme.", image: #imageLiteral(resourceName: "darkmode")),
				WhatsNewItem.image(title: "High Five", subtitle: "Your privacy is our #1 priority!", image: #imageLiteral(resourceName: "privacy_icon")),
				WhatsNewItem.image(title: "Attention Grabber", subtitle: "New follower? New message? Look here!", image: #imageLiteral(resourceName: "notifications_icon"))
			])
			whatsNew.titleText = "What's New"
			whatsNew.buttonText = "Continue"
			whatsNew.titleColor = KThemePicker.textColor.colorValue
			whatsNew.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
			whatsNew.itemTitleColor = KThemePicker.textColor.colorValue
			whatsNew.itemSubtitleColor = KThemePicker.subTextColor.colorValue
			whatsNew.buttonTextColor = KThemePicker.tintedButtonTextColor.colorValue
			whatsNew.buttonBackgroundColor = KThemePicker.tintColor.colorValue
			self.present(whatsNew)
		}
	}

	/// Sets up the search bar and starts the placeholder timer.
	fileprivate func setupSearchBar() {
		searchResultsTableViewController = SearchResultsTableViewController.instantiateFromStoryboard() as? SearchResultsTableViewController

		searchController = SearchController(searchResultsController: searchResultsTableViewController)
		searchController.delegate = self
		searchController.searchResultsUpdater = searchResultsTableViewController
		searchController.viewController = self

		let searchControllerBar = searchController.searchBar
		searchControllerBar.delegate = searchResultsTableViewController
		startPlaceholderTimer(for: searchControllerBar)

		navigationItem.searchController = searchController
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

	/**
		Updates the search placeholder with new placeholder string every second.

		- Parameter timer: A `Timer` object containing a reference to the search controller.
	*/
	@objc func updateSearchPlaceholder(_ timer: Timer) {
		if let searchControllerBar = timer.userInfo as? UISearchBar {
			UIView.animate(withDuration: 1, delay: 0, options: .transitionCrossDissolve, animations: {
				searchControllerBar.placeholder = self.placeholderArray.randomElement()
			}, completion: nil)
		}
	}

	/**
		Starts the placeholder timer for the search bar if no timers are already running.

		- Parameter searchControllerBar: The search bar for which the timer is started.
	*/
	func startPlaceholderTimer(for searchControllerBar: UISearchBar) {
		if placeholderTimer == nil {
			placeholderTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateSearchPlaceholder(_:)), userInfo: searchControllerBar, repeats: true)
		}
	}

	/// Stops the placeholder timer if one is running.
	func stopPlacholderTimer() {
		if placeholderTimer != nil {
			placeholderTimer?.invalidate()
			placeholderTimer = nil
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowDetailsSegue" {
			// Show detail for explore cell
			if let selectedCell = sender as? ExploreBaseCollectionViewCell, let showDetailTabBarController = segue.destination as? ShowDetailTabBarController {
				showDetailTabBarController.exploreBaseCollectionViewCell = selectedCell
				showDetailTabBarController.showDetailsElement = selectedCell.showDetailsElement
				if let showTitle = selectedCell.showDetailsElement?.title, let section = selectedCell.indexPath?.section {
					showDetailTabBarController.heroID = "explore_\(showTitle)_\(section)"
				}
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension HomeCollectionViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let categoriesCount = exploreCategories?.count else { return 0 }
		return categoriesCount + 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let exploreCategoriesCount = exploreCategories?.count {
			if section < exploreCategoriesCount {
				let categorySection = exploreCategories?[section]
				if categorySection?.shows?.count != 0 {
					return 1
				} else if categorySection?.genres?.count != 0 {
					return 1
				}
				return 0
			}
		}

		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let exploreCategoriesCount = exploreCategories?.count {
			if indexPath.section < exploreCategoriesCount {
				if let horizontalCollectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HorizontalCollectionTableViewCell", for: indexPath) as? HorizontalCollectionTableViewCell {
					return horizontalCollectionTableViewCell
				}
			}

			if indexPath.section == exploreCategoriesCount {
				if let verticalCollectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "VerticalCollectionTableViewCell", for: indexPath) as? VerticalCollectionTableViewCell {
					return verticalCollectionTableViewCell
				}
			}
		}

		if let legalExploreTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LegalExploreTableViewCell", for: indexPath) as? LegalExploreTableViewCell {
			return legalExploreTableViewCell
		}

		return UITableViewCell()
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let exploreCategoriesCount = exploreCategories?.count {
			if indexPath.section < exploreCategoriesCount {
				if let categoryType = exploreCategories?[indexPath.section].size, var exploreCellStyle = HorizontalCollectionCellStyle(rawValue: categoryType),
					let horizontalCollectionTableViewCell = cell as? HorizontalCollectionTableViewCell {

					if indexPath.section == 0 {
						exploreCellStyle = .banner
					}

					horizontalCollectionTableViewCell.cellStyle = exploreCellStyle

					if exploreCategories?[indexPath.section].shows?.count != 0 {
						horizontalCollectionTableViewCell.shows = exploreCategories?[indexPath.section].shows
					} else {
						horizontalCollectionTableViewCell.genres = exploreCategories?[indexPath.section].genres
					}

					horizontalCollectionTableViewCell.contentOffset = collectionViewOffsets[indexPath] ?? 0
				}
			}

			if let verticalCollectionTableViewCell = cell as? VerticalCollectionTableViewCell {
				verticalCollectionTableViewCell.actionsArray = actionsArray
			}
		}
	}
}

// MARK: - UITableViewDelegate
extension HomeCollectionViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard section != 0 else { return .zero }

		if let exploreCategoriesCount = exploreCategories?.count {
			if section < exploreCategoriesCount {
				if section != 0 {
					return (exploreCategories?[section].shows?.count != 0 || exploreCategories?[section].genres?.count != 0) ? UITableView.automaticDimension : .zero
				}
			} else if section == exploreCategoriesCount {
				return UITableView.automaticDimension
			}
		}

		return .zero
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let exploreCategoriesCount = exploreCategories?.count else { return nil }
		guard section <= exploreCategoriesCount else { return nil }
		guard let exploreSectionTitleCell = tableView.dequeueReusableCell(withIdentifier: "ExploreSectionTitleCell") as? ExploreSectionTitleCell else { return nil }

		if section < exploreCategoriesCount {
			exploreSectionTitleCell.exploreCategory = exploreCategories?[section]
		} else {
			exploreSectionTitleCell.title = "Quick Links"
		}

		return exploreSectionTitleCell.contentView
	}

	override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let horizontalCollectionTableViewCell = cell as? HorizontalCollectionTableViewCell {
			collectionViewOffsets[indexPath] = horizontalCollectionTableViewCell.contentOffset
		}
	}
}

// MARK: - UISearchControllerDelegate
extension HomeCollectionViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		searchController.searchBar.showsCancelButton = true

		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = true
			})
		}
		self.stopPlacholderTimer()
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		searchController.searchBar.showsCancelButton = false

		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = false
			})
		}
		self.startPlaceholderTimer(for: searchController.searchBar)
	}
}
