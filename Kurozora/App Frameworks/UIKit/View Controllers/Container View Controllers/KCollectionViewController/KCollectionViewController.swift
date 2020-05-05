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
	- A [UIActivityIndicatorView](apple-reference-documentation://hsXlO5I6Ag) is shown when `viewDidLoad` is called.
	- The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.
	- The view controller observes changes in the user's sign in status and runs `viewWillReload` if a change has been detected.

	You create a custom subclass of `KCollectionViewController` for each collection view that you want to manage. When you initialize the controller, using the [init(collectionViewLayout:)](apple-reference-documentation://hsrfD1Zed-) method, you specify the layout the collection view should have. Because the initially created collection view is without dimensions or content, the collection view’s data source and delegate—typically the collection view controller itself—must provide this information.

	You may override the [loadView()](apple-reference-documentation://hsl6d2tyZj) method or any other superclass method, but if you do, be sure to call `super` in the implementation of your method. If you do not, the collection view controller may not be able to perform all of the tasks needed to maintain the integrity of the collection view.

	You may also override `prefersActivityIndicatorHidden` to prevent the view from showing the acitivity indicator.

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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Set background color.
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Observe user sign-in status.
		NotificationCenter.default.addObserver(self, selector: #selector(viewWillReload), name: .KUserIsSignedInDidChange, object: nil)

		// Observe theme update notification.
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		// Configure collection view.
		configureCollectionView()

		// Start activity indicator view.
		setupActivityIndicator()

		// Setup empty data view.
		setupEmptyDataSetView()
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
	}

	/**
		Registers cells returned by [registerCells(for collectionView: UICollectionView)](x-source-tag://KCollectionViewDataSource-registerCellsForCollectionView).
	*/
	fileprivate func registerCells() {
		for cell in registerCells(for: collectionView) {
			collectionView.register(nibWithCellClass: cell)
		}
	}
}

// MARK: - Activity Indicator
extension KCollectionViewController {
	/**
		Adds the activity indicator at the center if the view and toggles it.
	*/
	private func setupActivityIndicator() {
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
	@objc func setupEmptyDataSetView() { }

	/**
		Reloads the empty data set of the collection view.
	*/
	@objc func reloadEmptyDataView() {
		collectionView.reloadEmptyDataSet()
	}
}
