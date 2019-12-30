//
//  KSearchController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class KSearchController: UISearchController {
	// MARK: - Properties
	var placeholderTimer: Timer?
	var viewController: UIViewController?
	var searchScope: SearchScope = .show {
		didSet {
			self.startPlaceholderTimer()
		}
	}
	var searchResultsTableViewController: SearchResultsCollectionViewController?

	// MARK: - Initializer

	init() {
		searchResultsTableViewController = SearchResultsCollectionViewController.instantiateFromStoryboard() as? SearchResultsCollectionViewController
		super.init(searchResultsController: searchResultsTableViewController)
	}

	override init(searchResultsController: UIViewController?) {
		super.init(searchResultsController: searchResultsController)
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		searchBar.placeholder = "I'm searching for..."
		searchResultsController?.view.isHidden = false

		// Toggel navigation controller style
		let kNavigationController = viewController?.navigationController as? KNavigationController
		kNavigationController?.toggleStyle(.blurred)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		searchBar.sizeToFit()
		searchBar.barStyle = .default
		searchBar.searchBarStyle = .default
		searchBar.isTranslucent = true
		searchBar.scopeButtonTitles = SearchScope.allString
		searchBar.selectedScopeButtonIndex = searchScope.rawValue
		searchBar.textField?.theme_textColor = KThemePicker.textColor.rawValue
		searchBar.delegate = searchResultsTableViewController

		delegate = self
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Toggel navigation controller style
		let kNavigationController = viewController?.navigationController as? KNavigationController
		kNavigationController?.navigationItem.searchController?.searchBar.isHidden = true
		kNavigationController?.toggleStyle(.normal)
	}

	// MARK: - Functions
	/// Updates the search placeholder with new placeholder string every second.
	@objc func updateSearchPlaceholder() {
		searchBar.placeholder = searchScope.placeholderString
	}

	/// Starts the placeholder timer for the search bar if no timers are already running.
	func startPlaceholderTimer() {
		if placeholderTimer == nil {
			placeholderTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateSearchPlaceholder), userInfo: nil, repeats: true)
		}
	}

	/// Stops the placeholder timer if one is running.
	func stopPlacholderTimer() {
		if placeholderTimer != nil {
			placeholderTimer?.invalidate()
			placeholderTimer = nil
		}
	}
}

// MARK: - UISearchControllerDelegate
extension KSearchController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		searchBar.showsCancelButton = true
		#if targetEnvironment(macCatalyst)
		searchController.searchBar.showsScopeBar = true
		#endif

		if var tabBarFrame = viewController?.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.viewController?.tabBarController?.tabBar.isHidden = true
			})
		}

		self.stopPlacholderTimer()
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		searchBar.showsCancelButton = false
		#if targetEnvironment(macCatalyst)
		searchController.searchBar.showsScopeBar = false
		#endif

		if var tabBarFrame = viewController?.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.viewController?.tabBarController?.tabBar.isHidden = false
			})
		}

		self.startPlaceholderTimer()
	}
}
