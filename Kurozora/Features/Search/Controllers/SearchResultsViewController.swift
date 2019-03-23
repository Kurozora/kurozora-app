//
//  SearchResultsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import Kingfisher
import SwiftTheme

class SearchResultsViewController: UIViewController {
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var suggestionsCollectionView: UICollectionView!
	@IBOutlet weak var suggestionsCollctionViewHeight: NSLayoutConstraint!
	@IBOutlet weak var suggestionsHeaderView: UIView!

	var statusBarStyle: UIStatusBarStyle {
		guard let statusBarStyleString = ThemeManager.value(for: "UIStatusBarStyle") as? String else { return .default }
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		collectionView.isHidden = true
		collectionView.delegate = self
		collectionView.dataSource = self

		// Suggestions collection view
		suggestionsCollctionViewHeight.constant = suggestionsCollctionViewHeight.constant / 2
		suggestionsCollectionView.delegate = self
		suggestionsCollectionView.dataSource = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

		suggestionsCollectionView.isHidden = false
		suggestionsHeaderView.isHidden = false
		collectionView.isHidden = true
    }

	// MARK: - Functions
	fileprivate func search(forText text: String, searchScope: Int) {
		// Prepare view for search
		suggestionsCollectionView.isHidden = true
		suggestionsHeaderView.isHidden = true
		collectionView.isHidden = false
		currentScope = searchScope

		guard let searchScope = SearchScope(rawValue: searchScope) else { return }

		if text != "" {
			switch searchScope {
			case .show:
				Service.shared.search(forShow: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.collectionView.reloadData()
					}
				}
			case .myLibrary: break
			case .thread:
				Service.shared.search(forThread: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.collectionView.reloadData()
					}
				}
			case .user:
				Service.shared.search(forUser: text) { (results) in
					DispatchQueue.main.async {
						self.results = results
						self.collectionView.reloadData()
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
	@IBAction func showMoreButtonPressed(_ sender: UIButton) {
		if sender.title(for: .normal) == "Show More" {
			sender.setTitle("Show Less", for: .normal)
			self.suggestionsCollctionViewHeight.constant = self.suggestionsCollctionViewHeight.constant * 2
			UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		} else {
			sender.setTitle("Show More", for: .normal)
			self.suggestionsCollctionViewHeight.constant = self.suggestionsCollctionViewHeight.constant / 2
			UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}

	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let sender = sender as? Int {
			if segue.identifier == "ShowDetailsSegue" {
				// Show detail for show cell
				let showTabBarController = segue.destination as? ShowTabBarController
				showTabBarController?.showID = sender
			} else if segue.identifier == "ProfileSegue" {
				// Show user profile for user cell
				if let kurozoraNavigationController = segue.destination as? KurozoraNavigationController {
					if let profileViewController = kurozoraNavigationController.topViewController as? ProfileViewController {
						profileViewController.otherUserID = sender
					}
				}
			}  else if segue.identifier == "ThreadSegue" {
				// Show detail for thread cell
				if let kurozoraNavigationController = segue.destination as? KurozoraNavigationController {
					let storyboard = UIStoryboard(name: "forums", bundle: nil)
					if let threadViewController = storyboard.instantiateViewController(withIdentifier: "Thread") as? ThreadViewController {
						threadViewController.isDismissEnabled = true
						threadViewController.forumThreadID = sender

						kurozoraNavigationController.pushViewController(threadViewController)
					}
				}
			}
		}
	}
}

// MARK: - UISearchResultsUpdating
extension SearchResultsViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		suggestionsCollectionView.isHidden = false
		suggestionsHeaderView.isHidden = false
		collectionView.isHidden = true
		searchController.searchResultsController?.view.isHidden = false
	}
}

// MARK: - UISearchBarDelegate
extension SearchResultsViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = SearchScope(rawValue: selectedScope) else { return }
		guard let text = searchBar.text else { return }

		results = []
		collectionView.reloadData()

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
			results = []
			collectionView.reloadData()
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		results = []
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension SearchResultsViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		if collectionView == suggestionsCollectionView {
			return 10
		}
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		if collectionView == suggestionsCollectionView {
			return 10
		}
		return 0
	}

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == self.collectionView {
			if let resultsCount = results?.count, resultsCount != 0 {
				return resultsCount
			}
			return 0
		}
		// Search suggestion cell
		return suggestions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == self.collectionView {
			if let searchScope = SearchScope(rawValue: currentScope) {
				let identifier = SearchList.fromScope(searchScope)
				let searchCell: SearchCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SearchCell

				switch searchScope {
				case .show, .thread, .user:
					searchCell.searchElement = results?[indexPath.row]
				case .myLibrary: break
				}
				return searchCell
			}
		}

		// Search suggestion cell
		let searchSuggestionCell: SearchCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchSuggestionCell", for: indexPath) as! SearchCell

		searchSuggestionCell.searchElement = suggestions[indexPath.row]

		return searchSuggestionCell
    }
}

// MARK: - UICollectionViewDelegate
extension SearchResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == self.collectionView {
			guard let searchScope = SearchScope(rawValue: currentScope) else { return }
			guard let searchID = results?[indexPath.item].id else { return }

			switch searchScope {
			case .show:
				self.performSegue(withIdentifier: "ShowDetailsSegue", sender: searchID)
			case .myLibrary: break
			case .thread:
				self.performSegue(withIdentifier: "ThreadSegue", sender: searchID)
			case .user:
				self.performSegue(withIdentifier: "ProfileSegue", sender: searchID)
			}
		} else {
			// Search suggestion cell
			let showID = suggestions[indexPath.item].id
			self.performSegue(withIdentifier: "ShowDetailsSegue", sender: showID)
		}
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchResultsViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == self.collectionView {
			guard let searchScope = SearchScope(rawValue: currentScope) else { return CGSize.zero }
			let cellWidth = collectionView.bounds.size.width

			switch searchScope {
			case .show:
				return CGSize(width: cellWidth, height: 136)
			case .myLibrary: break
			case .thread, .user:
				return CGSize(width: cellWidth, height: 82)
			}
		}

		// Search suggestion cell
		let suggestionsCollectionViewSize = CGSize(width: 68, height: 130)
		return suggestionsCollectionViewSize
	}
}
