//
//  KTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

/**
	A supercharged view controller that specializes in managing a collection view.

	This implemenation of [UITableViewController](apple-reference-documentation://hsbc27YqnU) implements the following behavior:
	- A [KRefreshControl](x-source-tag://KRefreshControl) is added to the table view.
	- A [UIActivityIndicatorView](apple-reference-documentation://hsXlO5I6Ag) is shown when [viewDidLoad](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuiviewcontroller%2F1621495-viewdidload) is called.
	- The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.
	- The view controller observes changes in the user's sign in status and runs [viewWillReload](x-source-tag://UIViewController-viewWillReload) if a change has been detected.
	- The view controller observes changes in the selected app theme and runs [themeWillReload](x-source-tag://UIViewController-themeWillReload) if a change has been detected.

	Create a custom subclass of `KTableViewController` for each table view that you manage. When you initialize the table view controller, you must specify the style of the table view (plain or grouped). You must also override the data source and delegate methods required to fill your table with data.

	You may override the [loadView()](apple-reference-documentation://hsl6d2tyZj) method or any other superclass method, but if you do, be sure to call `super` in the implementation of your method. If you do not, the table view controller may not be able to perform all of the tasks needed to maintain the integrity of the table view.

	You may override `prefersRefreshControlDisabled` to prevent the view from activating the refresh control.

	You may also override `prefersActivityIndicatorHidden` to prevent the view from showing the acitivity indicator.

	- Important: Refresh control is unavailable on macOS and as such it is disabled by default. Instead, the key-command `⌘+R` is added.

	- Tag: KTableViewController
*/
class KTableViewController: UITableViewController {
	// MARK: - Properties
	/// The activity indicator view object of the view controller.
	private let activityIndicatorView: KActivityIndicatorView = KActivityIndicatorView()

	/// The object controlling the empty background view.
	let emptyBackgroundView: EmptyBackgroundView = EmptyBackgroundView()

	/**
		Specifies whether the view controller prefers the activity indicator to be hidden or shown.

		If you change the return value for this method, call the [setNeedsActivityIndicatorAppearanceUpdate()](x-source-tag://KTableViewController-setNeedsActivityIndicatorAppearanceUpdate) method.

		By default, this property returns `false`.

		- Returns: `true` if the activity indicator should be hidden or `false` if it should be shown.
	*/
	var prefersActivityIndicatorHidden: Bool {
		return false
	}

	/**
		Specifies whether the table view prefers the refresh control to be disabled or enabled.

		If you change the return value for this method, call the [setNeedsRefreshControlAppearanceUpdate()](x-source-tag://KTableViewController-setNeedsRefreshControlAppearanceUpdate) method.

		By default, this property returns `false`.

		- Returns: `true` if the refresh control should be disabled or `false` if it should be enabled.
	*/
	var prefersRefreshControlDisabled: Bool {
		return false
	}

	// MARK: - Command Keys
	#if targetEnvironment(macCatalyst)
	/// The command key for refreshing pages.
	private let refreshCommand = UIKeyCommand(title: "Refresh Page", action: #selector(handleRefreshControl), input: "R", modifierFlags: .command, discoverabilityTitle: "Refresh Page")
	#endif

	// MARK: - Initializers
	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.reloadEmptyDataView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Observe user sign-in status.
		NotificationCenter.default.addObserver(self, selector: #selector(viewWillReload), name: .KUserIsSignedInDidChange, object: nil)

		// Observe theme update notification.
		NotificationCenter.default.addObserver(self, selector: #selector(themeWillReload), name: .ThemeUpdateNotification, object: nil)

		// Set table view theme.
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.tableView.theme_separatorColor = KThemePicker.separatorColorLight.rawValue

		// Configure table view.
		configureTableView()

		// Configure refresh control.
		configureRefreshControl()

		// Configure activity indicator.
		configureActivityIndicator()

		// Configure empty view.
		configureEmptyDataView()
	}

	// MARK: - Functions
	/**
		Configures the table view with default values.

		Cells can also be registered during the configuration by using [registerCells(for tableView: UITableView)](x-source-tag://KTableViewController-registerCellsForTableView).
	*/
	fileprivate func configureTableView() {
		tableView.backgroundView = emptyBackgroundView

		// Register cells with the table view.
		registerCells()
	}

	/**
		Registers cells returned by [registerCells(for tableView: UITableView)](x-source-tag://KTableViewController-registerCellsForTableView).
	*/
	fileprivate func registerCells() {
		for cell in registerCells(for: tableView) {
			tableView.register(nibWithCellClass: cell)
		}
	}
}

// MARK: - Refresh Control
extension KTableViewController {
	/**
		Configures the refresh control of the table view.
	*/
	private func configureRefreshControl() {
		#if targetEnvironment(macCatalyst)
		self.addKeyCommand(refreshCommand)
		#else
		tableView.refreshControl = KRefreshControl()
		refreshControl?.addTarget(self, action: #selector(self.handleRefreshControl), for: .valueChanged)
		#endif
	}

	/**
		Indicates to the system that the table view refresh control attributes have changed.

		Call this method if the table view's refresh control attributes, such as enabled/disabled status, change.

		- Tag: KTableViewController-setNeedsRefreshControlAppearanceUpdate
	*/
	func setNeedsRefreshControlAppearanceUpdate() {
		if prefersRefreshControlDisabled {
			#if targetEnvironment(macCatalyst)
			self.removeKeyCommand(refreshCommand)
			#else
			self.tableView.refreshControl = nil
			#endif
		} else {
			self.configureRefreshControl()
		}
	}

	/**
		Action method used to update your content.

		This method is called upon activation of the refresh control. Call the refresh control’s [endRefreshing()](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuirefreshcontrol%2F1624848-endrefreshing) method when you are done.

		- Tag: KTableViewController-handleRefreshControl
	*/
	@objc func handleRefreshControl() { }
}

// MARK: - Activity Indicator
extension KTableViewController {
	/**
		Configures the activity indicator with default values.
	*/
	private func configureActivityIndicator() {
		self.activityIndicatorView.removeFromSuperview()
		self.view.addSubview(activityIndicatorView)
		self.activityIndicatorView.center = self.view.center

		setNeedsActivityIndicatorAppearanceUpdate()
	}

	/**
		Indicates to the system that the view controller activity indicator attributes have changed.

		Call this method if the view controller's activity indicator attributes, such as hidden/unhidden status or style, change. If you call this method within an animation block, the changes are animated along with the rest of the animation block.

		- Tag: KTableViewController-setNeedsActivityIndicatorAppearanceUpdate
	*/
	func setNeedsActivityIndicatorAppearanceUpdate() {
		self.activityIndicatorView.prefersHidden = prefersActivityIndicatorHidden
	}
}

// MARK: - EmptyDataSet
extension KTableViewController {
	/**
		Shows a view to indicate the table view has no data to show.

		Use this method to show a beautiful and informative view when the table view is empty.
	*/
	@objc func configureEmptyDataView() { }

	/**
		Reload empty data with a completion handler.

		- Parameter completion: Completion handler to run after reloadEmptyDataView finishes.
	*/
	func reloadEmptyDataView(completion: (() -> Void)? = nil) {
		self.configureEmptyDataView()
		completion?()
	}
}

// MARK: - UINavigationControllerDelegate
extension KTableViewController: UINavigationControllerDelegate {}
