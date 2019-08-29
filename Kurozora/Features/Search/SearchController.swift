//
//  SearchController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SearchController: UISearchController, UISearchBarDelegate {
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

		let searchControllerBar = self.searchBar
		searchControllerBar.barStyle = .black
		searchControllerBar.searchBarStyle = .default
		searchControllerBar.isTranslucent = true
		searchControllerBar.enableCancelButton()
		searchControllerBar.scopeButtonTitles = scopeButtonTitles
		searchControllerBar.textField?.theme_textColor = KThemePicker.textColor.rawValue
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		guard let navigationController = viewController?.navigationController as? KNavigationController else { return }
		if #available(iOS 11.0, *) {
			navigationController.navigationItem.searchController?.searchBar.isHidden = true
		}
		navigationController.toggleStyle(.normal)
	}
}
