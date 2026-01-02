//
//  KCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// A supercharged view controller that specializes in managing a collection view.
///
/// This implementation of [UICollectionViewController](apple-reference-documentation://hskgp2RLo1) implements the following behavior:
/// - A [KRefreshControl](x-source-tag://KRefreshControl) is added to the collection view.
/// - A [UIActivityIndicatorView](apple-reference-documentation://hsXlO5I6Ag) is shown when [viewDidLoad](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuiviewcontroller%2F1621495-viewdidload) is called.
/// - The view controller subscribes to the `theme_backgroundColor` of the currently selected theme.
/// - The view controller observes changes in the user's sign in status and runs [viewWillReload](x-source-tag://UIViewController-viewWillReload) if a change has been detected.
/// - The view controller observes changes in the selected app theme and runs [themeWillReload](x-source-tag://UIViewController-themeWillReload) if a change has been detected.
///
/// You create a custom subclass of `KCollectionViewController` for each collection view that you want to manage. When you initialize the controller, using the [init(collectionViewLayout:)](apple-reference-documentation://hsrfD1Zed-) method, you specify the layout the collection view should have. Because the initially created collection view is without dimensions or content, the collection view’s data source and delegate—typically the collection view controller itself—must provide this information.
///
/// You may override the [loadView()](apple-reference-documentation://hsl6d2tyZj) method or any other superclass method, but if you do, be sure to call `super` in the implementation of your method. If you do not, the collection view controller may not be able to perform all of the tasks needed to maintain the integrity of the collection view.
///
/// You may override `prefersRefreshControlDisabled` to prevent the view from activating the refresh control.
///
/// You may also override `prefersActivityIndicatorHidden` to prevent the view from showing the acitivity indicator.
///
/// - Important: Refresh control is unavailable on macOS and as such it is disabled by default. Instead, the key-command `⌘+R` is added.
///
/// - Tag: KCollectionViewController
class KCollectionViewController: UICollectionViewController, SegueHandler {
	// MARK: - Properties
	/// The gradient view object of the view controller.
	private lazy var gradientView: GradientView = {
		let gradientView = GradientView()
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.gradientLayer?.theme_colors = KThemePicker.backgroundColors.gradientPicker
		return gradientView
	}()

	/// The activity indicator view object of the view controller.
	private lazy var activityIndicatorView: KActivityIndicatorView = KActivityIndicatorView()

	/// The object controlling the empty background view.
	lazy var emptyBackgroundView: EmptyBackgroundView = EmptyBackgroundView()

	/// Specifies whether the view controller prefers the activity indicator to be hidden or shown.
	///
	/// If you change the return value for this method, call the [setNeedsActivityIndicatorAppearanceUpdate()](x-source-tag://KCollectionViewDataSource-setNeedsActivityIndicatorAppearanceUpdate) method.
	///
	/// By default, this property returns `false`.
	///
	/// - Returns: `true` if the activity indicator should be hidden or `false` if it should be shown.
	var prefersActivityIndicatorHidden: Bool {
		return false
	}

	#if !targetEnvironment(macCatalyst)
	/// The refresh control used to update the collection contents.
	///
	/// The default value of this property is `nil`.
	///
	/// Assigning a refresh control to this property adds the control to the view controller’s associated interface. You do not need to set the frame of the refresh control before associating it with the view controller. The view controller updates the control’s height and width and sets its position appropriately.
	///
	/// The collection view controller does not automatically update collection's contents in response to user interactions with the refresh control. When the user initiates a refresh operation, the control generates a [valueChanged](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuicontrol%2Fevent%2F1618238-valuechanged) event. You must associate a target and action method with this event and use them to refresh your collection's contents.
	var refreshControl: UIRefreshControl? {
		get {
			return self.collectionView.refreshControl
		}
		set {
			self.collectionView.refreshControl = newValue
		}
	}
	#endif

	/// Specifies whether the collection view prefers the refresh control to be disabled or enabled.
	///
	/// If you change the return value for this method, call the [setNeedsRefreshControlAppearanceUpdate()](x-source-tag://KCollectionViewController-setNeedsRefreshControlAppearanceUpdate) method.
	///
	/// By default, this property returns `true`.
	///
	/// - Returns: `true` if the refresh control should be disabled or `false` if it should be enabled.
	var prefersRefreshControlDisabled: Bool {
		return true
	}

