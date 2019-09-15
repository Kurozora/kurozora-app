//
//  SearchResultsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import Kingfisher
import SwiftTheme

protocol SearchResultsTableViewControllerDelegate: class {
	func didCancelSearchController()
}

class SearchResultsTableViewController: UITableViewController {
	var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .lightContent }
		return .fromString(statusBarStyleString)
	}

	var showResults: [ShowDetailsElement]? {
		didSet {
			if showResults != nil {
				self.tableView.reloadData()
			}
		}
	}
	var threadResults: [ForumsThreadElement]? {
		didSet {
			if threadResults != nil {
				self.tableView.reloadData()
			}
		}
	}
	var userResults: [UserProfile]? {
		didSet {
			if userResults != nil {
				self.tableView.reloadData()
			}
		}
	}

	var timer: Timer?
	var viaSearchButton: Bool = false
	var currentScope: Int?
	var suggestions: [ShowDetailsElement] {
		var suggestionResults = [ShowDetailsElement]()
		let suggestionResultsArray: [JSON] = [
			["id": 1774, "title": "One Piece", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/81797-1.jpg"],
			["id": 2345, "title": "Steins;Gate 0", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/339268-1.jpg"],
			["id": 147, "title": "Death Parade", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/289177-1.jpg"],
			["id": 235, "title": "One-Punch Man", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/293088-2.jpg"],
			["id": 236, "title": "Re: Zero kara Hajimeru Isekai Seikatsu", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/305089-3.jpg"],
			["id": 56, "title": "Gintama'", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/79895-24.jpg"]
		]
		for suggestionResultItem in suggestionResultsArray {
			if let showDetailsElement = try? ShowDetailsElement(json: suggestionResultItem) {
				suggestionResults.append(showDetailsElement)
			}
		}
		return suggestionResults
	}
	weak var delegate: SearchResultsTableViewControllerDelegate?

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// Blurred table view background
		let blurEffect = UIBlurEffect(style: .regular)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)

		for subview in blurEffectView.subviews {
			subview.backgroundColor = nil
		}

		tableView.backgroundView = blurEffectView

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "search", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "SearchResultsTableViewController")
	}

	/**
		Perform search with the given search text and the search scope.

		- Parameter text: The string which to search for.
		- Parameter searchScope: The scope in which the text should be searched.
	*/
	fileprivate func performSearch(forText text: String, searchScope: Int) {
		// Prepare view for search
		currentScope = searchScope

		guard let searchScope = SearchScope(rawValue: searchScope) else { return }

		if !text.isEmpty {
			switch searchScope {
			case .show:
				Service.shared.search(forShow: text) { (showResults) in
					DispatchQueue.main.async {
						self.showResults = showResults
					}
				}
			case .myLibrary: break
			case .thread:
				Service.shared.search(forThread: text) { (threadResults) in
					DispatchQueue.main.async {
						self.threadResults = threadResults
					}
				}
			case .user:
				Service.shared.search(forUser: text) { (userResults) in
					DispatchQueue.main.async {
						self.userResults = userResults
					}
				}
			}
		}
	}

	/// Sets all search results to nil and reloads the table view
	fileprivate func emptySearchResults() {
		showResults = nil
		threadResults = nil
		userResults = nil
		tableView.reloadData()
	}

	@objc func search(_ timer: Timer) {
		let userInfo = timer.userInfo as? [String: Any]
		if let text = userInfo?["searchText"] as? String, let scope = userInfo?["searchScope"] as? Int {
			performSearch(forText: text, searchScope: scope)
		}
	}

	// MARK: - IBActions
//	@IBAction func showMoreButtonPressed(_ sender: UIButton) {
//		if sender.title(for: .normal) == "Show More" {
//			sender.setTitle("Show Less", for: .normal)
//			self.suggestionsCollctionViewHeight.constant = self.suggestionsCollctionViewHeight.constant * 2
//			UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
//				self.view.layoutIfNeeded()
//			}, completion: nil)
//		} else {
//			sender.setTitle("Show More", for: .normal)
//			self.suggestionsCollctionViewHeight.constant = self.suggestionsCollctionViewHeight.constant / 2
//			UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
//				self.view.layoutIfNeeded()
//			}, completion: nil)
//		}
//	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? SearchResultsCell {
			if segue.identifier == "ShowDetailsSegue" {
				// Show detail for show cell
				let showDetailTabBarController = segue.destination as? ShowDetailTabBarController
				showDetailTabBarController?.showDetailsElement = currentCell.showDetailsElement
			} else if segue.identifier == "ProfileSegue" {
				// Show user profile for user cell
				if let kurozoraNavigationController = segue.destination as? KNavigationController {
					if let profileViewController = kurozoraNavigationController.topViewController as? ProfileTableViewController {
						profileViewController.userID = currentCell.userProfile?.id
						profileViewController.dismissButtonIsEnabled = true
					}
				}
			} else if segue.identifier == "ThreadSegue" {
				// Show detail for thread cell
				if let kurozoraNavigationController = segue.destination as? KNavigationController {
					if let threadViewController = ThreadTableViewController.instantiateFromStoryboard() as? ThreadTableViewController {
						threadViewController.forumThreadID = currentCell.forumsThreadElement?.id
						threadViewController.dismissButtonIsEnabled = true

						kurozoraNavigationController.pushViewController(threadViewController)
					}
				}
			}
		} else if let currentCell = sender as? SuggestionResultCell {
			if segue.identifier == "ShowDetailsSegue" {
				// Show detail for show cell
				let showDetailTabBarController = segue.destination as? ShowDetailTabBarController
				showDetailTabBarController?.showID = currentCell.showDetailsElement?.id
			}
		}
	}
}

