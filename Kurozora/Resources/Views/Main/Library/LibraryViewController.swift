//
//  LibraryViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Tabman
import Pageboy

class LibraryViewController: KTabbedViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageButton: ProfileImageButton!
	@IBOutlet weak var toolbar: UIToolbar!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var changeLayoutBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var sortTypeBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var libraryKindSegmentedControl: UISegmentedControl!

	// MARK: - Properties
	var rightBarButtonItems: [UIBarButtonItem]? = nil
	var leftBarButtonItems: [UIBarButtonItem]? = nil
	var libraryKind: KKLibrary.Kind = UserSettings.libraryKind

	weak var libraryViewControllerDataSource: LibraryViewControllerDataSource?
	weak var libraryViewControllerDelegate: LibraryViewControllerDelegate?

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.enableActions()
			self.configureUserDetails()
		}

		#if targetEnvironment(macCatalyst)
		self.touchBar = nil
		#endif
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// Configurations
		self.configureToolbar()
		self.configureUserDetails()

		// Actions
		self.enableActions()

		// Make sure scrollView is always first hierarchically
		self.view.sendSubviewToBack(scrollView)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.navigationController?.navigationBar.standardAppearance.shadowColor = .clear
		self.navigationController?.navigationBar.compactAppearance?.shadowColor = .clear
	}

	// MARK: - Functions
	override func configureTabBarViewVisibility() {
		if User.isSignedIn {
			if let barItemsCount = self.bar.items?.count {
				self.bar.isHidden = barItemsCount <= 1
			}
		} else {
			self.bar.isHidden = true
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
		self.profileImageButton.setImage(User.current?.attributes.profileImageView.image ?? R.image.placeholders.userProfile(), for: .normal)
	}

	/// Performs segue to the profile view.
	@objc func segueToProfile() {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }
			if let profileTableViewController = R.storyboard.profile.profileTableViewController() {
				self.show(profileTableViewController, sender: nil)
			}
		}
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.libraryKindSegmentedControl.segmentTitles = KKLibrary.Kind.allString
			self.libraryKindSegmentedControl.selectedSegmentIndex = self.libraryKind.rawValue

			if !User.isSignedIn {
				self.toolbar.isHidden = true

				self.rightBarButtonItems = self.navigationItem.rightBarButtonItems
				self.leftBarButtonItems = self.navigationItem.leftBarButtonItems

				self.navigationItem.rightBarButtonItems = nil
				self.navigationItem.leftBarButtonItems = nil
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
	fileprivate func updateChangeLayoutBarButtonItem(_ cellStyle: KKLibrary.CellStyle) {
		self.changeLayoutBarButtonItem.tag = cellStyle.rawValue
		self.changeLayoutBarButtonItem.title = cellStyle.stringValue
		self.changeLayoutBarButtonItem.image = cellStyle.imageValue
	}

	/// Updates the sort type button icon to reflect the current sort type when switching between views.
	fileprivate func updateSortTypeBarButtonItem(_ sortType: KKLibrary.SortType) {
		self.sortTypeBarButtonItem.tag = sortType.rawValue
		self.sortTypeBarButtonItem.title = sortType.stringValue
		self.sortTypeBarButtonItem.image = sortType.imageValue
	}

	fileprivate func savePreferredCellStyle(for currentSection: LibraryListCollectionViewController) {
		var libraryLayouts = UserSettings.libraryCellStyles
		libraryLayouts[currentSection.libraryStatus.sectionValue] = changeLayoutBarButtonItem.tag
		UserSettings.set(libraryLayouts, forKey: .libraryCellStyles)
	}

	/// Changes the layout between the available library cell styles.
	fileprivate func changeLayout() {
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }
		var libraryCellStyle: KKLibrary.CellStyle = KKLibrary.CellStyle(rawValue: changeLayoutBarButtonItem.tag) ?? .detailed

		// Change button information
		libraryCellStyle = libraryCellStyle.next
		self.changeLayoutBarButtonItem.tag = libraryCellStyle.rawValue
		self.changeLayoutBarButtonItem.title = libraryCellStyle.stringValue
		self.changeLayoutBarButtonItem.image = libraryCellStyle.imageValue

		// Save cell style change to UserSettings
		self.savePreferredCellStyle(for: currentSection)

		// Update library list
		currentSection.libraryCellStyle = libraryCellStyle

		UIView.animate(withDuration: 0.2) {
			currentSection.collectionView.reloadData()
		}
	}

	/// Builds and presents the sort types in an action sheet.
	///
	/// - Parameter sender: The object containing a reference to the button that initiated this action.
	fileprivate func populateSortActions(_ sender: UIBarButtonItem) {
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.SortType.alertControllerItems, currentSelection: self.libraryViewControllerDataSource?.sortValue()) { [weak self] _, value, _  in
			guard let self = self else { return }
			let subActionSheetAlertController = UIAlertController.actionSheetWithItems(items: value.subAlertControllerItems, currentSelection: self.libraryViewControllerDataSource?.sortOptionValue()) { _, subValue, _ in
				self.libraryViewControllerDelegate?.sortLibrary(by: value, option: subValue)
			}

			// Present the controller
			if let popoverController = subActionSheetAlertController.popoverPresentationController {
				popoverController.barButtonItem = sender
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(subActionSheetAlertController, animated: true, completion: nil)
			}
		}

		if let sortValue = self.libraryViewControllerDataSource?.sortValue() {
			if sortValue != .none {
				// Report thread action
				let stopSortingAction = UIAlertAction(title: "Stop sorting", style: .destructive) { [weak self] _ in
					guard let self = self else { return }
					self.libraryViewControllerDelegate?.sortLibrary(by: .none, option: .none)
				}
				stopSortingAction.setValue(UIImage(systemName: "xmark.circle.fill"), forKey: "image")
				stopSortingAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				actionSheetAlertController.addAction(stopSortingAction)
			}
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	#if targetEnvironment(macCatalyst)
	/// Goes to the selected view.
	@objc func goToSelectedView(_ touchBarItem: NSPickerTouchBarItem) {
		self.bar.delegate?.bar(self.bar, didRequestScrollTo: touchBarItem.selectedIndex)
	}
	#endif

	/// Segues to the favorites view.
	@objc func segueToFavorites() {
		self.performSegue(withIdentifier: R.segue.libraryViewController.favoritesSegue, sender: nil)
	}

	// MARK: - IBActions
	@IBAction func changeLayoutBarButtonItemPressed(_ sender: UIBarButtonItem) {
		self.changeLayout()
	}

	@IBAction func sortTypeBarButtonItemPressed(_ sender: UIBarButtonItem) {
		self.populateSortActions(sender)
	}

	@IBAction func libraryKindSegmentdControlDidChange(_ sender: UISegmentedControl) {
		guard let libraryKind = KKLibrary.Kind(rawValue: sender.selectedSegmentIndex) else { return }
		self.libraryKind = libraryKind
		self.bar.reloadData(at: 0...KKLibrary.Status.all.count - 1, context: .full)
		self.libraryViewControllerDelegate?.libraryViewController(self, didChange: libraryKind)
		UserSettings.set(libraryKind.rawValue, forKey: .libraryKind)
	}

	@IBAction func profileButtonPressed(_ sender: UIButton) {
		self.segueToProfile()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.libraryViewController.favoritesSegue.identifier:
			guard let favoritesCollectionViewController = segue.destination as? FavoritesCollectionViewController else { return }
			favoritesCollectionViewController.libraryKind = self.libraryKind
		default: break
		}
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
		let sectionsCount = User.isSignedIn ? KKLibrary.Status.all.count : 1
		return sectionsCount
	}

	override func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return User.isSignedIn ? .at(index: UserSettings.libraryPage) : nil
	}
}

// MARK: - LibraryListViewControllerDelegate
extension LibraryViewController: LibraryListViewControllerDelegate {
	func libraryListViewController(updateLayoutWith cellStyle: KKLibrary.CellStyle) {
		self.updateChangeLayoutBarButtonItem(cellStyle)
	}

	func libraryListViewController(updateSortWith sortType: KKLibrary.SortType) {
		self.updateSortTypeBarButtonItem(sortType)
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
