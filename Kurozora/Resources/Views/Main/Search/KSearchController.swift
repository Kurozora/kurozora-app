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
	var searchScope: SearchScope = .kurozora

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

		if let viewController = self.viewController {
			if #available(iOS 16.0, *) {
				self.searchResultsUpdater = viewController
			}

			switch viewController.searchViewKind {
			case .single:
				self.searchBar.placeholder = L10n.search
				self.searchBar.showsScopeBar = false
				self.searchBar.scopeButtonTitles = [SearchScope.kurozora.stringValue]
			case .multiple:
				#if targetEnvironment(macCatalyst)
				self.searchBar.placeholder = L10n.search
				#else
				self.searchBar.placeholder = "Anime, Manga, Games and More"
				self.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .bookmark, state: .normal)
				#endif
				self.searchBar.scopeButtonTitles = SearchScope.allString
			case .library:
				self.searchBar.placeholder = L10n.searchLibrary
				self.searchBar.showsScopeBar = false
				self.searchBar.scopeButtonTitles = [SearchScope.library.stringValue]
				self.searchScope = .library
				#if !targetEnvironment(macCatalyst)
				self.searchBar.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .bookmark, state: .normal)
				#endif
			}
		}

		self.searchBar.selectedScopeButtonIndex = self.searchScope.rawValue
		self.searchBar.searchTextField.theme_textColor = KThemePicker.textColor.rawValue
		self.searchBar.searchTextField.theme_tokenBackgroundColor = KThemePicker.tintedBackgroundColor.rawValue

		if #available(iOS 16.0, *) {
			self.obscuresBackgroundDuringPresentation = false
		}
	}
}

// MARK: - UISearchControllerDelegate
extension KSearchController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		guard let viewController = self.viewController else { return }

		switch viewController.searchViewKind {
		case .single:
			if #available(iOS 16.0, *) {
				self.scopeBarActivation = .manual
				self.searchBar.showsScopeBar = false
			} else {
				self.automaticallyShowsScopeBar = false
			}
		case .multiple:
			if #available(iOS 16.0, *) {
				#if targetEnvironment(macCatalyst)
				self.scopeBarActivation = .manual
				self.searchBar.showsScopeBar = true
				#else
				self.scopeBarActivation = .onSearchActivation
				#endif
			} else {
				self.automaticallyShowsScopeBar = true
			}
		case .library:
			if #available(iOS 16.0, *) {
				self.scopeBarActivation = .manual
				self.searchBar.showsScopeBar = false
			} else {
				self.automaticallyShowsScopeBar = false
			}
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		#if targetEnvironment(macCatalyst)
		self.searchBar.showsScopeBar = false
		#endif
	}
}
