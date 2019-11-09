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

class LibraryViewController: TabmanViewController {
	// MARK: - IBOutlets
	@IBOutlet var changeLayoutButton: UIBarButtonItem!

	// MARK: - Properties
	lazy var viewControllers = [UIViewController]()
	var searchResultsTableViewController: SearchResultsTableViewController?
	var searchController: SearchController!

	var rightBarButtonItems: [UIBarButtonItem]? = nil
	var leftBarButtonItems: [UIBarButtonItem]? = nil

	let librarySections: [LibrarySectionList] = [.watching, .planning, .completed, .onHold, .dropped]
	let bar = TMBar.ButtonBar()

	#if DEBUG
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) = {
		return LibraryListCollectionViewController().numberOfItems
	}()
	var numberOfItemsTextField: UITextField = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))
	#endif

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationItem.hidesSearchBarWhenScrolling = false
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: .KUserIsSignedInDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(reloadTabBarStyle), name: .ThemeUpdateNotification, object: nil)

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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		navigationItem.hidesSearchBarWhenScrolling = true
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
		searchResultsTableViewController = SearchResultsTableViewController.instantiateFromStoryboard() as? SearchResultsTableViewController

		searchController = SearchController(searchResultsController: searchResultsTableViewController)
		searchController.delegate = self
		searchController.searchBar.selectedScopeButtonIndex = SearchScope.myLibrary.rawValue
		searchController.searchResultsUpdater = searchResultsTableViewController
		searchController.viewController = self

		let searchControllerBar = searchController.searchBar
		searchControllerBar.delegate = searchResultsTableViewController

		navigationItem.searchController = searchController
	}

	/// Applies the the style for the currently enabled theme on the tabman bar.
	private func styleTabmanBarView() {
		// Background view
		bar.backgroundView.style = .blur(style: KThemePicker.visualEffect.blurValue)

		// Indicator
		bar.indicator.weight = .light
		bar.indicator.cornerStyle = .eliptical
		bar.indicator.overscrollBehavior = .bounce
		bar.indicator.theme_tintColor = KThemePicker.tintColor.rawValue

		// State
		bar.buttons.customize { (button) in
			button.selectedTintColor = KThemePicker.tintColor.colorValue
			button.tintColor = KThemePicker.tintColor.colorValue.withAlphaComponent(0.4)
		}

		// Layout
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
		bar.layout.interButtonSpacing = 24.0
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
		addBar(bar, dataSource: self, at: .top)

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
            let viewController = storyboard.instantiateViewController(withIdentifier: "LibraryListCollectionViewController") as! LibraryListCollectionViewController
            var sectionTitle = librarySections[index].rawValue
			sectionTitle = (sectionTitle == "On-Hold" ? "OnHold" : sectionTitle)

			// Get the user's preferred library layout
			if let libraryLayouts = UserSettings.libraryLayouts as? [String: String] {
				let currentLayout = libraryLayouts[sectionTitle] ?? "Detailed"
				guard let libraryLayout = LibraryListStyle(rawValue: "\(currentLayout)Cell") else { return }

				viewController.libraryLayout = libraryLayout
			}
			viewController.sectionTitle = sectionTitle
			viewController.sectionIndex = index
			viewController.delegate = self
            viewControllers.append(viewController)
        }

        self.viewControllers = viewControllers
    }

	/// Updates the layout button icon to reflect the current layout when switching between views.
	private func updateChangeLayoutButtonIcon(_ layout: LibraryListStyle) {
		if layout == .compact {
			changeLayoutButton.title = "Compact"
			changeLayoutButton.image = #imageLiteral(resourceName: "compact_view_icon")
		} else if layout == .detailed {
			changeLayoutButton.title = "Detailed"
			changeLayoutButton.image = #imageLiteral(resourceName: "detailed_view_icon")
		}
	}

	/// Changes the layout between compact and detailed cells.
	private func changeLayout() {
		guard let buttonTitle = changeLayoutButton.title else { return }
		guard let currentSection = self.currentViewController as? LibraryListCollectionViewController else { return }

		var libraryLayout: LibraryListStyle = .detailed

		// Change button information
		if buttonTitle == "Detailed" {
			libraryLayout = .compact
			changeLayoutButton.title = "Compact"
			changeLayoutButton.image = #imageLiteral(resourceName: "compact_view_icon")
		} else if buttonTitle == "Compact" {
			changeLayoutButton.title = "Detailed"
			changeLayoutButton.image = #imageLiteral(resourceName: "detailed_view_icon")
		}

		// Add to UserSettings
		if let libraryLayouts = UserSettings.libraryLayouts as? [String: String] {
			var newLibraryLayouts = libraryLayouts
			newLibraryLayouts[currentSection.sectionTitle] = changeLayoutButton.title
			UserSettings.set(newLibraryLayouts, forKey: .libraryLayouts)
		}

		// Update library list
		currentSection.libraryLayout = libraryLayout
		UIView.animate(withDuration: 0, animations: {
			guard let flowLayout = currentSection.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
				return
			}
			flowLayout.invalidateLayout()
		}, completion: { _ in
			currentSection.collectionView.reloadData()
		})
	}

	// MARK: - IBActions
	@IBAction func changeLayoutButtonPressed(_ sender: UIBarButtonItem) {
		changeLayout()
	}
}

// MARK: - LibraryListViewControllerDelegate
extension LibraryViewController: LibraryListViewControllerDelegate {
	func updateLayoutChangeButton(current layout: LibraryListStyle) {
		updateChangeLayoutButtonIcon(layout)
	}
}

// MARK: - PageboyViewControllerDataSource
extension LibraryViewController: PageboyViewControllerDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		let sectionsCount = User.isSignedIn ? librarySections.count : 1
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
		let sectionTitle = librarySections[index].rawValue
		return TMBarItem(title: sectionTitle)
	}
}

// MARK: - UISearchControllerDelegate
extension LibraryViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		searchController.searchBar.showsCancelButton = true

		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = true
			})
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		searchController.searchBar.showsCancelButton = false

		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.isHidden = false
			})
		}
	}
}
