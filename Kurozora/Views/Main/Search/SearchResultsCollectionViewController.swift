//
//  SearchResultsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/**
	The collection view controller in charge of providing the necessary functionalities for searching shows, threads and users.
*/
class SearchResultsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	/// The collection of results fetched by the search request.
	var searchResults: [Codable]? {
		didSet {
			if searchResults != nil {
				self.collectionView.reloadData()
			}
		}
	}

	/// The current scope of the search.
	var currentScope: SearchScope = .show

	/// The collection of suggested shows.
	var suggestionElements: [Show]? {
		didSet {
			if suggestionElements != nil {
				self.collectionView.reloadData()
			}
		}
	}

	/// The URL for the next set of resources.
	var nextPageURL: String?

	/// The object containing the search controller
	lazy var kSearchController: KSearchController = KSearchController()

	/// Whether to include a search controller in the navigation bar
	var includesSearchBar = true

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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Fetch user's search history.
		SearchHistory.getContent { showDetailsElements in
			self.suggestionElements = showDetailsElements
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		// Disable Refresh Control & hide Activity Indicator
		self._prefersRefreshControlDisabled = true
		self._prefersActivityIndicatorHidden = true

		if includesSearchBar {
			self.setupSearchController()
		}
    }

	// MARK: - Functions
	/// Setup the search controller with the desired settings.
	func setupSearchController() {
		// Set the current view as the view controller of the search
		self.kSearchController.viewController = self

		// Add search bar to navigation controller
		self.navigationItem.searchController = self.kSearchController
	}

	/**
		Disables or enables the user interaction on the current view. Also shows a loading indicator.

		- Parameter disable: Indicates whether to disable the interaction.
	*/
	func disableUserInteraction(_ disable: Bool) {
		self._prefersActivityIndicatorHidden = !disable
	}

	/**
		Perform search with the given search text and the search scope.

		- Parameter text: The string which to search for.
		- Parameter searchScope: The scope in which the text should be searched.
	*/
	func performSearch(withText text: String, in searchScope: SearchScope) {
		// Prepare view for search
		self.currentScope = searchScope

		// Decide with wich endpoint to perform the search
		switch searchScope {
		case .show:
			if self.nextPageURL == nil {
				// Show activity indicator.
				self._prefersActivityIndicatorHidden = false
			}

			// Perform show search request.
			KService.search(forShow: text, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let showResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.searchResults = []
					}

					// Append new data and save next page url
					self.searchResults?.append(contentsOf: showResponse.data)
					self.nextPageURL = showResponse.next

					// Hide activity indicator.
					self._prefersActivityIndicatorHidden = true
				case .failure:
					// Hide activity indicator.
					self._prefersActivityIndicatorHidden = true
				}
			}
		case .library:
			WorkflowController.shared.isSignedIn {
				if self.nextPageURL == nil {
					// Show activity indicator.
					self._prefersActivityIndicatorHidden = false
				}

				// Perform library search request.
				KService.searchLibrary(forShow: text, next: self.nextPageURL) { [weak self] result in
					guard let self = self else { return }
					switch result {
					case .success(let showResponse):
						// Reset data if necessary
						if self.nextPageURL == nil {
							self.searchResults = []
						}

						// Append new data and save next page url
						self.searchResults?.append(contentsOf: showResponse.data)
						self.nextPageURL = showResponse.next

						// Hide activity indicator.
						self._prefersActivityIndicatorHidden = true
					case .failure:
						// Hide activity indicator.
						self._prefersActivityIndicatorHidden = true
					}
				}
			}
		case .user:
			if self.nextPageURL == nil {
				// Show activity indicator.
				self._prefersActivityIndicatorHidden = false
			}

			// Perform user search request.
			KService.search(forUsername: text, next: self.nextPageURL) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let userResponse):
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.searchResults = []
					}

					// Append new data and save next page url
					self.searchResults?.append(contentsOf: userResponse.data)
					self.nextPageURL = userResponse.next

					// Hide activity indicator.
					self._prefersActivityIndicatorHidden = true
				case .failure:
					// Hide activity indicator.
					self._prefersActivityIndicatorHidden = true
				}
			}
		}
	}

	/// Sets all search results to nil and reloads the table view
	fileprivate func resetSearchResults() {
		self.nextPageURL = nil
		self.searchResults = nil
		self.collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var resultsCount = suggestionElements?.count

		if self.searchResults != nil {
			resultsCount = self.searchResults?.count
		}

		return resultsCount ?? 0
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if self.searchResults != nil {
			let searchBaseResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: currentScope.identifierString, for: indexPath) as! SearchBaseResultsCell
			searchBaseResultsCell.separatorView?.isHidden = indexPath.item == self.searchResults!.count - 1
			switch currentScope {
			case .show, .library:
				(searchBaseResultsCell as? SearchShowResultsCell)?.show = self.searchResults?[indexPath.row] as? Show
			case .user:
				(searchBaseResultsCell as? SearchUserResultsCell)?.user = self.searchResults?[indexPath.row] as? User
			}
			return searchBaseResultsCell
		}

		guard let searchResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchSuggestionResultCell, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(R.reuseIdentifier.searchSuggestionResultCell.identifier)")
		}
		searchResultsCell.show = suggestionElements?[indexPath.row]
		return searchResultsCell
	}
}

// MARK: - UISearchBarDelegate
extension SearchResultsCollectionViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		guard let searchScope = SearchScope(rawValue: selectedScope) else { return }
		guard let text = searchBar.text else { return }
		self.nextPageURL = nil

		switch searchScope {
		case .library:
			WorkflowController.shared.isSignedIn {
				self.performSearch(withText: text, in: searchScope)
				return
			}
			searchBar.selectedScopeButtonIndex = currentScope.rawValue
		default:
			self.performSearch(withText: text, in: searchScope)
		}
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		guard let searchScope = SearchScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }
		guard let text = searchBar.text else { return }
		self.nextPageURL = nil
		performSearch(withText: text, in: searchScope)
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.resetSearchResults()
	}
}
