//
//  KTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import SwiftTheme
import UIKit
#if DEBUG
import FLEX
#endif

class KTabBarController: UITabBarController {
	// MARK: - Properties
	private var subscriptions = Set<AnyCancellable>()
	private var _previousTabs: NSObject?

	/// The now-playing accessory's content view, retained so its container can be sized across size-class changes.
	private var musicAccessoryContentView: UIView?

	/// The library sync-progress ring.
	private var syncProgressRingView: SyncProgressRingView?

	/// The constraints currently pinning the sync-progress ring to its host row.
	private var syncProgressRingConstraints: [NSLayoutConstraint] = []

	/// The pending removal task for the sync-progress ring.
	private var syncProgressRingRemovalTask: Task<Void, Never>?

	@available(iOS 18.0, *)
	private var previousTabs: [UITab] {
		get {
			if let tabs = self._previousTabs as? [UITab] {
				return tabs
			} else {
				return []
			}
		}
		set {
			self._previousTabs = newValue as NSObject
		}
	}

	// MARK: - Initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	@available(iOS 18.0, *)
	override init(tabs: [UITab]) {
		super.init(tabs: tabs)
		self.sharedInit()
	}

	// MARK: - View
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		#if !targetEnvironment(macCatalyst)
		self.updateMusicAccessorySize()
		#endif
		self.updateLibrarySyncIndicator()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationsDidUpdate), name: .KUNDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleLibrarySyncProgressDidChange), name: .KLibrarySyncProgressDidChange, object: nil)

		// Initialize views
		self.configureTabs()

		if #available(iOS 18.0, *) {
			self.registerForTraitChanges([UITraitHorizontalSizeClass.self], action: #selector(handleHorizontalSizeClass))
		}
	}

	@available(iOS 18.0, *)
	@objc func handleHorizontalSizeClass() {
		if self.traitCollection.horizontalSizeClass == .compact {
			self.previousTabs = self.tabs
			self.tabs = self.tabs.filter { tab in
				tab.preferredPlacement == .fixed || tab.preferredPlacement == .pinned
			}
		} else if !self.previousTabs.isEmpty {
			self.tabs = self.previousTabs
		}

		self.updateLibrarySyncIndicator()
	}

	/// Refreshes the library tab's sync indicator when sync progress changes.
	@objc private func handleLibrarySyncProgressDidChange() {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.updateLibrarySyncIndicator()
		}
	}

	/// Shows a pie progress indicator over the library row's badge slot in the sidebar while syncing.
	private func updateLibrarySyncIndicator() {
		guard #available(iOS 18.0, *) else { return }

		let syncProgress = LibrarySyncProgress.shared
		let sidebarIsVisible = self.traitCollection.horizontalSizeClass == .regular
		let ringIsVisible = self.syncProgressRingView?.superview != nil

		guard sidebarIsVisible, let libraryRowContentView = self.libraryRowContentView() else {
			self.cancelSyncProgressRingRemoval()
			self.syncProgressRingView?.removeFromSuperview()
			return
		}

		guard syncProgress.isSyncing else {
			if ringIsVisible, self.syncProgressRingRemovalTask == nil {
				self.finishLibrarySyncIndicator()
			}
			return
		}

		// Avoid flashing the pie on empty steady-state rounds until real work is known.
		guard syncProgress.expectedCount ?? 0 > 0 || ringIsVisible else { return }

		let wasFinishing = self.cancelSyncProgressRingRemoval()
		let syncProgressRingView = self.makeSyncProgressRingViewIfNeeded()
		let isNewAppearance = syncProgressRingView.superview == nil || wasFinishing
		self.attachSyncProgressRingView(syncProgressRingView, to: libraryRowContentView)
		if isNewAppearance {
			syncProgressRingView.reset()
		}
		syncProgressRingView.setProgress(syncProgress.fractionCompleted ?? 0, animated: true)
	}

	/// Animates the ring to full, then removes it shortly after.
	private func finishLibrarySyncIndicator() {
		self.syncProgressRingView?.setProgress(1.0, animated: true)

		self.syncProgressRingRemovalTask = Task { @MainActor [weak self] in
			try? await Task.sleep(nanoseconds: 650_000_000)
			guard let self = self, !Task.isCancelled else { return }
			self.syncProgressRingView?.removeFromSuperview()
			self.syncProgressRingRemovalTask = nil
		}
	}

	/// Cancels the pending ring-removal task, if any, and reports whether one was in flight.
	@discardableResult
	private func cancelSyncProgressRingRemoval() -> Bool {
		guard self.syncProgressRingRemovalTask != nil else { return false }
		self.syncProgressRingRemovalTask?.cancel()
		self.syncProgressRingRemovalTask = nil
		return true
	}

	/// Returns the lazily-created sync-progress ring, creating it on first use.
	private func makeSyncProgressRingViewIfNeeded() -> SyncProgressRingView {
		if let syncProgressRingView = self.syncProgressRingView {
			return syncProgressRingView
		}

		let syncProgressRingView = SyncProgressRingView()
		syncProgressRingView.translatesAutoresizingMaskIntoConstraints = false
		self.syncProgressRingView = syncProgressRingView
		return syncProgressRingView
	}

	/// Parents the ring in the given row's content view at the trailing badge position, replacing any prior constraints.
	private func attachSyncProgressRingView(_ syncProgressRingView: SyncProgressRingView, to contentView: UIView) {
		guard syncProgressRingView.superview !== contentView else { return }

		NSLayoutConstraint.deactivate(self.syncProgressRingConstraints)
		contentView.addSubview(syncProgressRingView)

		if let trailingBadgeLabel = self.trailingBadgeLabel(in: contentView) {
			self.syncProgressRingConstraints = [
				syncProgressRingView.centerXAnchor.constraint(equalTo: trailingBadgeLabel.centerXAnchor),
				syncProgressRingView.centerYAnchor.constraint(equalTo: trailingBadgeLabel.centerYAnchor)
			]
		} else {
			self.syncProgressRingConstraints = [
				syncProgressRingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
				syncProgressRingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
			]
		}

		NSLayoutConstraint.activate(self.syncProgressRingConstraints)
	}

	/// Returns the content view of the sidebar row currently displaying the library tab, if visible.
	private func libraryRowContentView() -> UIView? {
		for collectionView in self.collectionViews(in: self.view) {
			for cell in collectionView.visibleCells {
				let isLibraryRow = self.labels(in: cell.contentView).contains { $0.text == TabBarItem.library.stringValue }
				if isLibraryRow {
					return cell.contentView
				}
			}
		}

		return nil
	}

	/// Returns the trailing badge-looking label in the given content view, if the row currently shows one.
	private func trailingBadgeLabel(in contentView: UIView) -> UILabel? {
		return self.labels(in: contentView).first { label in
			label.text != TabBarItem.library.stringValue && !(label.text?.isEmpty ?? true)
		}
	}

	/// Recursively collects every `UICollectionView` in the given view's hierarchy.
	private func collectionViews(in view: UIView) -> [UICollectionView] {
		var collectionViews: [UICollectionView] = []

		if let collectionView = view as? UICollectionView {
			collectionViews.append(collectionView)
		}

		for subview in view.subviews {
			collectionViews.append(contentsOf: self.collectionViews(in: subview))
		}

		return collectionViews
	}

	/// Recursively collects every `UILabel` in the given view's hierarchy.
	private func labels(in view: UIView) -> [UILabel] {
		var labels: [UILabel] = []

		if let label = view as? UILabel {
			labels.append(label)
		}

		for subview in view.subviews {
			labels.append(contentsOf: self.labels(in: subview))
		}

		return labels
	}

	/// Builds the music playback accessory.
	///
	/// - Returns: A tab accessory wrapping a freshly bound ``MusicPlaybackControlView``.
	@available(iOS 26.0, *)
	private func makeMusicAccessory() -> UITabAccessory {
		let musicPlaybackControlView = MusicPlaybackControlView()
		musicPlaybackControlView.playbackController = MusicManager.shared
		self.musicAccessoryContentView = musicPlaybackControlView
		return UITabAccessory(contentView: musicPlaybackControlView)
	}

    #if !targetEnvironment(macCatalyst)
	/// Sizes the music player accessory's container.
	///
	/// - Note: After the window crosses between the regular and compact layouts, the system leaves the accessory
	/// at a stale size and no longer resizes it. The controller keeps laying out, so it drives the
	/// container's frame here, centered in the content area beside the sidebar. Ugly, but so is Apple's
	/// implementation of tab bar bottom accessory.
	private func updateMusicAccessorySize() {
		guard #available(iOS 26.0, *), self.traitCollection.horizontalSizeClass == .regular else { return }
		guard let container = self.musicAccessoryContentView?.superview, let containerParent = container.superview else { return }

		// The system centers the accessory on the content-area center (non-sidebar area). Keep that
		// center and cap the width to what fits symmetrically around it, so it never crosses the sidebar.
		let horizontalInset: CGFloat = 16
		let center = container.frame.midX
		let widthFittingContentArea = max(0, 2 * (containerParent.bounds.width - horizontalInset - center))

		let readableWidth = self.view.readableContentGuide.layoutFrame.width
		let targetWidth = min(readableWidth > 0 ? readableWidth : widthFittingContentArea, widthFittingContentArea)
		let targetHeight: CGFloat = 64
		guard targetWidth > 0 else { return }

		let targetFrame = CGRect(
			x: (center - targetWidth / 2).rounded(),
			y: (container.frame.maxY - targetHeight).rounded(),
			width: targetWidth.rounded(),
			height: targetHeight
		)

		if container.frame != targetFrame {
			container.frame = targetFrame
		}
	}
    #endif

	/// Configure the tabs.
	@MainActor
	func configureTabs() {
		if #available(iOS 18.0, *) {
			self.delegate = self
			self.tabs = TabBarItem.tabBarCases.map { $0.tab }
			self.selectTab(.home)
			self.previousTabs = self.tabs
		} else {
			self.viewControllers = TabBarItem.tabBarCases.map {
				let rootNavigationController = $0.kViewControllerValue
				let tabBarItem: UITabBarItem

				if $0 != .search {
					tabBarItem = UITabBarItem(title: $0.stringValue, image: $0.imageValue, selectedImage: $0.selectedImageValue)
				} else {
					tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: $0.rawValue)
					tabBarItem.title = $0.stringValue
					tabBarItem.image = $0.imageValue
					tabBarItem.selectedImage = $0.selectedImageValue
				}

				rootNavigationController.tabBarItem = tabBarItem
				return rootNavigationController
			}
		}
	}

	// MARK: - Functions
	/// Re-applies the localized tab titles in place, preserving each tab's navigation stack.
	override func reloadLocalization() {
		if #available(iOS 18.0, macCatalyst 18.0, *) {
			for tab in self.tabs {
				guard let tabBarItem = TabBarItem.tabBarCases.first(where: { $0.rowIdentifierValue == tab.identifier }) else { continue }
				tab.title = tabBarItem.stringValue
			}
		} else {
			self.viewControllers?.enumerated().forEach { index, viewController in
				guard TabBarItem.tabBarCases.indices.contains(index) else { return }
				viewController.tabBarItem?.title = TabBarItem.tabBarCases[index].stringValue
			}
		}
	}

	func selectTab(_ tabItem: TabBarItem) {
		if #available(iOS 18.0, *) {
			self.selectedIndex = self.tabs.firstIndex(of: tabItem.tab) ?? 0
		} else {
			self.selectedIndex = tabItem.rawValue
		}
	}

	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		#if DEBUG
		let showFlexLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.showFlex))
		#if targetEnvironment(macCatalyst)
		showFlexLongPressGestureRecognizer.minimumPressDuration = 2.0
		#else
		showFlexLongPressGestureRecognizer.numberOfTouchesRequired = 2
		#endif
		#endif

		if #available(iOS 18.0, *) {
			self.mode = .tabSidebar

			let sidebarBottomProfileView = KSidebarBottomProfileView()
			sidebarBottomProfileView.delegate = self
			self.sidebar.bottomBarView = sidebarBottomProfileView
		}

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.tabBarMinimizeBehavior = .onScrollDown
			self.observePlayback()

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			UIApplication.topViewController?.view.window?.addGestureRecognizer(showFlexLongPressGestureRecognizer)
			#endif
			#endif
		} else {
			self.tabBar.isTranslucent = true
			self.tabBar.backgroundColor = .clear
			self.tabBar.barStyle = .default
			self.tabBar.itemPositioning = .centered
			self.tabBar.theme_tintColor = KThemePicker.tintColor.rawValue

			let appearance = UITabBarAppearance()
			appearance.theme_backgroundColor = KThemePicker.barTintColor.rawValue

			self.tabBar.theme_standardAppearance = ThemeTabBarAppearancePicker(appearances: appearance)
			self.tabBar.theme_compactAppearance = ThemeTabBarAppearancePicker(appearances: appearance)

			#if DEBUG
			self.tabBar.addGestureRecognizer(showFlexLongPressGestureRecognizer)
			#endif

			let showAccountSwitcherLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.showAccountSwitcher))
			showAccountSwitcherLongPressGestureRecognizer.numberOfTouchesRequired = 1
			self.tabBar.addGestureRecognizer(showAccountSwitcherLongPressGestureRecognizer)
		}
	}

	/// Observes `MusicManager` playback state and shows or hides the bottom accessory accordingly.
	@available(iOS 26.0, *)
	private func observePlayback() {
		MusicManager.shared.$currentSong
			.receive(on: RunLoop.main)
			.sink { [weak self] song in
				guard let self = self else { return }

				if song != nil {
					if self.bottomAccessory == nil {
						self.setBottomAccessory(self.makeMusicAccessory(), animated: true)
					}
				} else {
					if self.bottomAccessory != nil {
						self.setBottomAccessory(nil, animated: true)
						self.musicAccessoryContentView = nil
					}
				}
			}
			.store(in: &self.subscriptions)
	}

	#if DEBUG
	/// Show FLEX explorer.
	///
	/// - Parameter gestureRecognizer: The gesture object containing information about the recognized gesture.
	@objc private func showFlex(_ gestureRecognizer: UILongPressGestureRecognizer) {
		if FLEXManager.shared.isHidden {
			FLEXManager.shared.showExplorer()
		}
	}
	#endif

	/// Show Account Switcher.
	///
	/// - Parameter gestureRecognizer: The gesture object containing information about the recognized gesture.
	@objc private func showAccountSwitcher(_ gestureRecognizer: UILongPressGestureRecognizer) {
		if UIApplication.topViewController as? SwitchAccountsTableViewController == nil {
			let switchAccountsTableViewController = SwitchAccountsTableViewController()
			let kNavigationController = KNavigationController(rootViewController: switchAccountsTableViewController)
			kNavigationController.sheetPresentationController?.detents = [.medium()]
			kNavigationController.sheetPresentationController?.selectedDetentIdentifier = .medium
			kNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
			kNavigationController.sheetPresentationController?.prefersGrabberVisible = true

			if UserSettings.hapticsAllowed {
				UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			}

			self.show(kNavigationController, sender: nil)
		}
	}

	/// Sets up the badge value on the tab bar item.
	func setBadgeValue(_ value: String?, for tabBarItem: TabBarItem) {
		let badgeValue = switch tabBarItem {
		case .home, .schedule, .library, .feed, .search, .settings:
			value
		case .notifications:
			UserSettings.notificationsBadge && User.isSignedIn ? value : nil
		}

		if #available(iOS 18.0, *) {
			let tab = self.tabs.first {
				$0.identifier == tabBarItem.rowIdentifierValue
			}
			tab?.badgeValue = badgeValue
		} else {
			let tab = self.tabBar.items?.first(where: { item in
				item.tag == tabBarItem.rawValue
			})
			tab?.badgeValue = badgeValue
		}
	}

	/// Handles refreshing the notifications badge when the user notifications change.
	@objc private func handleNotificationsDidUpdate(_ notification: Notification) {
		Task { @MainActor [weak self] in
			guard let self = self, User.isSignedIn else { return }
			if self.notificationsTableViewController()?.viewIfLoaded != nil {
				return
			}
			do {
				let response = try await KService.notifications().response()
				let unreadCount = response.data.filter { $0.attributes.readStatus == .unread }.count
				self.setBadgeValue(unreadCount == 0 ? nil : "\(unreadCount)", for: .notifications)
			} catch {
				print("LiveUpdates: failed to refresh notifications badge -", error.localizedDescription)
			}
		}
	}

	/// Returns the loaded `NotificationsTableViewController` instance for the notifications tab, if any.
	private func notificationsTableViewController() -> NotificationsTableViewController? {
		guard let index = TabBarItem.tabBarCases.firstIndex(of: .notifications),
			let viewControllers = self.viewControllers, viewControllers.indices.contains(index),
			let navigationController = viewControllers[index] as? KNavigationController else {
			return nil
		}

		return navigationController.viewControllers.first as? NotificationsTableViewController
	}
}

