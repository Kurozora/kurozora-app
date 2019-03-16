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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.searchBar.placeholder = "I'm searching for..."
		self.searchResultsController?.view.isHidden = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let searchControllerBar = self.searchBar
		searchControllerBar.theme_barTintColor = "Global.tintColor"
		searchControllerBar.barStyle = .default
		searchControllerBar.scopeButtonTitles = scopeButtonTitles
		searchControllerBar.textField?.theme_textColor = "Global.textColor"
	}
}
