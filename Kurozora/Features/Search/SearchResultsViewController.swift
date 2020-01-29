//
//  SearchResultsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftTheme

class SearchResultsCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	var showResults: [ShowDetailsElement]? {
		didSet {
			if showResults != nil {
				self.collectionView.reloadData()
			}
		}
	}
	var threadResults: [ForumsThreadElement]? {
		didSet {
			if threadResults != nil {
				self.collectionView.reloadData()
			}
		}
	}
	var userResults: [UserProfile]? {
		didSet {
			if userResults != nil {
				self.collectionView.reloadData()
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

		collectionView.collectionViewLayout = createLayout()

		// Blurred table view background
		let blurEffect = UIBlurEffect(style: .regular)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)

		for subview in blurEffectView.subviews {
			subview.backgroundColor = nil
		}

		collectionView.backgroundView = blurEffectView
    }

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "search", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "SearchResultsCollectionViewController")
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
		collectionView.reloadData()
	}

	/// Performs search after the given amount of time has passed.
	@objc func search(_ timer: Timer) {
		let userInfo = timer.userInfo as? [String: Any]
		if let text = userInfo?["searchText"] as? String, let scope = userInfo?["searchScope"] as? Int {
			performSearch(forText: text, searchScope: scope)
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var resultsCount = suggestions.count

		if showResults != nil || threadResults != nil || userResults != nil {
			if let searchScope = SearchScope(rawValue: currentScope) {
				switch searchScope {
				case .show:
					resultsCount = showResults?.count ?? 0
				case .myLibrary: break
				case .thread:
					resultsCount = threadResults?.count ?? 0
				case .user:
					resultsCount = userResults?.count ?? 0
				}
			}
		}

		return resultsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if showResults != nil || threadResults != nil || userResults != nil {
			let searchScope = SearchScope(rawValue: currentScope) ?? .show
			let identifier = searchScope.identifierString
			let searchBaseResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SearchBaseResultsCell
			return searchBaseResultsCell
		}

		let searchResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchSuggestionResultCell", for: indexPath) as! SearchSuggestionResultCell
		return searchResultsCell
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if showResults != nil {
			(cell as? SearchShowResultsCell)?.showDetailsElement = showResults?[indexPath.row]
		} else if threadResults != nil {
			(cell as? SearchForumsResultsCell)?.forumsThreadElement = threadResults?[indexPath.row]
		} else if userResults != nil {
			(cell as? SearchUserResultsCell)?.userProfile = userResults?[indexPath.row]
		} else {
			(cell as? SearchSuggestionResultCell)?.showDetailsElement = suggestions[indexPath.row]
		}
	}
}

// MARK: - UICollectionViewDelegate
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let searchBaseResultsCell = collectionView.cellForItem(at: indexPath)
		if showResults != nil {
			if let showDetailsViewController = ShowDetailCollectionViewController.instantiateFromStoryboard() as? ShowDetailCollectionViewController {
				showDetailsViewController.showDetailsElement = (searchBaseResultsCell as? SearchShowResultsCell)?.showDetailsElement
				presentingViewController?.show(showDetailsViewController, sender: nil)
			}
		} else if threadResults != nil {
			if let threadTableViewController = ThreadTableViewController.instantiateFromStoryboard() as? ThreadTableViewController {
				threadTableViewController.forumsThreadElement = (searchBaseResultsCell as? SearchForumsResultsCell)?.forumsThreadElement
				presentingViewController?.show(threadTableViewController, sender: nil)
			}
		} else if userResults != nil {
			if let profileTableViewController = ProfileTableViewController.instantiateFromStoryboard() as? ProfileTableViewController {
				profileTableViewController.userID = (searchBaseResultsCell as? SearchUserResultsCell)?.userProfile?.id
				presentingViewController?.show(profileTableViewController, sender: nil)
			}
		} else {
			if let showDetailsViewController = ShowDetailCollectionViewController.instantiateFromStoryboard() as? ShowDetailCollectionViewController {
				showDetailsViewController.showDetailsElement = (searchBaseResultsCell as? SearchSuggestionResultCell)?.showDetailsElement
				presentingViewController?.show(showDetailsViewController, sender: nil)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SearchResultsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		if showResults != nil || threadResults != nil || userResults != nil {
			return 1
		}

		let width = layoutEnvironment.container.contentSize.width
		var columnCount = (width / 110).rounded().int
		if columnCount < 0 {
			columnCount = 1
		} else if columnCount > 5 {
			columnCount = 5
		}
		return columnCount
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int) -> CGFloat {
		if showResults != nil {
			return UIDevice.isPhone && UIDevice.isPortrait ? 0.40 : 0.25
		} else if threadResults != nil {
			return UIDevice.isPhone && UIDevice.isPortrait ? 0.30 : 0.15
		} else if userResults != nil {
			return UIDevice.isPhone && UIDevice.isPortrait ? 0.25 : 0.20
		}
		return (1.50 / columnsCount.double).cgFloat
	}

	override func contentInset(forItemInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let leadingInset = collectionView.directionalLayoutMargins.leading
		let trailingInset = collectionView.directionalLayoutMargins.trailing
		return NSDirectionalEdgeInsets(top: 20, leading: leadingInset, bottom: 20, trailing: trailingInset)
	}

	override func contentInset(forBackgroundInSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		let leadingInset = collectionView.directionalLayoutMargins.leading
		let trailingInset = collectionView.directionalLayoutMargins.trailing
		return NSDirectionalEdgeInsets(top: 20, leading: leadingInset, bottom: 20, trailing: trailingInset)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let heightFraction = self.groupHeightFraction(forSection: section, with: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												   heightDimension: .fractionalWidth(heightFraction))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)

			let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.elementKindSectionBackground)
			sectionBackgroundDecoration.contentInsets = self.contentInset(forBackgroundInSection: section, layout: layoutEnvironment)
			layoutSection.decorationItems = [sectionBackgroundDecoration]

			return layoutSection
		}
		layout.register(SectionBackgroundDecorationView.self, forDecorationViewOfKind: SectionBackgroundDecorationView.elementKindSectionBackground)
		return layout
	}
}

// MARK: - UISearchResultsUpdating
extension SearchResultsCollectionViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		searchController.searchResultsController?.view.isHidden = false
	}
}

// MARK: - UISearchBarDelegate
extension SearchResultsCollectionViewController: UISearchBarDelegate {
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
