//
//  LibraryViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import SCLAlertView
import SwiftTheme

protocol LibraryViewControllerDelegate: class {
	func sortTypeBarButtonItemPressed(_ sender: UIBarButtonItem)
}

class LibraryViewController: TabmanViewController {
	// MARK: - IBOutlets
	@IBOutlet var changeLayoutBarButtonItem: UIBarButtonItem!
	@IBOutlet var sortTypeBarButtonItem: UIBarButtonItem!
	@IBOutlet var bottomBarView: UIView!

	// MARK: - Properties
	lazy var viewControllers = [UIViewController]()
	var kSearchController: KSearchController = KSearchController()

	var rightBarButtonItems: [UIBarButtonItem]? = nil
	var leftBarButtonItems: [UIBarButtonItem]? = nil

	let bar = TMBar.KBar()

	weak var libraryViewControllerDelegate: LibraryViewControllerDelegate?

	#if DEBUG
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) = {
		return LibraryListCollectionViewController().numberOfItems
	}()
	var numberOfItemsTextField: UITextField = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))
	#endif

	// MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: .KUserIsSignedInDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTabBarStyle), name: .ThemeUpdateNotification, object: nil)

		navigationItem.hidesSearchBarWhenScrolling = false

		// Actions
		enableActions()

		// Setup search bar.
		setupSearchBar()

		// Tabman view controllers
		dataSource = self

		// Tabman bar
		initTabmanBarView()

		#if DEBUG
		numberOfItemsTextField.placeholder = "# items for: width, height"
		numberOfItemsTextField.text = "\(numberOfItems.forWidth), \(numberOfItems.forHeight)"
		numberOfItemsTextField.textAlignment = .center
		numberOfItemsTextField.addTarget(self, action: #selector(updateLayout(_:)), for: .editingDidEnd)
		navigationItem.title = nil
		navigationItem.titleView = numberOfItemsTextField
		#endif
    }

	// MARK: - Functions
	#if DEBUG
	/// Updates the layout using the data from the given textfield.
	@objc func updateLayout(_ textField: UITextField) {
		guard let textFieldText = numberOfItemsTextField.text else { return }
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }

		if textFieldText.isEmpty {
			currentSection.newNumberOfItems = nil
		} else {
			currentSection.newNumberOfItems = getNumbers(textFieldText)
		}

		currentSection.collectionView.reloadData()
	}

	/// Returns the width and height from the given string.
	func getNumbers(_ text: String) -> (forWidth: CGFloat, forHeight: CGFloat) {
		let stringArray = text.withoutSpacesAndNewLines.components(separatedBy: ",")
		let width = (stringArray.count > 1) ? Double(stringArray[0])?.cgFloat : numberOfItems.forWidth
		let height = (stringArray.count > 1) ? Double(stringArray[1])?.cgFloat : numberOfItems.forHeight
		return (width ?? numberOfItems.forWidth, height ?? numberOfItems.forHeight)
	}
	#endif

	/// Sets up the search bar.
	fileprivate func setupSearchBar() {
		// Configure search controller
		kSearchController.searchScope = .myLibrary
		kSearchController.viewController = self

		// Add search bar to navigation controller
		navigationItem.searchController = kSearchController
	}

	/// Applies the the style for the currently enabled theme on the tabman bar.
	private func styleTabmanBarView() {
		// Background view
		bar.backgroundView.style = .blur(style: KThemePicker.visualEffect.blurValue)

		// Indicator
		bar.indicator.layout(in: bar)

		// Scrolling
		bar.scrollMode = .interactive

		// State
		bar.buttons.customize { (button) in
			button.contentInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
			button.selectedTintColor = KThemePicker.tintColor.colorValue
			button.tintColor = button.selectedTintColor.withAlphaComponent(0.25)
		}

		// Layout
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
		bar.layout.interButtonSpacing = 0.0
		if UIDevice.isPad {
			bar.layout.contentMode = .fit
		}

		// Style
		bar.fadesContentEdges = true
	}

	/// Initializes the tabman bar view.
	private func initTabmanBarView() {
		// Style tabman bar
		styleTabmanBarView()

		// Add tabman bar to view
		addBar(bar, dataSource: self, at: .custom(view: bottomBarView, layout: { bar in
			bar.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				bar.topAnchor.constraint(equalTo: self.bottomBarView.topAnchor),
				bar.bottomAnchor.constraint(equalTo: self.bottomBarView.bottomAnchor),
				bar.leftAnchor.constraint(lessThanOrEqualTo: self.bottomBarView.leftAnchor),
				bar.rightAnchor.constraint(lessThanOrEqualTo: self.bottomBarView.rightAnchor),
				bar.centerXAnchor.constraint(equalTo: self.bottomBarView.centerXAnchor)
			])
		}))

		bar.cornerRadius = bar.height / 2

		// Configure tabman bar visibility
		tabmanBarViewIsEnabled()
	}

	/// Hides or unhides the tabman bar view according to the user's sign in state.
	private func tabmanBarViewIsEnabled() {
		if User.isSignedIn {
			if let barItemsCount = bar.items?.count {
				bar.isHidden = barItemsCount <= 1
			}
		} else {
			bar.isHidden = true
		}
	}

	/// Reloads the tab bar with the new data.
	@objc func reloadTabBarStyle() {
		styleTabmanBarView()
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

	/// Reload the data on the view.
	@objc private func reloadView() {
		enableActions()
		reloadData()
		tabmanBarViewIsEnabled()
	}

	/**
		Initializes the view controllers which will be used for pagination.

		- Parameter count: The number of view controller to initialize.
	*/
    private func initializeViewControllers(with count: Int) {
        let storyboard = UIStoryboard(name: "library", bundle: nil)
        var viewControllers = [UIViewController]()

        for index in 0 ..< count {
            let libraryListCollectionViewController = storyboard.instantiateViewController(withIdentifier: "LibraryListCollectionViewController") as! LibraryListCollectionViewController
			let sectionTitle = Library.Section.all[index].sectionValue

			// Get the user's preferred sort type
			let librarySortTypes = UserSettings.librarySortTypes
			let preferredSortType = librarySortTypes[sectionTitle] ?? 0
			if let librarySortType = Library.SortType(rawValue: preferredSortType) {
				libraryListCollectionViewController.librarySortType = librarySortType
			}

			// Get the user's preferred library layout
			let libraryLayouts = UserSettings.libraryCellStyles
			let preferredLayout = libraryLayouts[sectionTitle] ?? 0
			if let libraryCellStyle = Library.CellStyle(rawValue: preferredLayout) {
				libraryListCollectionViewController.libraryCellStyle = libraryCellStyle
			}

			libraryListCollectionViewController.sectionTitle = sectionTitle
			libraryListCollectionViewController.sectionIndex = index
			libraryListCollectionViewController.delegate = self
            viewControllers.append(libraryListCollectionViewController)
        }

        self.viewControllers = viewControllers
    }

	/// Updates the layout button icon to reflect the current layout when switching between views.
	fileprivate func updateChangeLayoutBarButtonItem(_ cellStyle: Library.CellStyle) {
		changeLayoutBarButtonItem.tag = cellStyle.rawValue
		changeLayoutBarButtonItem.title = cellStyle.stringValue
		changeLayoutBarButtonItem.image = cellStyle.imageValue
	}

	/// Updates the sort type button icon to reflect the current sort type when switching between views.
	fileprivate func updateSortTypeBarButtonItem(_ sortType: Library.SortType) {
		sortTypeBarButtonItem.tag = sortType.rawValue
		sortTypeBarButtonItem.title = sortType.stringValue
		sortTypeBarButtonItem.image = sortType.imageValue
	}

	fileprivate func savePreferredCellStyle(for currentSection: LibraryListCollectionViewController) {
		let libraryLayouts = UserSettings.libraryCellStyles
		var newLibraryLayouts = libraryLayouts
		newLibraryLayouts[currentSection.sectionTitle] = changeLayoutBarButtonItem.tag
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
		var libraryCellStyle: Library.CellStyle = Library.CellStyle(rawValue: changeLayoutBarButtonItem.tag) ?? .detailed

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

	/// Builds and presents the sort types in an action sheet.
	fileprivate func populateSortActions(_ sender: UIBarButtonItem) {
		libraryViewControllerDelegate?.sortTypeBarButtonItemPressed(sender)
	}

	// MARK: - IBActions
	@IBAction func changeLayoutBarButtonItemPressed(_ sender: UIBarButtonItem) {
		changeLayout()
	}

	@IBAction func sortTypeBarButtonItemPressed(_ sender: UIBarButtonItem) {
		populateSortActions(sender)
	}
}

// MARK: - LibraryListViewControllerDelegate
extension LibraryViewController: LibraryListViewControllerDelegate {
	func updateChangeLayoutButton(with cellStyle: Library.CellStyle) {
		updateChangeLayoutBarButtonItem(cellStyle)
	}

	func updateSortTypeButton(with sortType: Library.SortType) {
		updateSortTypeBarButtonItem(sortType)
		changeSortType()
	}
}

// MARK: - PageboyViewControllerDataSource
extension LibraryViewController: PageboyViewControllerDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		let sectionsCount = User.isSignedIn ? Library.Section.all.count : 1
		initializeViewControllers(with: sectionsCount)
		return sectionsCount
	}

	func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
		return self.viewControllers[index]
	}

	func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return User.isSignedIn ? .at(index: UserSettings.libraryPage) : nil
	}
}

// MARK: - TMBarDataSource
extension LibraryViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		let sectionTitle = Library.Section.all[index].stringValue
		return TMBarItem(title: sectionTitle)
	}
}