// MARK: - UITabBarControllerDelegate
extension KTabBarController: UITabBarControllerDelegate {
	@available(iOS 18.0, *)
	func tabBarController(_ tabBarController: UITabBarController, didSelectTab selectedTab: UITab, previousTab: UITab?) {
		if UserSettings.hapticsAllowed {
			UISelectionFeedbackGenerator().selectionChanged()
		}

		if let sidebarBottomProfileView = self.sidebar.bottomBarView as? KSidebarBottomProfileView {
			sidebarBottomProfileView.isSelected = false
		}

		if selectedTab == previousTab, let tabBarItem = TabBarItem(identifierValue: selectedTab.identifier) { // Same tab selected
			let selectedViewController = (self.selectedViewController as? KNavigationController)?.visibleViewController

			switch tabBarItem {
			case .home, .library:
				let collectionView = (selectedViewController as? UICollectionViewController)?.collectionView
				if collectionView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					collectionView?.safeScrollToItem(at: [0, 0], at: .top, animated: true)
				}
			case .schedule:
				let collectionViewController = selectedViewController as? ScheduleCollectionViewController
				collectionViewController?.scrollToToday(animated: true)
			case .feed, .notifications:
				let tableView = (selectedViewController as? UITableViewController)?.tableView
				if tableView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					tableView?.safeScrollToRow(at: [0, 0], at: .top, animated: true)
				}
			case .search:
				let collectionViewController = selectedViewController as? UICollectionViewController
				collectionViewController?.navigationItem.searchController?.searchBar.searchTextField.becomeFirstResponder()
			case .settings: return
			}
		}
	}

	@available(iOS 18.0, *)
	func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
		guard let tabBarItem = TabBarItem(identifierValue: tab.identifier) else { return true } // Select by default

		switch tabBarItem {
		case .settings:
			self.presentSettingsViewController()
			return false
		default:
			return true
		}
	}

	@available(iOS 18.0, *)
	func presentSettingsViewController() {
		// Since the view controller in the selected tab is owned
		// by the tab controller, the app crashes if you present it.
		// So we create a new instance to present instead.
		let settingsSplitViewController = TabBarItem.settings.kViewControllerValue
		settingsSplitViewController.modalPresentationStyle = .fullScreen
		self.present(settingsSplitViewController, animated: true)
	}
}

