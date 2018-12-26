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
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let searchControllerBar = self.searchBar
		searchControllerBar.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
		searchControllerBar.scopeButtonTitles = scopeButtonTitles

		if let textfield = searchControllerBar.value(forKey: "searchField") as? UITextField {
			textfield.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
		}
	}
}
