//
//  KCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

/**
	A supercharged view controller that specializes in managing a collection view.

	This implemenation of [UICollectionViewController](apple-reference-documentation://hskgp2RLo1) implements the following behavior:
	- A [KRefreshControl](x-source-tag://KRefreshControl) is added to the collection view.
	- A [UIActivityIndicatorView](apple-reference-documentation://hsXlO5I6Ag) is shown when [viewDidLoad](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuiviewcontroller%2F1621495-viewdidload) is called.
	- The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.
	- The view controller observes changes in the user's sign in status and runs [viewWillReload](x-source-tag://UIViewController-viewWillReload) if a change has been detected.

	You create a custom subclass of `KCollectionViewController` for each collection view that you want to manage. When you initialize the controller, using the [init(collectionViewLayout:)](apple-reference-documentation://hsrfD1Zed-) method, you specify the layout the collection view should have. Because the initially created collection view is without dimensions or content, the collection view’s data source and delegate—typically the collection view controller itself—must provide this information.

	You may override the [loadView()](apple-reference-documentation://hsl6d2tyZj) method or any other superclass method, but if you do, be sure to call `super` in the implementation of your method. If you do not, the collection view controller may not be able to perform all of the tasks needed to maintain the integrity of the collection view.

	You may override `prefersRefreshControlDisabled` to prevent the view from activating the refresh control.

	You may also override `prefersActivityIndicatorHidden` to prevent the view from showing the acitivity indicator.

	- Important: Refresh control is unavailable on macOS and as such it is disabled by default.

	- Tag: KCollectionViewController
*/
class KCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	/// The activity indicator view object of the view controller.
	private let activityIndicatorView: KActivityIndicatorView = KActivityIndicatorView()

	/**
		Specifies whether the view controller prefers the activity indicator to be hidden or shown.

		If you change the return value for this method, call the [setNeedsActivityIndicatorAppearanceUpdate()](x-source-tag://KCollectionViewDataSource-setNeedsActivityIndicatorAppearanceUpdate) method.

		By default, this property returns `false`.

		- Returns: `true` if the activity indicator should be hidden or `false` if it should be shown.
	*/
	var prefersActivityIndicatorHidden: Bool {
		return false
	}

	#if !targetEnvironment(macCatalyst)
	/**
		The refresh control used to update the collection contents.

		The default value of this property is `nil`.

		Assigning a refresh control to this property adds the control to the view controller’s associated interface. You do not need to set the frame of the refresh control before associating it with the view controller. The view controller updates the control’s height and width and sets its position appropriately.

		The collection view controller does not automatically update collection's contents in response to user interactions with the refresh control. When the user initiates a refresh operation, the control generates a [valueChanged](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuicontrol%2Fevent%2F1618238-valuechanged) event. You must associate a target and action method with this event and use them to refresh your collection's contents.
	*/
	var refreshControl: UIRefreshControl? {
		get {
			return self.collectionView.refreshControl
		}
		set {
			self.collectionView.refreshControl = newValue
		}
	}
	#endif

	/**
		Specifies whether the collection view prefers the refresh control to be disabled or enabled.

		If you change the return value for this method, call the [setNeedsRefreshControlAppearanceUpdate()](x-source-tag://KCollectionViewController-setNeedsRefreshControlAppearanceUpdate) method.

		By default, this property returns `true`.

		- Returns: `true` if the refresh control should be disabled or `false` if it should be enabled.
	*/
	var prefersRefreshControlDisabled: Bool {
		return true
	}

	// MARK: - Command Keys
	#if targetEnvironment(macCatalyst)
	/// The command key for refreshing pages.
	private let refreshCommand = UIKeyCommand(title: "Refresh Page", action: #selector(handleRefreshControl), input: "R", modifierFlags: .command, discoverabilityTitle: "Refresh Page")
	#endif

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Set background color.
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Observe user sign-in status.
		NotificationCenter.default.addObserver(self, selector: #selector(viewWillReload), name: .KUserIsSignedInDidChange, object: nil)

		// Observe theme update notification.
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView(_:)), name: .ThemeUpdateNotification, object: nil)

		// Configure collection view.
		configureCollectionView()

		// Configure refresh control.
		configureRefreshControl()

		// Configure activity indicator.
		configureActivityIndicator()

		// Configure empty data view.
		configureEmptyDataView()
	}

	// MARK: - Functions
	/**
		Configures the collection view with default values.

		Cells can also be registered during the configuration by using [registerCells(for collectionView: UICollectionView)](x-source-tag://KCollectionViewDataSource-registerCellsForCollectionView).
	*/
	fileprivate func configureCollectionView() {
		collectionView.collectionViewLayout = createLayout()
		collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		// Register cells with the collection view.
		registerCells()

		// Register reusable views with the collection view.
		registerNibs()
	}

	/**
		Registers cells returned by [registerCells(for collectionView: UICollectionView)](x-source-tag://KCollectionViewDataSource-registerCellsForCollectionView).
	*/
	fileprivate func registerCells() {
		for cell in registerCells(for: collectionView) {
			collectionView.register(nibWithCellClass: cell)
		}
	}

	/**
		Registers reusable views returned by [registerNibs(for collectionView: UICollectionView)](x-source-tag://KCollectionViewDataSource-registerNibsForCollectionView).
	*/
	fileprivate func registerNibs() {
		for nib in registerNibs(for: collectionView) {
			collectionView.register(nib: UINib(nibName: String(describing: nib), bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: nib)
		}
	}
}

