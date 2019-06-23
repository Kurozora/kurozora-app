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
		let statusBarStyle = UIStatusBarStyle.fromString(statusBarStyleString)

		return statusBarStyle
	}
	var results: [SearchElement]?
	var timer: Timer?
	var currentScope: Int!
	var suggestions: [SearchElement] {
		var results = [SearchElement]()

		let resultsArray: [JSON] = [
			["id": 118, "title": "ONE ~Kagayaku Kisetsu e~", "average_rating": 0, "poster_thumbnail": ""],
			["id": 202, "title": "Naruto", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/78857-9.jpg"],
			["id": 147, "title": "Outlaw Star", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/75911-5.jpg"],
			["id": 235, "title": "Kodocha", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/79544-2.jpg"],
			["id": 236, "title": "Re: Zero kara Hajimeru Isekai Seikatsu", "average_rating": 0, "poster_thumbnail": ""],
			["id": 56, "title": "Vampire Hunter D", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/79042-3.jpg"],
			["id": 22, "title": ".hack", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/79099-3.jpg"],
			["id": 28, "title": "Hellsing", "average_rating": 0, "poster_thumbnail": "https://www.thetvdb.com/banners/_cache/posters/71278-6.jpg"]
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
	fileprivate func search(forText text: String, searchScope: Int) {
		// Prepare view for search
		currentScope = searchScope

		guard let searchScope = SearchScope(rawValue: searchScope) else { return }

		if text != "" {
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
			}  else if segue.identifier == "ThreadSegue" {
				// Show detail for thread cell
				if let kurozoraNavigationController = segue.destination as? KNavigationController {
					let storyboard = UIStoryboard(name: "forums", bundle: nil)
					if let threadViewController = storyboard.instantiateViewController(withIdentifier: "Thread") as? ThreadViewController {
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

		if text != "" {
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
		
		if searchText != "" {
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
			let searchScope = SearchScope(rawValue: currentScope)
			let identifier = SearchList.fromScope(searchScope!)
			let searchResultsCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SearchResultsCell

			switch searchScope {
			case .show?, .thread?, .user?:
				searchResultsCell.searchElement = results?[indexPath.row]
			case .myLibrary?: break
			default: break
			}

			if tableView.numberOfRows() == 1 {
				searchResultsCell.separatorView?.isHidden = true
			} else {
				searchResultsCell.separatorView?.isHidden = false
			}

			if indexPath.row == 0 {
				searchResultsCell.visualEffectView?.roundCorners([.topRight, .topLeft], radius: 10)
			} else if indexPath.row == results!.count - 1 {
				searchResultsCell.visualEffectView?.roundCorners([.bottomRight, .bottomLeft], radius: 10)
			} else {
				searchResultsCell.visualEffectView?.roundCorners(.allCorners, radius: 0)
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
