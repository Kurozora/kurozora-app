//
//  LibraryViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import Pageboy
import Tabman
import UIKit

class LibraryViewController: KTabbedViewController, ProfileNavigable {
	// MARK: - Views
	var profileBarButtonItem: ProfileBarButtonItem?
	var sortTypeBarButtonItem = UIBarButtonItem()
	var searchBarButtonItem = UIBarButtonItem()
	var moreBarButtonItem = UIBarButtonItem()

	var toolbar = UIToolbar()
	var libraryKindBarButtonItem = UIBarButtonItem()
	var libraryKindSegmentedControl = UISegmentedControl()

	var scrollView: UIScrollView = UIScrollView()
	var scrollViewContentView = UIView()

	// MARK: - Properties
	var libraryKind: LibraryKind = UserSettings.libraryKind
	var user: User?
	var viewedUser: User? {
		return self.user ?? User.current
	}

	weak var libraryViewControllerDataSource: LibraryViewControllerDataSource?
	weak var libraryViewControllerDelegate: LibraryViewControllerDelegate?

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureUserDetails()
			self.enableActions()

			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationItem.title = L10n.library

		self.configureView()

		self.enableActions()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
		self.navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
		self.navigationController?.navigationItem.leftItemsSupplementBackButton = true
	}

	// MARK: - Functions
	/// Configures the tab bar visibility.
	override func configureTabBarViewVisibility() {
		if self.viewedUser == nil {
			self.bar.isHidden = true
		} else {
			if let barItemsCount = self.bar.items?.count {
				self.bar.isHidden = barItemsCount <= 1
			}
		}
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileBarButtonItem?.image = User.current?.attributes.profileImageView.image ?? .Placeholders.userProfile
	}

	// MARK: - TMBarDataSource
	override func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		let sectionTitle: String

		switch self.libraryKind {
		case .shows:
			sectionTitle = LibraryStatus.all[index].showStringValue
		case .literatures:
			sectionTitle = LibraryStatus.all[index].literatureStringValue
		case .games:
			sectionTitle = LibraryStatus.all[index].gameStringValue
		}

		return TMBarItem(title: sectionTitle)
	}

	// MARK: - TMBarDelegate
	override func bar(_ bar: TMBar, didRequestScrollTo index: PageboyViewController.PageIndex) {
		super.bar(bar, didRequestScrollTo: index)
		#if targetEnvironment(macCatalyst)
		self.tabBarTouchBarItem?.selectedIndex = index
		#endif
	}

	// MARK: - PageboyViewControllerDataSource
	override func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		return self.viewedUser != nil ? LibraryStatus.all.count : 1
	}

	override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return self.viewedUser != nil ? .at(index: UserSettings.libraryPage) : nil
	}
}