// MARK: - Theme
extension KCollectionViewController {
	@objc func updateTheme() {

	}
}

// MARK: - Refresh Control
extension KCollectionViewController {
	/**
		Configures the refresh control of the collection view.
	*/
	private func configureRefreshControl() {
		#if targetEnvironment(macCatalyst)
		addKeyCommand(refreshCommand)
		#else
		collectionView.refreshControl = KRefreshControl()
		refreshControl?.addTarget(self, action: #selector(self.handleRefreshControl), for: .valueChanged)
		#endif
	}

	/**
		Indicates to the system that the collection view refresh control attributes have changed.

		Call this method if the collection view's refresh control attributes, such as enabled/disabled status, change.

		- Tag: KCollectionViewController-setNeedsRefreshControlAppearanceUpdate
	*/
	func setNeedsRefreshControlAppearanceUpdate() {
		if prefersRefreshControlDisabled {
			#if targetEnvironment(macCatalyst)
			removeKeyCommand(refreshCommand)
			#else
			self.collectionView.refreshControl = nil
			#endif
		} else {
			self.configureRefreshControl()
		}
	}

	/**
		Action method used to update your content.

		This method is called upon activation of the refresh control. Call the refresh control’s [endRefreshing()](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuirefreshcontrol%2F1624848-endrefreshing) method when you are done.

		- Tag: KCollectionViewController-handleRefreshControl
	*/
	@objc func handleRefreshControl() { }
}

// MARK: - Activity Indicator
extension KCollectionViewController {
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

		- Tag: KCollectionViewDataSource-setNeedsActivityIndicatorAppearanceUpdate
	*/
	func setNeedsActivityIndicatorAppearanceUpdate() {
		self.activityIndicatorView.prefersHidden = prefersActivityIndicatorHidden
	}
}

// MARK: - EmptyDataSet
extension KCollectionViewController {
	/**
		Shows a view to indicate the collection view has no data to show.

		Use this method to show a beautiful and informative view when the collection view is empty.
	*/
	@objc func configureEmptyDataView() { }

	/**
		Reload empty data with a completion handler.

		- Parameter completion: Completion handler to run after reloadEmptyDataView finishes.
	*/
	func reloadEmptyDataView(completion: (() -> Void)? = nil) {
		collectionView.reloadEmptyDataSet()
		self.configureEmptyDataView()
		completion?()
	}

	/**
		Reload empty data when receiving a notification.

		- Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	*/
	@objc private func reloadEmptyDataView(_ notification: NSNotification) {
		self.reloadEmptyDataView()
	}
}

// MARK: - UINavigationControllerDelegate
extension KCollectionViewController: UINavigationControllerDelegate { }
