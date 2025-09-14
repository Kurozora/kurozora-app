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
		self.viewControllers = TabBarItem.tabBarCases.map {
			let rootNavigationController = $0.kViewControllerValue
			// MARK: Refactor
//			BounceAnimation()
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

		self.setupBadgeValue()
		NotificationCenter.default.addObserver(self, selector: #selector(self.toggleBadge), name: .KSNotificationsBadgeIsOn, object: nil)
	}

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		#if DEBUG
		let showFlexLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.showFlex))
		showFlexLongPressGestureRecognizer.numberOfTouchesRequired = 2
		#endif

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.tabBarMinimizeBehavior = .onScrollDown

			#if DEBUG
			UIApplication.topViewController?.view.window?.addGestureRecognizer(showFlexLongPressGestureRecognizer)
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
			self.tabBar.items?[3].badgeValue = nil
		} else {
			self.tabBar.items?[3].badgeValue = nil
		}
	}
}

// MARK: - UITabBarDelegate
extension KTabBarController {
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		guard let idx = tabBar.items?.firstIndex(of: item), self.viewControllers?[idx] != nil else { return }
		self.selectedIndex = idx

		if UserSettings.hapticsAllowed {
			UISelectionFeedbackGenerator().selectionChanged()
		}

		if tabBar.selectedItem == item { // Same tab selected
			let selectedViewController = (self.viewControllers?[safe: self.selectedIndex] as? KNavigationController)?.visibleViewController
			switch self.selectedIndex {
			case 0:
				let collectionView = (selectedViewController as? UICollectionViewController)?.collectionView
				if collectionView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					collectionView?.safeScrollToItem(at: [0, 0], at: .top, animated: true)
				}
			case 1:
				let collectionView = ((selectedViewController as? KTabbedViewController)?.currentViewController as? UICollectionViewController)?.collectionView
				if collectionView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					collectionView?.safeScrollToItem(at: [0, 0], at: .top, animated: true)
				}
			case 2:
				let tableView = (selectedViewController as? UITableViewController)?.tableView
				if tableView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					tableView?.safeScrollToRow(at: [0, 0], at: .top, animated: true)
				}
			case 3:
				let tableView = (selectedViewController as? UITableViewController)?.tableView
				if tableView?.isAtTop ?? true {
					selectedViewController?.dismiss(animated: true, completion: nil)
				} else {
					tableView?.safeScrollToRow(at: [0, 0], at: .top, animated: true)
				}
			case 4:
				(selectedViewController as? UICollectionViewController)?.navigationItem.searchController?.searchBar.searchTextField.becomeFirstResponder()
			default: break
			}
		}
	}
}
