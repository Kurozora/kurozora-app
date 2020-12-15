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

protocol LibraryViewControllerDelegate: class {
	/**
		Tells your `LibraryViewControllerDelegate` to sort the library with the specified sort type.

		- Parameter sortType: The sort type by which the library should be sorted.
	*/
	func sortLibrary(by sortType: KKLibrary.SortType, option: KKLibrary.SortType.Options)

	/**
		Tells your `LibraryViewControllerDelegate` the current sort value used to sort the items in the library.

		- Returns: The current sort value used to sort the items in the library.
	*/
	func sortValue() -> KKLibrary.SortType

	/**
		Tells your `LibraryViewControllerDelegate` the current sort option value used to sort the items in the library.

		- Returns: The current sort option value used to sort the items in the library.
	*/
	func sortOptionValue() -> KKLibrary.SortType.Options
}

class LibraryViewController: KTabbedViewController {
	// MARK: - IBOutlets
	@IBOutlet var changeLayoutBarButtonItem: UIBarButtonItem!
	@IBOutlet var sortTypeBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var kSearchController: KSearchController = KSearchController()
	var rightBarButtonItems: [UIBarButtonItem]? = nil
	var leftBarButtonItems: [UIBarButtonItem]? = nil

	weak var libraryViewControllerDelegate: LibraryViewControllerDelegate?

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		enableActions()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// Actions
		enableActions()

		// Configure search bar.
		configureSearchBar()
    }

	// MARK: - Functions
	/// Configures the search bar.
	fileprivate func configureSearchBar() {
		// Configure search controller
		kSearchController.searchScope = .myLibrary
		kSearchController.viewController = self

		// Add search bar to navigation controller
		navigationItem.searchController = kSearchController
	}

	override func configureTabBarViewVisibility() {
		if User.isSignedIn {
			if let barItemsCount = bar.items?.count {
				bar.isHidden = barItemsCount <= 1
			}
		} else {
			bar.isHidden = true
		}
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		DispatchQueue.main.async {
			if !User.isSignedIn {
				self.rightBarButtonItems = self.navigationItem.rightBarButtonItems
				self.leftBarButtonItems = self.navigationItem.leftBarButtonItems

				self.navigationItem.rightBarButtonItems = nil
				self.navigationItem.leftBarButtonItems = nil
			} else {
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
		changeLayoutBarButtonItem.tag = cellStyle.rawValue
		changeLayoutBarButtonItem.title = cellStyle.stringValue
		changeLayoutBarButtonItem.image = cellStyle.imageValue
	}

	/// Updates the sort type button icon to reflect the current sort type when switching between views.
	fileprivate func updateSortTypeBarButtonItem(_ sortType: KKLibrary.SortType) {
		sortTypeBarButtonItem.tag = sortType.rawValue
		sortTypeBarButtonItem.title = sortType.stringValue
		sortTypeBarButtonItem.image = sortType.imageValue
	}

	fileprivate func savePreferredCellStyle(for currentSection: LibraryListCollectionViewController) {
		let libraryLayouts = UserSettings.libraryCellStyles
		var newLibraryLayouts = libraryLayouts
		newLibraryLayouts[currentSection.libraryStatus.sectionValue] = changeLayoutBarButtonItem.tag
		UserSettings.set(newLibraryLayouts, forKey: .libraryCellStyles)
	}

	/// Changes the layout between the available library cell styles.
	fileprivate func changeSortType() {
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }

		// Update library list
		UIView.animate(withDuration: 0, animations: {
			guard let flowLayout = currentSection.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
				return
			}
			flowLayout.invalidateLayout()
		}, completion: { _ in
			currentSection.collectionView.reloadData()
		})
	}

	/// Changes the layout between the available library cell styles.
	fileprivate func changeLayout() {
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }
		var libraryCellStyle: KKLibrary.CellStyle = KKLibrary.CellStyle(rawValue: changeLayoutBarButtonItem.tag) ?? .detailed

		// Change button information
		libraryCellStyle = libraryCellStyle.next
		changeLayoutBarButtonItem.tag = libraryCellStyle.rawValue
		changeLayoutBarButtonItem.title = libraryCellStyle.stringValue
		changeLayoutBarButtonItem.image = libraryCellStyle.imageValue

		// Save cell style change to UserSettings
		savePreferredCellStyle(for: currentSection)

		// Update library list
		currentSection.libraryCellStyle = libraryCellStyle
		UIView.animate(withDuration: 0, animations: {
			guard let flowLayout = currentSection.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
				return
			}
			flowLayout.invalidateLayout()
		}, completion: { _ in
			currentSection.collectionView.reloadData()
		})
	}

	/**
		Builds and presents the sort types in an action sheet.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	fileprivate func populateSortActions(_ sender: UIBarButtonItem) {
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.SortType.alertControllerItems, currentSelection: self.libraryViewControllerDelegate?.sortValue()) { [weak self] (_, value, _)  in
			guard let self = self else { return }
			let subActionSheetAlertController = UIAlertController.actionSheetWithItems(items: value.subAlertControllerItems, currentSelection: self.libraryViewControllerDelegate?.sortOptionValue()) { (_, subValue, _) in
				self.libraryViewControllerDelegate?.sortLibrary(by: value, option: subValue)
			}

			//Present the controller
			if let popoverController = subActionSheetAlertController.popoverPresentationController {
				popoverController.barButtonItem = sender
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(subActionSheetAlertController, animated: true, completion: nil)
			}
		}

		if let sortValue = self.libraryViewControllerDelegate?.sortValue() {
			if sortValue != .none {
				// Report thread action
				let stopSortingAction = UIAlertAction.init(title: "Stop sorting", style: .destructive, handler: { (_) in
					self.libraryViewControllerDelegate?.sortLibrary(by: .none, option: .none)
				})
				stopSortingAction.setValue(UIImage(systemName: "xmark.circle.fill"), forKey: "image")
				stopSortingAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				actionSheetAlertController.addAction(stopSortingAction)
			}
		}

		//Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	// MARK: - IBActions
	@IBAction func changeLayoutBarButtonItemPressed(_ sender: UIBarButtonItem) {
		changeLayout()
	}

	@IBAction func sortTypeBarButtonItemPressed(_ sender: UIBarButtonItem) {
		populateSortActions(sender)
	}

	// MARK: - TMBarDataSource
	override func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		let sectionTitle = KKLibrary.Status.all[index].stringValue
		return TMBarItem(title: sectionTitle)
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
	func updateChangeLayoutButton(with cellStyle: KKLibrary.CellStyle) {
		updateChangeLayoutBarButtonItem(cellStyle)
	}

	func updateSortTypeButton(with sortType: KKLibrary.SortType) {
		updateSortTypeBarButtonItem(sortType)
		changeSortType()
	}
}

// MARK: - KTabbedViewControllerDataSource
extension LibraryViewController {
	override func initializeViewControllers(with count: Int) -> [UIViewController]? {
		var viewControllers = [UIViewController]()

		for index in 0 ..< count {
			if let libraryListCollectionViewController = R.storyboard.library.libraryListCollectionViewController() {
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
