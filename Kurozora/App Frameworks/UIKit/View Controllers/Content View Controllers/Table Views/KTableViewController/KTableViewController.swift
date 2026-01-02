//
//  KTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A supercharged view controller that specializes in managing a collection view.
///
/// This implementation of [UITableViewController](apple-reference-documentation://hsbc27YqnU) implements the following behavior:
/// - A [KRefreshControl](x-source-tag://KRefreshControl) is added to the table view.
/// - A [UIActivityIndicatorView](apple-reference-documentation://hsXlO5I6Ag) is shown when [viewDidLoad](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuiviewcontroller%2F1621495-viewdidload) is called.
/// - The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.
/// - The view controller observes changes in the user's sign in status and runs [viewWillReload](x-source-tag://UIViewController-viewWillReload) if a change has been detected.
/// - The view controller observes changes in the selected app theme and runs [themeWillReload](x-source-tag://UIViewController-themeWillReload) if a change has been detected.
///
/// Create a custom subclass of `KTableViewController` for each table view that you manage. When you initialize the table view controller, you must specify the style of the table view (plain or grouped). You must also override the data source and delegate methods required to fill your table with data.
///
/// You may override the [loadView()](apple-reference-documentation://hsl6d2tyZj) method or any other superclass method, but if you do, be sure to call `super` in the implementation of your method. If you do not, the table view controller may not be able to perform all of the tasks needed to maintain the integrity of the table view.
///
/// You may override `prefersRefreshControlDisabled` to prevent the view from activating the refresh control.
///
/// You may also override `prefersActivityIndicatorHidden` to prevent the view from showing the acitivity indicator.
///
/// - Important: Refresh control is unavailable on macOS and as such it is disabled by default. Instead, the key-command `⌘+R` is added.
///
/// - Tag: KTableViewController
class KTableViewController: UITableViewController, SegueHandler {
	// MARK: - Properties
	/// The gradient view object of the view controller.
	private var gradientView: GradientView = {
		let gradientView = GradientView()
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.gradientLayer?.theme_colors = KThemePicker.backgroundColors.gradientPicker
		return gradientView
	}()

	/// The activity indicator view object of the view controller.
	private lazy var activityIndicatorView: KActivityIndicatorView = {
		return KActivityIndicatorView()
	}()

	/// The object controlling the empty background view.
	lazy var emptyBackgroundView: EmptyBackgroundView = {
		return EmptyBackgroundView()
	}()

	/// Specifies whether the view controller prefers the activity indicator to be hidden or shown.
	///
	/// If you change the return value for this method, call the [setNeedsActivityIndicatorAppearanceUpdate()](x-source-tag://KTableViewController-setNeedsActivityIndicatorAppearanceUpdate) method.
	///
	/// By default, this property returns `false`.
	///
	/// - Returns: `true` if the activity indicator should be hidden or `false` if it should be shown.
	var prefersActivityIndicatorHidden: Bool {
		return false
	}

	/// Specifies whether the table view prefers the refresh control to be disabled or enabled.
	///
	/// If you change the return value for this method, call the [setNeedsRefreshControlAppearanceUpdate()](x-source-tag://KTableViewController-setNeedsRefreshControlAppearanceUpdate) method.
	///
	/// By default, this property returns `false`.
	///
	/// - Returns: `true` if the refresh control should be disabled or `false` if it should be enabled.
	var prefersRefreshControlDisabled: Bool {
		return false
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureEmptyDataView()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Observe user sign-in status.
		NotificationCenter.default.addObserver(self, selector: #selector(self.viewWillReload), name: .KUserIsSignedInDidChange, object: nil)

		// Observe theme update notification.
		NotificationCenter.default.addObserver(self, selector: #selector(self.themeWillReload), name: .ThemeUpdateNotification, object: nil)

		// Set table view theme.
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		self.tableView.theme_separatorColor = KThemePicker.separatorColorLight.rawValue

		// Configure the gradient view.
		self.configureGradientView()

		// Configure table view.
		self.configureTableView()

		// Configure refresh control.
		self.configureRefreshControl()

		// Configure activity indicator.
		self.configureActivityIndicator()

		// Configure empty view.
		self.configureEmptyDataView()
	}

	// MARK: - Functions
	/// Configures the gradient view with default values.
	fileprivate func configureGradientView() {
		self.view.addSubview(self.gradientView)
		self.view.sendSubviewToBack(self.gradientView)

		NSLayoutConstraint.activate([
			self.gradientView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.gradientView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.gradientView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.gradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		])
	}

	/// Configures the table view with default values.
	///
	/// Cells can also be registered during the configuration by using [registerCells(for tableView: UITableView)](x-source-tag://KTableViewController-registerCellsForTableView).
	fileprivate func configureTableView() {
		self.tableView.prefetchDataSource = self
		self.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.tableView.backgroundView = self.emptyBackgroundView

		// Register cells with the table view.
		self.registerCells()

		// Register reusable views with the table view.
		self.registerNibs()
	}

	/// Registers cells returned by [registerCells(for tableView: UITableView)](x-source-tag://KTableViewController-registerCellsForTableView).
	fileprivate func registerCells() {
		for cell in registerCells(for: self.tableView) {
			let identifier = String(describing: cell)
			self.tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
		}
	}

	/// Registers nibs returned by [registerNibs(for tableView: UITableView)](x-source-tag://KTableViewController-registerNibsForTableView).
	fileprivate func registerNibs() {
		for nib in registerNibs(for: self.tableView) {
			let identifier = String(describing: nib)
			self.tableView.register(UINib(nibName: identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: identifier)
		}
	}

	// MARK: - SegueHandler
	func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		return nil
	}

	func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {}
}

// MARK: - UICollectionViewDataSourcePrefetching
extension KTableViewController: UITableViewDataSourcePrefetching {
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) { }
}

// MARK: - Refresh Control
extension KTableViewController {
	/// Configures the refresh control of the table view.
	private func configureRefreshControl() {
		#if targetEnvironment(macCatalyst)
		#else
		self.tableView.refreshControl = KRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(self.handleRefreshControl), for: .valueChanged)
		#endif
	}

