//
//  SearchResultsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import TRON

/**
	The collection view controller in charge of providing the necessary functionalities for searching shows, threads and users.
*/
class SearchResultsCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	/// The collection of results fetched by the search request.
	var searchResults: [JSONDecodable]? {
		didSet {
			if searchResults != nil {
				self.collectionView.reloadData()
			}
		}
	}

	/// A timer that fires after a certain time interval has elapsed, sending a specified message to a target object.
	var timer: Timer?

	/// The current scope of the search.
	var currentScope: SearchScope = .show

	/// The collection of suggested shows.
	var suggestionElements: [ShowDetailsElement]? {
		didSet {
			if suggestionElements != nil {
				self.collectionView.reloadData()
			}
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return KThemePicker.statusBarStyle.statusBarValue
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Fetch user's search history.
		SearchHistory.getContent({ (showDetailsElements) in
			self.suggestionElements = showDetailsElements
		})
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// Create colelction view layout
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
		Perform search with the given search text and the search scope.

		- Parameter text: The string which to search for.
		- Parameter searchScope: The scope in which the text should be searched.
	*/
	fileprivate func performSearch(withText text: String, in searchScope: SearchScope) {
		// Prepare view for search
		self.emptySearchResults()
		self.currentScope = searchScope

		// Decide with wich endpoint to perform the search
		if !text.isEmpty {
			switch searchScope {
			case .show:
				KService.search(forShow: text) { result in
					switch result {
					case .success(let showResults):
						DispatchQueue.main.async {
							self.searchResults = showResults
						}
					case .failure:
						break
					}
				}
			case .myLibrary:
				WorkflowController.shared.isSignedIn {
					guard let userID = User.current?.id else { return }
					KService.search(inUserLibrary: userID, forShow: text) { result in
						switch result {
						case .success(let showResults):
							DispatchQueue.main.async {
								self.searchResults = showResults
							}
						case .failure:
							break
						}
					}
				}
			case .thread:
				KService.search(forThread: text) { result in
					switch result {
					case .success(let threadResults):
						DispatchQueue.main.async {
							self.searchResults = threadResults
						}
					case .failure:
						break
					}
				}
			case .user:
				KService.search(forUsername: text) { result in
					switch result {
					case .success(let userResults):
						DispatchQueue.main.async {
							self.searchResults = userResults
						}
					case .failure:
						break
					}
				}
			}
		}
	}

	/// Sets all search results to nil and reloads the table view
	fileprivate func emptySearchResults() {
		searchResults = nil
		collectionView.reloadData()
	}

	/**
		Performs search after the given amount of time has passed.

		 - Parameter timer: The timer object used to determin when to perform the search.
	*/
	@objc func search(_ timer: Timer) {
		let userInfo = timer.userInfo as? [String: Any]
		if let text = userInfo?["searchText"] as? String, let searchScope = userInfo?["searchScope"] as? SearchScope {
			performSearch(withText: text, in: searchScope)
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var resultsCount = suggestionElements?.count
		if UIDevice.isPhone, UIDevice.isPortrait || UIDevice.isFlat, resultsCount ?? 0 > 6 {
			resultsCount = 6
		}

		if searchResults != nil {
			resultsCount = searchResults?.count
		}

		return resultsCount ?? 0
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if searchResults != nil {
			let searchBaseResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: currentScope.identifierString, for: indexPath) as! SearchBaseResultsCell
			switch currentScope {
			case .show, .myLibrary:
				(searchBaseResultsCell as? SearchShowResultsCell)?.showDetailsElement = searchResults?[indexPath.row] as? ShowDetailsElement
			case .thread:
				(searchBaseResultsCell as? SearchForumsResultsCell)?.forumsThreadElement = searchResults?[indexPath.row] as? ForumsThreadElement
			case .user:
				(searchBaseResultsCell as? SearchUserResultsCell)?.userProfile = searchResults?[indexPath.row] as? UserProfile
			}
			return searchBaseResultsCell
		}

		guard let searchResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.searchSuggestionResultCell, for: indexPath) else {
			fatalError("Cannot dequeue cell with reuse identifier \(R.reuseIdentifier.searchSuggestionResultCell.identifier)")
		}
		searchResultsCell.showDetailsElement = suggestionElements?[indexPath.row]
		return searchResultsCell
	}
}

// MARK: - UICollectionViewDelegate
extension SearchResultsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let searchBaseResultsCell = collectionView.cellForItem(at: indexPath)
		if searchResults != nil {
			switch currentScope {
			case .show, .myLibrary:
				if let showDetailsViewController = R.storyboard.showDetails.showDetailCollectionViewController() {
					let showDetailsElement = (searchBaseResultsCell as? SearchShowResultsCell)?.showDetailsElement
					showDetailsViewController.showDetailsElement = showDetailsElement
					SearchHistory.saveContentsOf(showDetailsElement)
					presentingViewController?.show(showDetailsViewController, sender: nil)
				}
			case .thread:
				if let threadTableViewController = R.storyboard.forums.threadTableViewController() {
					threadTableViewController.forumsThreadElement = (searchBaseResultsCell as? SearchForumsResultsCell)?.forumsThreadElement
					presentingViewController?.show(threadTableViewController, sender: nil)
				}
			case .user:
				if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
					profileTableViewController.userProfile = (searchBaseResultsCell as? SearchUserResultsCell)?.userProfile
					presentingViewController?.show(profileTableViewController, sender: nil)
				}
			}
		} else {
			if let showDetailsViewController = R.storyboard.showDetails.showDetailCollectionViewController() {
				showDetailsViewController.showDetailsElement = (searchBaseResultsCell as? SearchSuggestionResultCell)?.showDetailsElement
				presentingViewController?.show(showDetailsViewController, sender: nil)
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension SearchResultsCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		if searchResults != nil {
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
		if searchResults != nil {
			switch currentScope {
			case .show, .myLibrary:
				if UIDevice.isPhone, UIDevice.isPortrait || UIDevice.isFlat {
					return 0.40
				}
				return 0.25
			case .thread:
				if UIDevice.isPhone, UIDevice.isPortrait || UIDevice.isFlat {
					return 0.30
				}
				return 0.15
			case .user:
				if UIDevice.isPhone, UIDevice.isPortrait || UIDevice.isFlat {
					return 0.25
				}
				return 0.20
			}
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

		switch searchScope {
		case .myLibrary:
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
		performSearch(withText: text, in: searchScope)
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		guard let searchScope = SearchScope(rawValue: searchBar.selectedScopeButtonIndex) else { return }

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
