//
//  SearchController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SearchController: UISearchController {
	let scopeButtonTitles = SearchScope.allString
	var viewController: UIViewController?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.searchBar.placeholder = "I'm searching for..."
		self.searchResultsController?.view.isHidden = false

		guard let navigationController = viewController?.navigationController as? KNavigationController else { return }
		navigationController.toggleStyle(.blurred)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		searchBar.sizeToFit()
		searchBar.barStyle = .default
		searchBar.searchBarStyle = .default
		searchBar.isTranslucent = true
		searchBar.showsCancelButton = true
		searchBar.scopeButtonTitles = scopeButtonTitles
		searchBar.textField?.theme_textColor = KThemePicker.textColor.rawValue
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		guard let navigationController = viewController?.navigationController as? KNavigationController else { return }
		navigationController.navigationItem.searchController?.searchBar.isHidden = true
		navigationController.toggleStyle(.normal)
	}
}
