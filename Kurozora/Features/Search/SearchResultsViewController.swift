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

class SearchResultsTableViewController: UITableViewController {
	var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .lightContent }
		return .fromString(statusBarStyleString)
	}
	var results: [SearchElement]?
	var timer: Timer?
	var currentScope: Int!
	var suggestions: [SearchElement] {
		var results = [SearchElement]()

		let resultsArray: [JSON] = [
			["id": 1774, "title": "One Piece", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/81797-1.jpg"],
			["id": 2345, "title": "Steins;Gate 0", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/339268-1.jpg"],
			["id": 147, "title": "Death Parade", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/289177-1.jpg"],
			["id": 235, "title": "One-Punch Man", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/293088-2.jpg"],
			["id": 236, "title": "Re: Zero kara Hajimeru Isekai Seikatsu", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/305089-3.jpg"],
			["id": 56, "title": "Gintama'", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/posters/79895-24.jpg"]
		]
		for resultsItem in resultsArray {
			if let searchElement = try? SearchElement(json: resultsItem) {
				results.append(searchElement)
			}
		}

		return results
	}

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

	fileprivate func search(forText text: String, searchScope: Int) {
		// Prepare view for search
		currentScope = searchScope

		guard let searchScope = SearchScope(rawValue: searchScope) else { return }

		if !text.isEmpty {
			switch searchScope {
			case .show:
				Service.shared.search(forShow: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.tableView.reloadData()
					}
				}
			case .myLibrary: break
			case .thread:
				Service.shared.search(forThread: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.tableView.reloadData()
					}
				}
			case .user:
				Service.shared.search(forUser: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.tableView.reloadData()
					}
				}
			}
		}
	}

	@objc func search(_ timer: Timer) {
		let userInfo = timer.userInfo as? [String: Any]
		if let text = userInfo?["searchText"] as? String, let scope = userInfo?["searchScope"] as? Int {
			search(forText: text, searchScope: scope)
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

	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let currentCell = sender as? SearchResultsCell {
			if segue.identifier == "ShowDetailsSegue" {
				// Show detail for show cell
				let showTabBarController = segue.destination as? ShowDetailTabBarController
				showTabBarController?.showID = currentCell.searchElement?.id
			} else if segue.identifier == "ProfileSegue" {
				// Show user profile for user cell
				if let kurozoraNavigationController = segue.destination as? KNavigationController {
					if let profileViewController = kurozoraNavigationController.topViewController as? ProfileTableViewController {
						profileViewController.otherUserID = currentCell.searchElement?.id
					}
				}
			} else if segue.identifier == "ThreadSegue" {
				// Show detail for thread cell
				if let kurozoraNavigationController = segue.destination as? KNavigationController {
					if let threadViewController = ThreadTableViewController.instantiateFromStoryboard() as? ThreadTableViewController {
						threadViewController.isDismissEnabled = true
						threadViewController.forumThreadID = currentCell.searchElement?.id

						kurozoraNavigationController.pushViewController(threadViewController)
					}
				}
			}
		} else if let currentCell = sender as? SuggestionResultCell {
			if segue.identifier == "ShowDetailsSegue" {
				// Show detail for show cell
				let showTabBarController = segue.destination as? ShowDetailTabBarController
				showTabBarController?.showID = currentCell.searchElement?.id
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

		results = nil
		tableView.reloadData()

		if !text.isEmpty {
			switch searchScope {
			case .show, .thread, .user:
				search(forText: text, searchScope: selectedScope)
			case .myLibrary: break
			}
		}
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let text = searchBar.text else { return }
		let scope = searchBar.selectedScopeButtonIndex
		search(forText: text, searchScope: scope)
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		let searchScope = searchBar.selectedScopeButtonIndex

		if !searchText.isEmpty {
			timer?.invalidate()
			timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(search(_:)), userInfo: ["searchText": searchText, "searchScope": searchScope], repeats: false)
		} else {
			results = nil
			tableView.reloadData()
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		results = nil
		tableView.reloadData()
	}
}

// MARK: - UITableViewDataSource
extension SearchResultsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let resultsCount = results?.count else { return 1 }
		return resultsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if results != nil {
			var searchResultsCell = SearchResultsCell()

			if let searchScope = SearchScope(rawValue: currentScope) {
				let identifier = searchScope.identifierString
				searchResultsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SearchResultsCell

				switch searchScope {
				case .show, .thread, .user:
					searchResultsCell.searchElement = results?[indexPath.row]
				case .myLibrary: break
				}
			}

			if tableView.numberOfRows() == 1 {
				searchResultsCell.separatorView?.isHidden = true
			} else {
				searchResultsCell.separatorView?.isHidden = false
			}

			if indexPath.row == 0 {
				searchResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchResultsCell.visualEffectView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
			} else if indexPath.row == results!.count - 1 {
				searchResultsCell.visualEffectView?.layer.cornerRadius = 10
				searchResultsCell.visualEffectView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			} else {
				searchResultsCell.visualEffectView?.layer.cornerRadius = 0
			}

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
