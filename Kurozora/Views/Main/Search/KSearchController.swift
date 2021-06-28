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

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		searchBar.placeholder = "I'm searching for..."
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self

		searchBar.delegate = viewController as? SearchResultsCollectionViewController
		searchBar.scopeButtonTitles = SearchScope.allString
		searchBar.selectedScopeButtonIndex = searchScope.rawValue
		searchBar.textField?.theme_textColor = KThemePicker.textColor.rawValue
	}

	// MARK: - Functions
	/// Updates the search placeholder with new placeholder string every second.
	@objc func updateSearchPlaceholder() {
		searchBar.placeholder = searchScope.placeholderString
	}

	/// Starts the placeholder timer for the search bar if no timers are already running.
	private func startPlaceholderTimer() {
		if placeholderTimer == nil {
			placeholderTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateSearchPlaceholder), userInfo: nil, repeats: true)
		}
	}

	/// Stops the placeholder timer if one is running.
	private func stopPlacholderTimer() {
		if placeholderTimer != nil {
			placeholderTimer?.invalidate()
			placeholderTimer = nil
		}
	}
}

// MARK: - UISearchControllerDelegate
extension KSearchController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		#if targetEnvironment(macCatalyst)
		#else
		searchBar.showsCancelButton = true
		#endif

		self.stopPlacholderTimer()
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		#if targetEnvironment(macCatalyst)
		#else
		searchBar.showsCancelButton = false
		#endif

		self.startPlaceholderTimer()
	}
}