// MARK: - UISearchResultsUpdating
extension SearchResultsTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		searchController.searchResultsController?.view.isHidden = false
	}
}

// MARK: - UISearchBarDelegate
extension SearchResultsTableViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = SearchScope(rawValue: selectedScope) else { return }
		guard let text = searchBar.text else { return }

		emptySearchResults()

		if !text.isEmpty {
			switch searchScope {
			case .show, .thread, .user:
				performSearch(forText: text, searchScope: selectedScope)
			case .myLibrary: break
			}
		}
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let text = searchBar.text else { return }
		let scope = searchBar.selectedScopeButtonIndex
		performSearch(forText: text, searchScope: scope)
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let searchScope = searchBar.selectedScopeButtonIndex

		if !searchText.isEmpty {
			timer?.invalidate()
			timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(search(_:)), userInfo: ["searchText": searchText, "searchScope": searchScope], repeats: false)
		} else {
			emptySearchResults()
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		emptySearchResults()
		delegate?.didCancelSearchController()
	}
}

// MARK: - UITableViewDataSource
extension SearchResultsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let currentScope = currentScope else { return 1 }
		var resultsCount: Int? = nil

		if let searchScope = SearchScope(rawValue: currentScope) {
			switch searchScope {
			case .show:
				resultsCount = showResults?.count
			case .thread:
				resultsCount = threadResults?.count
			case .user:
				resultsCount = userResults?.count
			case .myLibrary: break
			}
		}
		return resultsCount ?? 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if showResults != nil || threadResults != nil || userResults != nil {
			var searchResultsCell = SearchResultsCell()
			var resultsCount = 1

			// Configure cell
			if let currentScope = currentScope, let searchScope = SearchScope(rawValue: currentScope) {
				let identifier = searchScope.identifierString
				searchResultsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SearchResultsCell

				switch searchScope {
				case .show:
					searchResultsCell.showDetailsElement = showResults?[indexPath.row]
					resultsCount = showResults?.count ?? 0
				case .thread:
					searchResultsCell.forumsThreadElement = threadResults?[indexPath.row]
					resultsCount = threadResults?.count ?? 0
				case .user:
					searchResultsCell.userProfile = userResults?[indexPath.row]
					resultsCount = userResults?.count ?? 0
				case .myLibrary: break
				}
			}

			// Configure separator
			if tableView.numberOfRows() == 1 || indexPath.row == tableView.numberOfRows() - 1 {
				searchResultsCell.separatorView?.isHidden = true
			} else {
				searchResultsCell.separatorView?.isHidden = false
			}

			// Configure corner radius
			if resultsCount == 1 {
				searchResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchResultsCell.visualEffectView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			} else if indexPath.row == 0 {
				searchResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchResultsCell.visualEffectView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
			} else if indexPath.row == resultsCount - 1 {
				searchResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchResultsCell.visualEffectView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			} else {
				searchResultsCell.visualEffectView?.layer.cornerRadius = 0
			}

			searchResultsCell.searchResultsTableViewController = self
			return searchResultsCell
		} else {
			let searchResultsCell = tableView.dequeueReusableCell(withIdentifier: "SuggestionResultCell", for: indexPath) as! SearchResultsCell
			searchResultsCell.suggestionElement = suggestions
			return searchResultsCell
		}
	}
}

// MARK: - UITableViewDelegate
extension SearchResultsTableViewController {
}
