//
//  KTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit
#if DEBUG
import FLEX
#endif

class KTabBarController: UITabBarController {
	// MARK: - Properties
	private var _previousTabs: NSObject?

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
	override func viewDidLoad() {
		super.viewDidLoad()

		// Initialize views
		self.configureTabs()

		self.setupBadgeValue()
		NotificationCenter.default.addObserver(self, selector: #selector(self.toggleBadge), name: .KSNotificationsBadgeIsOn, object: nil)

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
	}

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
			self.sidebar.bottomBarView = UIView()
		}

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.tabBarMinimizeBehavior = .onScrollDown

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			UIApplication.topViewController?.view.window?.addGestureRecognizer(showFlexLongPressGestureRecognizer)
			#endif
			#endif
		} else {
			self.tabBar.isTranslucent = true
			self.tabBar.itemPositioning = .centered
			self.tabBar.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
			self.tabBar.barStyle = .default

			#if DEBUG
			self.tabBar.addGestureRecognizer(showFlexLongPressGestureRecognizer)
			#endif

			let showAccountSwitcherLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.showAccountSwitcher))
			showAccountSwitcherLongPressGestureRecognizer.numberOfTouchesRequired = 1
			self.tabBar.addGestureRecognizer(showAccountSwitcherLongPressGestureRecognizer)
		}
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
			if let switchAccountKNavigationController = R.storyboard.switchAccountSettings.switchAccountKNavigationController() {
				switchAccountKNavigationController.sheetPresentationController?.detents = [.medium()]
				switchAccountKNavigationController.sheetPresentationController?.selectedDetentIdentifier = .medium
				switchAccountKNavigationController.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
				switchAccountKNavigationController.sheetPresentationController?.prefersGrabberVisible = true

				if UserSettings.hapticsAllowed {
					UIImpactFeedbackGenerator(style: .medium).impactOccurred()
				}

				self.show(switchAccountKNavigationController, sender: nil)
			}
		}
	}

	/// Toggles the badge on/off on the tab bar item.
	@objc func toggleBadge() {
		self.setupBadgeValue()
	}

	/// Sets up the badge value on the tab bar item.
	fileprivate func setupBadgeValue() {
		if UserSettings.notificationsBadge, User.isSignedIn {
			if #available(iOS 18.0, *) {
				let tab = self.tabs.first {
					$0.identifier == TabBarItem.notifications.rowIdentifierValue
				}

				// MARK: Implement notification badge
				tab?.badgeValue = nil
			} else {
				let tab = self.tabBar.items?.first(where: { item in
					item.tag == TabBarItem.notifications.rawValue
				})

				// MARK: Implement notification badge
				tab?.badgeValue = nil
			}
		} else {
			self.tab?.badgeValue = nil
		}
	}
}

// MARK: - UITabBarControllerDelegate
extension KTabBarController: UITabBarControllerDelegate {
	@available(iOS 18.0, *)
	func tabBarController(_ tabBarController: UITabBarController, didSelectTab selectedTab: UITab, previousTab: UITab?) {
		if UserSettings.hapticsAllowed {
			UISelectionFeedbackGenerator().selectionChanged()
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
