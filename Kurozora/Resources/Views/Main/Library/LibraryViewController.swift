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

class LibraryViewController: KTabbedViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageButton: ProfileImageButton!
	@IBOutlet weak var toolbar: UIToolbar!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var sortTypeBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var libraryKindBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var libraryKindSegmentedControl: UISegmentedControl!
	@IBOutlet weak var moreBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var rightBarButtonItems: [UIBarButtonItem]?
	var leftBarButtonItems: [UIBarButtonItem]?
	var libraryKind: KKLibrary.Kind = UserSettings.libraryKind
	var user: User?
	var viewedUser: User? {
		return self.user ?? User.current
	}

	weak var libraryViewControllerDataSource: LibraryViewControllerDataSource?
	weak var libraryViewControllerDelegate: LibraryViewControllerDelegate?

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.configureUserDetails()
		self.enableActions()

		#if targetEnvironment(macCatalyst)
		self.touchBar = nil
		#endif
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationItem.title = Trans.library

		// Configurations
		self.configureToolbar()
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.libraryKindBarButtonItem.hidesSharedBackground = true
		}
		self.configureUserDetails()

		// Actions
		self.enableActions()

		// Make sure scrollView is always first hierarchically
		self.view.sendSubviewToBack(self.scrollView)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
		self.navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
		self.navigationController?.navigationItem.leftItemsSupplementBackButton = true
	}

	// MARK: - Functions
	override func configureTabBarViewVisibility() {
		if self.viewedUser == nil {
			self.bar.isHidden = true
		} else {
			if let barItemsCount = self.bar.items?.count {
				self.bar.isHidden = barItemsCount <= 1
			}
		}
	}

	func configureToolbar() {
		self.toolbar.delegate = self
		self.toolbar.isTranslucent = false
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.profileImageButton?.setImage(User.current?.attributes.profileImageView.image ?? .Placeholders.userProfile, for: .normal)
		}
	}

	/// Performs segue to the profile view.
	@objc func segueToProfile() {
		Task { [weak self] in
			guard let self = self else { return }
			let signedIn = await WorkflowController.shared.isSignedIn(on: self)
			guard signedIn else { return }

			if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
				self.show(profileTableViewController, sender: nil)
			}
		}
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			guard let index = self.currentIndex else { return }

			self.moreBarButtonItem.menu = self.viewedUser?.makeLibraryContextMenu(in: self, userInfo: [
				"includeUser": self.user != nil,
				"index": index,
			], sourceView: nil, barButtonItem: self.moreBarButtonItem)
			self.populateSortActions()
			self.libraryKindSegmentedControl.segmentTitles = KKLibrary.Kind.allString
			self.libraryKindSegmentedControl.selectedSegmentIndex = self.libraryKind.rawValue

			if self.viewedUser == nil {
				self.toolbar.isHidden = true

				self.rightBarButtonItems = self.navigationItem.rightBarButtonItems
				self.leftBarButtonItems = self.navigationItem.leftBarButtonItems

				self.navigationItem.rightBarButtonItems = nil
				self.navigationItem.leftBarButtonItems = nil
			} else if self.viewedUser != User.current {
				self.toolbar.isHidden = false

				self.navigationItem.rightBarButtonItems = self.navigationItem.rightBarButtonItems?.filter { barButtonItem in
					barButtonItem.customView != self.profileImageButton
				}
			} else {
				self.toolbar.isHidden = false

				if self.navigationItem.rightBarButtonItems == nil, self.rightBarButtonItems != nil {
					self.navigationItem.rightBarButtonItems = self.rightBarButtonItems
				}

				if self.navigationItem.leftBarButtonItems == nil, self.leftBarButtonItems != nil {
					self.navigationItem.leftBarButtonItems = self.leftBarButtonItems
				}
			}
		}
	}

	/// Updates the layout button icon to reflect the current layout when switching between views.
	///
	/// - Parameters:
	///    - index: The index of the selected view.
	fileprivate func updateLayoutMenuAction(for index: Int?) {
		guard let index = index else { return }
		self.moreBarButtonItem.menu = self.viewedUser?.makeLibraryContextMenu(in: self, userInfo: [
			"includeUser": self.user != nil,
			"index": index,
		], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	/// Updates the sort type button icon to reflect the current sort type when switching between views.
	///
	/// - Parameters:
	///    - sortType: The selected sort type.
	///    - option: The selected sort type option.
	fileprivate func updateSortTypeBarButtonItem(sortType: KKLibrary.SortType, option: KKLibrary.SortType.Option) {
		self.sortTypeBarButtonItem.title = "Sorting by \(sortType.stringValue) (\(option.stringValue))"
		self.sortTypeBarButtonItem.image = sortType == .none
			? UIImage(systemName: "line.3.horizontal.decrease.circle")
			: UIImage(systemName: "line.3.horizontal.decrease.circle.fill") //		self.populateSortActions()
	}

	/// Changes the layout between the available library cell styles.
	///
	/// - Parameters:
	///    - libraryCellStyle: The selected library cell style.
	func changeLayout(to libraryCellStyle: KKLibrary.CellStyle) {
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }

		// Save cell style change to UserSettings
		var libraryLayouts = UserSettings.libraryCellStyles
		libraryLayouts[currentSection.libraryStatus.sectionValue] = libraryCellStyle.rawValue
		UserSettings.set(libraryLayouts, forKey: .libraryCellStyles)

		// Update menu
		self.updateLayoutMenuAction(for: self.currentIndex)

		// Update library list
		currentSection.libraryCellStyle = libraryCellStyle

		UIView.animate(withDuration: 0.2) {
			currentSection.collectionView.reloadData()
		}
	}

	/// Builds and presents the sort types in an action sheet.
	fileprivate func populateSortActions() {
		var menuItems: [UIMenuElement] = []

		// Create sorting action
		KKLibrary.SortType.allCases.forEach { [weak self] sortType in
			guard let self = self else { return }
			var subMenuItems: [UIAction] = []
			let sortTypeSelected = self.libraryViewControllerDataSource?.sortValue() == sortType

			for option in sortType.optionValue {
				let sortOptionSelected = self.libraryViewControllerDataSource?.sortOptionValue() == option
				let actionIsOn = sortTypeSelected && sortOptionSelected

				let action = UIAction(title: option.stringValue, image: option.imageValue, state: actionIsOn ? .on : .off) { _ in
					self.libraryViewControllerDelegate?.sortLibrary(by: sortType, option: option)
					self.populateSortActions()
				}
				subMenuItems.append(action)
			}

			let submenu = UIMenu(title: sortType.stringValue, image: sortType.imageValue, children: subMenuItems)
			menuItems.append(submenu)
		}

		// Create "Stop sorting" action
		if let sortValue = self.libraryViewControllerDataSource?.sortValue(), sortValue != .none {
			let stopSortingAction = UIAction(title: "Stop sorting", image: UIImage(systemName: "xmark.circle.fill"), attributes: .destructive) { [weak self] _ in
				guard let self = self else { return }
				self.libraryViewControllerDelegate?.sortLibrary(by: .none, option: .none)
				self.populateSortActions()
			}
			let stopSortingMenu = UIMenu(title: "", options: .displayInline, children: [stopSortingAction])

			menuItems.append(stopSortingMenu)
		}

		self.sortTypeBarButtonItem.menu = UIMenu(title: "", children: menuItems)
	}

	#if targetEnvironment(macCatalyst)
	/// Goes to the selected view.
	@objc func goToSelectedView(_ touchBarItem: NSPickerTouchBarItem) {
		self.bar.delegate?.bar(self.bar, didRequestScrollTo: touchBarItem.selectedIndex)
		self.populateSortActions()
	}
	#endif

	// MARK: - IBActions
	@IBAction func libraryKindSegmentedControlDidChange(_ sender: UISegmentedControl) {
		guard let libraryKind = KKLibrary.Kind(rawValue: sender.selectedSegmentIndex) else { return }
		self.libraryKind = libraryKind
		self.bar.reloadData(at: 0 ... KKLibrary.Status.all.count - 1, context: .full)
		UserSettings.set(libraryKind.rawValue, forKey: .libraryKind)
		self.libraryViewControllerDelegate?.libraryViewController(self, didChange: libraryKind)
		self.populateSortActions()
	}

	@IBAction func profileButtonPressed(_ sender: UIButton) {
		self.segueToProfile()
	}

	// MARK: - TMBarDataSource
	override func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		let sectionTitle: String

		switch self.libraryKind {
		case .shows:
			sectionTitle = KKLibrary.Status.all[index].showStringValue
		case .literatures:
			sectionTitle = KKLibrary.Status.all[index].literatureStringValue
		case .games:
			sectionTitle = KKLibrary.Status.all[index].gameStringValue
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
		return self.viewedUser != nil ? KKLibrary.Status.all.count : 1
	}

	override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return self.viewedUser != nil ? .at(index: UserSettings.libraryPage) : nil
	}
}

