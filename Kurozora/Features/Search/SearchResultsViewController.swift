//
//  SearchResultsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftTheme

class SearchResultsTableViewController: UITableViewController {
	// MARK: - Properties
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
	var currentScope: Int = 0
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

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

		// Blurred table view background
		let blurEffect = UIBlurEffect(style: .regular)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)

		for subview in blurEffectView.subviews {
			subview.backgroundColor = nil
		}

		tableView.backgroundView = blurEffectView
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
				KService.shared.search(forShow: text) { (showResults) in
					DispatchQueue.main.async {
						self.showResults = showResults
					}
				}
			case .myLibrary: break
			case .thread:
				KService.shared.search(forThread: text) { (threadResults) in
					DispatchQueue.main.async {
						self.threadResults = threadResults
					}
				}
			case .user:
				KService.shared.search(forUser: text) { (userResults) in
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

	/// Performs search after the given amount of time has passed.
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
}

// MARK: - UITableViewDataSource
extension SearchResultsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var resultsCount: Int? = nil

		if let searchScope = SearchScope(rawValue: currentScope) {
			switch searchScope {
			case .show:
				resultsCount = showResults?.count
			case .myLibrary: break
			case .thread:
				resultsCount = threadResults?.count
			case .user:
				resultsCount = userResults?.count
			}
		}
		return resultsCount ?? 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if showResults != nil || threadResults != nil || userResults != nil {
			let searchScope = SearchScope(rawValue: currentScope) ?? .show
			let identifier = searchScope.identifierString

			let searchBaseResultsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SearchBaseResultsCell
			var resultsCount = 1

			// Configure cell
			switch searchScope {
			case .show:
				(searchBaseResultsCell as? SearchShowResultsCell)?.showDetailsElement = showResults?[indexPath.row]
				resultsCount = showResults?.count ?? 0
			case .myLibrary: break
			case .thread:
				(searchBaseResultsCell as? SearchForumsResultsCell)?.forumsThreadElement = threadResults?[indexPath.row]
				resultsCount = threadResults?.count ?? 0
			case .user:
				(searchBaseResultsCell as? SearchUserResultsCell)?.userProfile = userResults?[indexPath.row]
				resultsCount = userResults?.count ?? 0
			}

			// Configure corner radius
			if resultsCount == 1 {
				searchBaseResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchBaseResultsCell.visualEffectView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			} else if indexPath.row == 0 {
				searchBaseResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchBaseResultsCell.visualEffectView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
			} else if indexPath.row == resultsCount - 1 {
				searchBaseResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchBaseResultsCell.visualEffectView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			} else {
				searchBaseResultsCell.visualEffectView?.layer.cornerRadius = 0
			}

			// Configure separator
			if tableView.numberOfRows() == 1 || indexPath.row == tableView.numberOfRows() - 1 {
				searchBaseResultsCell.separatorView?.isHidden = true
			} else {
				searchBaseResultsCell.separatorView?.isHidden = false
			}

			return searchBaseResultsCell
		} else {
			let searchResultsCell = tableView.dequeueReusableCell(withIdentifier: "SearchEmptyResultsCell", for: indexPath) as! SearchEmptyResultsCell
			searchResultsCell.suggestionElement = suggestions
			return searchResultsCell
		}
	}
}

// MARK: - UITableViewDelegate
extension SearchResultsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if showResults != nil || threadResults != nil || userResults != nil {
			guard let searchScope = SearchScope(rawValue: currentScope) else { return }
			let searchBaseResultsCell = tableView.cellForRow(at: indexPath) as? SearchBaseResultsCell

			switch searchScope {
			case .show:
				if let showDetailsViewController = ShowDetailViewController.instantiateFromStoryboard() as? ShowDetailViewController {
					showDetailsViewController.showDetailsElement = (searchBaseResultsCell as? SearchShowResultsCell)?.showDetailsElement
					presentingViewController?.show(showDetailsViewController, sender: nil)
				}
			case .myLibrary: break
			case .thread:
				if let threadTableViewController = ThreadTableViewController.instantiateFromStoryboard() as? ThreadTableViewController {
					threadTableViewController.forumsThreadElement = (searchBaseResultsCell as? SearchForumsResultsCell)?.forumsThreadElement
					presentingViewController?.show(threadTableViewController, sender: nil)
				}
			case .user:
				if let profileTableViewController = ProfileTableViewController.instantiateFromStoryboard() as? ProfileTableViewController {
					profileTableViewController.userID = (searchBaseResultsCell as? SearchUserResultsCell)?.userProfile?.id
					presentingViewController?.show(profileTableViewController, sender: nil)
				}
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
	}
}
