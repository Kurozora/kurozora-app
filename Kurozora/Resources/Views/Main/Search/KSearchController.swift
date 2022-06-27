//
//  KSearchController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class KSearchController: UISearchController {
	// MARK: - Properties
	weak var viewController: SearchResultsCollectionViewController?
	var searchScope: KKSearchScope = .kurozora
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
	override func viewDidLoad() {
		super.viewDidLoad()

		self.searchBar.delegate = self.viewController
		#if targetEnvironment(macCatalyst)
		self.searchBar.placeholder = Trans.search
		#else
		self.searchBar.placeholder = "Anime, Character, Person, and More"
		#endif
		self.searchBar.scopeButtonTitles = KKSearchScope.allString
		self.searchBar.selectedScopeButtonIndex = self.searchScope.rawValue
		self.searchBar.searchTextField.theme_textColor = KThemePicker.textColor.rawValue
	}
}

// MARK: - UISearchControllerDelegate
extension KSearchController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		if self.forceShowsCancelButton {
			self.searchBar.showsCancelButton = true
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		if self.forceShowsCancelButton {
			self.searchBar.showsCancelButton = false
		}
	}
}