// MARK: - LibraryListViewControllerDelegate
extension LibraryViewController: LibraryListViewControllerDelegate {
	func libraryListViewController(willScrollTo index: Int) {
		self.updateLayoutMenuAction(for: index)
	}

	func libraryListViewController(updateSortWith sortType: KKLibrary.SortType, sortOption: KKLibrary.SortType.Option) {
		self.updateSortTypeBarButtonItem(sortType: sortType, option: sortOption)
	}

	func libraryListViewController(updateTotalCount totalCount: Int) {
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 9.0, *) {
			self.navigationItem.subtitle = totalCount > 0 ? "\(totalCount) Items" : nil
		} else {
			self.navigationItem.title = "\(Trans.library)\(totalCount > 0 ? " (\(totalCount))" : "")"
		}
	}
}

// MARK: - KTabbedViewControllerDataSource
extension LibraryViewController {
	override func initializeViewControllers(with count: Int) -> [UIViewController] {
		var viewControllers: [UIViewController] = []

		for index in 0 ..< count {
			if let libraryListCollectionViewController = R.storyboard.libraryList.libraryListCollectionViewController() {
				let libraryStatus = KKLibrary.Status.all[index]

				// Get the user's preferred library layout
				let libraryLayouts = UserSettings.libraryCellStyles
				let preferredLayout = libraryLayouts[libraryStatus.sectionValue] ?? 0
				if let libraryCellStyle = KKLibrary.CellStyle(rawValue: preferredLayout) {
					libraryListCollectionViewController.libraryCellStyle = libraryCellStyle
				}

				libraryListCollectionViewController.libraryStatus = libraryStatus
				libraryListCollectionViewController.sectionIndex = index
				libraryListCollectionViewController.user = self.user
				libraryListCollectionViewController.delegate = self
				viewControllers.append(libraryListCollectionViewController)
			}
		}

		return viewControllers
	}
}

// MARK: - UIToolbarDelegate
extension LibraryViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}
