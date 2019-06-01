//
//  SearchController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SearchController: UISearchController, UISearchBarDelegate {
	let scopeButtonTitles = ["Anime", "My Library", "Thread", "User"]
	var homeCollectionViewController: HomeCollectionViewController?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.searchBar.placeholder = "I'm searching for..."
		self.searchResultsController?.view.isHidden = false

		guard let navigationController = homeCollectionViewController?.navigationController as? KNavigationController else { return }
		navigationController.toggleStyle(.blurred)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		searchBar.sizeToFit()

		let searchControllerBar = self.searchBar
		searchControllerBar.theme_barTintColor = KThemePicker.tintColor.rawValue
		searchControllerBar.barStyle = .black
		searchControllerBar.searchBarStyle = .default
		searchControllerBar.isTranslucent = true
		searchControllerBar.enableCancelButton()
		searchControllerBar.scopeButtonTitles = scopeButtonTitles
		searchControllerBar.textField?.theme_textColor = KThemePicker.textColor.rawValue
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		guard let navigationController = homeCollectionViewController?.navigationController as? KNavigationController else { return }
		navigationController.toggleStyle(.normal)
	}
}