	/// Indicates to the system that the table view refresh control attributes have changed.
	///
	/// Call this method if the table view's refresh control attributes, such as enabled/disabled status, change.
	///
	/// - Tag: KTableViewController-setNeedsRefreshControlAppearanceUpdate
	func setNeedsRefreshControlAppearanceUpdate() {
		if prefersRefreshControlDisabled {
			#if targetEnvironment(macCatalyst)
			#else
			self.tableView.refreshControl = nil
			#endif
		} else {
			self.configureRefreshControl()
		}
	}

	/// Action method used to update your content.
	///
	/// This method is called upon activation of the refresh control. Call the refresh control’s [endRefreshing()](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuirefreshcontrol%2F1624848-endrefreshing) method when you are done.
	///
	/// - Tag: KTableViewController-handleRefreshControl
	@objc func handleRefreshControl() { }
}

// MARK: - Activity Indicator
extension KTableViewController {
	/// Configures the activity indicator with default values.
	private func configureActivityIndicator() {
		self.activityIndicatorView.removeFromSuperview()
		self.view.addSubview(activityIndicatorView)
		self.activityIndicatorView.center = self.view.center

		setNeedsActivityIndicatorAppearanceUpdate()
	}

	/// Indicates to the system that the view controller activity indicator attributes have changed.
	///
	/// Call this method if the view controller's activity indicator attributes, such as hidden/unhidden status or style, change. If you call this method within an animation block, the changes are animated along with the rest of the animation block.
	///
	/// - Tag: KTableViewController-setNeedsActivityIndicatorAppearanceUpdate
	func setNeedsActivityIndicatorAppearanceUpdate() {
		self.activityIndicatorView.prefersHidden = prefersActivityIndicatorHidden
	}
}

// MARK: - EmptyDataSet
extension KTableViewController {
	/// Shows a view to indicate the table view has no data to show.
	///
	/// Use this method to show a beautiful and informative view when the table view is empty.
	@objc func configureEmptyDataView() { }
}

// MARK: - UINavigationControllerDelegate
extension KTableViewController: UINavigationControllerDelegate {}

// MARK: - SeguePerforming
extension KTableViewController: SeguePerforming {
	func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
		self.performSegue(withIdentifier: identifier.rawValue, sender: sender)
	}

	func show(_ identifier: SegueIdentifier, sender: Any?) {
		guard let destination = makeDestination(for: identifier) else { return }
		self.prepare(for: identifier, destination: destination, sender: sender)
		self.show(destination, sender: sender)
	}

	func showDetailViewController(_ identifier: SegueIdentifier, sender: Any?) {
		guard let destination = makeDestination(for: identifier) else { return }
		self.prepare(for: identifier, destination: destination, sender: sender)
		self.showDetailViewController(destination, sender: sender)
	}

	func present(_ identifier: SegueIdentifier, sender: Any?) {
		guard let destination = makeDestination(for: identifier) else { return }
		self.prepare(for: identifier, destination: destination, sender: sender)
		self.present(destination, animated: true)
	}
}
