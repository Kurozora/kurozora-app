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
	var forceShowsCancelButton: Bool = true

	// MARK: - Initializers
	override init(searchResultsController: UIViewController?) {
		super.init(searchResultsController: searchResultsController)
		self.delegate = self
	}

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.delegate = self
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.delegate = self
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.searchBar.placeholder = "I'm searching for..."
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.searchBar.delegate = viewController as? SearchResultsCollectionViewController
		self.searchBar.scopeButtonTitles = SearchScope.allString
		self.searchBar.selectedScopeButtonIndex = searchScope.rawValue
		self.searchBar.textField?.theme_textColor = KThemePicker.textColor.rawValue
	}

	// MARK: - Functions
	/// Updates the search placeholder with new placeholder string every second.
	@objc func updateSearchPlaceholder() {
		self.searchBar.placeholder = searchScope.placeholderString
	}

	/// Starts the placeholder timer for the search bar if no timers are already running.
	private func startPlaceholderTimer() {
		if self.placeholderTimer == nil {
			self.placeholderTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateSearchPlaceholder), userInfo: nil, repeats: true)
		}
	}

	/// Stops the placeholder timer if one is running.
	private func stopPlacholderTimer() {
		if self.placeholderTimer != nil {
			self.placeholderTimer?.invalidate()
			self.placeholderTimer = nil
		}
	}
}

// MARK: - UISearchControllerDelegate
extension KSearchController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		if self.forceShowsCancelButton {
			self.searchBar.showsCancelButton = true
		}

		self.stopPlacholderTimer()
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		if self.forceShowsCancelButton {
			self.searchBar.showsCancelButton = false
		}

		self.startPlaceholderTimer()
	}
}