// MARK: - UITabBarDelegate
extension KTabBarController {
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		guard
			let index = tabBar.items?.firstIndex(of: item),
			self.viewControllers?[index] != nil
		else { return }
		self.selectedIndex = index

		if UserSettings.hapticsAllowed {
			UISelectionFeedbackGenerator().selectionChanged()
		}

		if tabBar.selectedItem == item, let tabBarItem = TabBarItem(rawValue: self.selectedIndex) { // Same tab selected
			let selectedViewController = (self.selectedViewController as? KNavigationController)?.visibleViewController

			switch tabBarItem {
			case .home, .schedule, .library:
				let collectionView = (selectedViewController as? UICollectionViewController)?.collectionView
				if collectionView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					collectionView?.safeScrollToItem(at: [0, 0], at: .top, animated: true)
				}
			case .feed, .notifications:
				let tableView = (selectedViewController as? UITableViewController)?.tableView
				if tableView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					tableView?.safeScrollToRow(at: [0, 0], at: .top, animated: true)
				}
			case .search:
				(selectedViewController as? UICollectionViewController)?.navigationItem.searchController?.searchBar.searchTextField.becomeFirstResponder()
			case .settings: break
			}
		}
	}
}

// MARK: - KSidebarBottomProfileViewDelegate
extension KTabBarController: KSidebarBottomProfileViewDelegate {
	func sidebarBottomProfileViewDidTap(_ profileView: KSidebarBottomProfileView) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn, let user = User.current else { return }

		if let navigationController = self.selectedViewController as? KNavigationController,
		   let visibleProfile = navigationController.visibleViewController as? ProfileTableViewController,
		   visibleProfile.user?.id == user.id {
			return
		}

		let profileTableViewController = ProfileTableViewController()(with: user)
		if #available(iOS 18.0, *) {
			profileTableViewController.sidebarBottomProfileView = self.sidebar.bottomBarView as? KSidebarBottomProfileView
			self.selectedTab = nil
		}
		self.selectedViewController?.show(profileTableViewController, sender: nil)
	}
}