	// MARK: - Initializers
	@MainActor required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init() {
		let layout = UICollectionViewFlowLayout()
		super.init(collectionViewLayout: layout)
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

		// Set collection view theme.
		self.view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Configure the gradient view.
		self.configureGradientView()

		// Configure collection view.
		self.configureCollectionView()

		// Configure refresh control.
		self.configureRefreshControl()

		// Configure activity indicator.
		self.configureActivityIndicator()

		// Configure empty data view.
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
			self.gradientView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
		])
	}

	/// Configures the collection view with default values.
	///
	/// Cells can also be registered during the configuration by using [registerCells(for collectionView: UICollectionView)](x-source-tag://KCollectionViewDataSource-registerCellsForCollectionView).
	fileprivate func configureCollectionView() {
		self.collectionView.backgroundColor = nil
		self.collectionView.prefetchDataSource = self
		if let collectionViewLayout = self.createLayout() {
			self.collectionView.collectionViewLayout = collectionViewLayout
		}
		self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.collectionView.backgroundView = self.emptyBackgroundView

		// Register cells with the collection view.
		self.registerCells()

		// Register reusable views with the collection view.
		self.registerNibs()
	}

	/// Registers cells returned by [registerCells(for collectionView: UICollectionView)](x-source-tag://KCollectionViewDataSource-registerCellsForCollectionView).
	fileprivate func registerCells() {
		for cell in self.registerCells(for: self.collectionView) {
			let identifier = String(describing: cell)
			self.collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
		}
	}

	/// Registers reusable views returned by [registerNibs(for collectionView: UICollectionView)](x-source-tag://KCollectionViewDataSource-registerNibsForCollectionView).
	fileprivate func registerNibs() {
		for nib in self.registerNibs(for: self.collectionView) {
			let identifier = String(describing: nib)
			self.collectionView.register(UINib(nibName: identifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
		}
	}

	// MARK: - SegueHandler
	func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		return nil
	}

	func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {}
}

// MARK: - UICollectionViewDataSourcePrefetching
extension KCollectionViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {}
}

// MARK: - UICollectionViewDelegate
extension KCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let collectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: collectionViewCell, parameters: parameters)
		}
		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		if let indexPath = configuration.identifier as? IndexPath, let collectionViewCell = collectionView.cellForItem(at: indexPath) {
			let parameters = UIPreviewParameters()
			parameters.backgroundColor = .clear
			return UITargetedPreview(view: collectionViewCell, parameters: parameters)
		}
		return nil
	}

	override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		if let previewViewController = animator.previewViewController {
			animator.addCompletion {
				self.show(previewViewController, sender: self)
			}
		}
	}
}

// MARK: - Refresh Control
extension KCollectionViewController {
	/// Configures the refresh control of the collection view.
	private func configureRefreshControl() {
		#if targetEnvironment(macCatalyst)
		#else
		self.collectionView.refreshControl = KRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(self.handleRefreshControl), for: .valueChanged)
		#endif
	}

	/// Indicates to the system that the collection view refresh control attributes have changed.
	///
	/// Call this method if the collection view's refresh control attributes, such as enabled/disabled status, change.
	///
	/// - Tag: KCollectionViewController-setNeedsRefreshControlAppearanceUpdate
	func setNeedsRefreshControlAppearanceUpdate() {
		if self.prefersRefreshControlDisabled {
			#if targetEnvironment(macCatalyst)
			#else
			self.collectionView.refreshControl = nil
			#endif
		} else {
			self.configureRefreshControl()
		}
	}

	/// Action method used to update your content.
	///
	/// This method is called upon activation of the refresh control. Call the refresh control’s [endRefreshing()](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuirefreshcontrol%2F1624848-endrefreshing) method when you are done.
	///
	/// - Tag: KCollectionViewController-handleRefreshControl
	@objc func handleRefreshControl() {}
}

// MARK: - Activity Indicator
extension KCollectionViewController {
	/// Configures the activity indicator with default values.
	private func configureActivityIndicator() {
		self.activityIndicatorView.removeFromSuperview()
		self.view.addSubview(self.activityIndicatorView)
		self.activityIndicatorView.center = self.view.center

		self.setNeedsActivityIndicatorAppearanceUpdate()
	}

	/// Indicates to the system that the view controller activity indicator attributes have changed.
	///
	/// Call this method if the view controller's activity indicator attributes, such as hidden/unhidden status or style, change. If you call this method within an animation block, the changes are animated along with the rest of the animation block.
	///
	/// - Tag: KCollectionViewDataSource-setNeedsActivityIndicatorAppearanceUpdate
	func setNeedsActivityIndicatorAppearanceUpdate() {
		self.activityIndicatorView.prefersHidden = self.prefersActivityIndicatorHidden
	}
}

// MARK: - EmptyDataSet
extension KCollectionViewController {
	/// Shows a view to indicate the collection view has no data to show.
	///
	/// Use this method to show a beautiful and informative view when the collection view is empty.
	@objc @MainActor
	func configureEmptyDataView() {}
}

// MARK: - UINavigationControllerDelegate
extension KCollectionViewController: UINavigationControllerDelegate {}

// MARK: - SeguePerforming
extension KCollectionViewController: SeguePerforming {
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
