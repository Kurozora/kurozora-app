//
//  KTabbedViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Tabman
import Pageboy

/**
	The KTabbedViewControllerDataSource protocol defines methods that guide you with managing the sections and view controllers registered with the tabbed view.

	- Tag: KTabbedViewControllerDataSource
*/
@objc protocol KTabbedViewControllerDataSource: class {
	/**
		Tells `KTabbedViewControllerDataSource` which view controllers should be initialized for pagination.

		This method is used together with `numberOfViewControllers(in:)` to initialize the view controllers for pagination.

		- Parameter count: The number of view controllers to initialize.

		- Returns: A collection of view contorllers.

		- Tag: KTVCDS-initializeViewControllersWithCount
	*/
	@objc func initializeViewControllers(with count: Int) -> [UIViewController]?

	/**
		Tells `KTabbedViewControllerDataSource` to fetch sections from an external source, such as from an API.

		This method is called in `init(coder:)` when intializing the view from a storyboard.

		- Tag: KTVCDS-fetchSections
	*/
	@objc optional func fetchSections()
}

/**
	A supercharged view controller that specializes in managing a tabbed view controller. `KTabbedViewController` may only be used with storyboards.

	This implementation of `TabmanViewController` implements the following behavior:
	- [KTabbedViewControllerDataSource](x-source-tag://KTabbedViewControllerDataSource) for managing the tab bar and its data.
	- [KBar](x-source-tag://KBar), the bar reminiscent of the iOS 13 Photos app bottom tab bar.

	Create a csutom subclass of `KTabbedViewController` for each tabbed view that you manage. You may only initialize a tabbed view controller through a storyboad. You must also override [initializeViewControllers(with:)](x-source-tag://KTVCDS-initializeViewControllersWithCount) method.

	You may override [fetchSections()](x-source-tag://KTVCDS-fetchSections) method if your tabbar sections are accessed through an external source, such as an API. This method will be called when the view controller is initialized, so make sure to run it on a background thread to avoid freezing the app.

	- Tag: KTabbedViewController
*/
class KTabbedViewController: TabmanViewController, TMBarDataSource, PageboyViewControllerDataSource {
	// MARK: - IBOutlets
	@IBOutlet weak var bottomBarView: UIView!

	// MARK: - Properties
	/// The view controllers that are associated with the bar.
	var viewControllers: [UIViewController]?

	/// A `UIView` that contains a `TMBarLayout` which displays a collection of `TMBarButton`, and a `TMBarIndicator`.
	let bar = TMBar.KBar()

	/// Tab bar data manager.
	weak var tabBarDataSource: KTabbedViewControllerDataSource?

	// MARK: - Initializers
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.tabBarDataSource = self

		// Fetch sections.
		self.tabBarDataSource?.fetchSections?()
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: .KUserIsSignedInDidChange, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(reloadTabBarStyle), name: .ThemeUpdateNotification, object: nil)

//		navigationItem.hidesSearchBarWhenScrolling = false

		// Initialize view controllers.
		self.viewControllers = self.tabBarDataSource?.initializeViewControllers(with: self.numberOfViewControllers(in: self))

		// Tabman view controllers
		self.dataSource = self

		// Tabman bar
		initTabBarView()
	}

	// MARK: - Functions
	/// Initializes the tab bar view with the specified style.
	private func initTabBarView() {
		self.styleTabBarView()
		self.addBar(bar, dataSource: self, at: .custom(view: bottomBarView, layout: { bar in
			bar.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				bar.topAnchor.constraint(equalTo: self.bottomBarView.topAnchor),
				bar.bottomAnchor.constraint(equalTo: self.bottomBarView.bottomAnchor),
				bar.leftAnchor.constraint(lessThanOrEqualTo: self.bottomBarView.leftAnchor),
				bar.rightAnchor.constraint(lessThanOrEqualTo: self.bottomBarView.rightAnchor),
				bar.centerXAnchor.constraint(equalTo: self.bottomBarView.centerXAnchor)
			])
		}))

		// Set corner raduis after the tab bar has been populated with data so it uses the correct height
		self.bar.cornerRadius = bar.height / 2

		self.configureTabBarViewVisibility()
	}

	/// Applies the the style for the currently enabled theme on the tab bar.
	private func styleTabBarView() {
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

	/**
		Configures the tab bar's visibility.

		By default, the bar is hidden if only one item is supplied in [barItem(for:at:)](x-source-tag://KTVC-barItemForBarAtIndex). You can override this method and implement your own logic for hiding and showing the bar.

		- Tag: KTVC-configureTabBarViewVisibility
	*/
	func configureTabBarViewVisibility() {
		if let barItemsCount = bar.items?.count {
			bar.isHidden = barItemsCount <= 1
		}
	}

	/// Reloads the tab bar with the new data.
	@objc func reloadTabBarStyle() {
		styleTabBarView()
	}

	/**
		Reloads the view controllers in the page view controller. This reloads the `dataSource` entirely, calling `reloadData()` and [configureTabBarViewVisibility()](x-source-tag://KTVC-configureTabBarViewVisibility).

		You may override this method, but if you do, be sure to call `super` in the implementation of your method. If you do not, the view controller may not be able to perform all of the tasks needed to maintain the integrity of the `dataSource`.
	*/
	@objc func reloadView() {
		self.reloadData()
		self.configureTabBarViewVisibility()
	}

	// MARK: - TMBarDataSource
	/**
		Provide a `BarItem` for an index in the bar.

		You should override and provide your own `BarItem` to be displayed in the tab bar.

		- Parameter bar: The bar.
		- Parameter index: Index of the item.

		- Returns: The BarItem.

		- Tag: KTVC-barItemForBarAtIndex
	*/
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		return TMBarItem(title: "Section \(index)")
	}

	// MARK: - PageboyViewControllerDataSource
	/**
		The number of view controllers to display.

		Make sure to call [numberOfViewControllers(in:)](x-source-tag://KTVCDS-initializeViewControllersWithCount) before returning and pass the results to `viewControllers` property to make sure your views are loaded correctly.

		- Parameter pageboyViewController: The Page view controller.

		- Returns: The total number of view controllers to display.
	*/
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		let numberOfViews = 0
		return numberOfViews
	}

	/**
		The view controller to display at a page index.

		- Parameter pageboyViewController: The Page view controller.
		- Parameter index: The page index.

		- Returns: The view controller to display
	*/
	func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
		return self.viewControllers?[index]
	}

	/**
		The default page index to display in the Pageboy view controller.

		- Parameter pageboyViewController: The Pageboy view controller.

		- Returns: Default page.
	*/
	func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return .first
	}
}

// MARK: - KTabbedViewControllerDataSource
extension KTabbedViewController: KTabbedViewControllerDataSource {
	/**
		Tells `KTabbedViewControllerDataSource` which view controllers should be initialized for pagination.

		This method is used together with `numberOfViewControllers(in:)` to initialize the view controllers for pagination.

		- Parameter count: The number of view controllers to initialize.

		- Returns: A collection of view contorllers.
	*/
	func initializeViewControllers(with count: Int) -> [UIViewController]? {
		return nil
	}

	/**
		Tells `KTabbedViewControllerDataSource` to fetch sections from an external source, such as from an API.

		This method is called in `init(coder:)` when intializing the view from a storyboard.
	*/
	func fetchSections() {}
}
