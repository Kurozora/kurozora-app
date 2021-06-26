//
//  KTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import ESTabBarController_swift

class KTabBarController: ESTabBarController {
	// MARK: - Properties
//	fileprivate var once: Bool = false

	// MARK: - Initializers
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//		if !once {
//			self.tabBar.isTranslucent = true
//			self.tabBar.itemPositioning = .centered
//			self.tabBar.backgroundColor = .clear
//			self.tabBar.barStyle = .default
//
//			once = true
//		}
//	}

    override func viewDidLoad() {
		super.viewDidLoad()

		// Initialize views
		viewControllers = TabBarItem.allCases.map {
			let rootNavigationController = $0.kViewControllerValue
			rootNavigationController.tabBarItem = ESTabBarItem(BounceAnimation(), title: $0.stringValue, image: $0.imageValue, selectedImage: $0.selectedImageValue)
			return rootNavigationController
		}

		setupBadgeValue()
		NotificationCenter.default.addObserver(self, selector: #selector(toggleBadge), name: .KSNotificationsBadgeIsOn, object: nil)
    }

	// MARK: - Functions
	/// The shared settings used to initialize tab bar view.
	private func sharedInit() {
		self.tabBar.isTranslucent = true
		self.tabBar.itemPositioning = .centered
		self.tabBar.backgroundColor = .clear
		self.tabBar.barStyle = .default
	}

	/// Toggles the badge on/off on the tab bar item.
	@objc func toggleBadge() {
		setupBadgeValue()
	}

	/// Sets up the badge value on the tab bar item.
	fileprivate func setupBadgeValue() {
		if UserSettings.notificationsBadge, User.isSignedIn {
			self.tabBar.items?[3].badgeValue = "\(69)"
		} else {
			self.tabBar.items?[3].badgeValue = nil
		}
	}
}

extension KTabBarController {
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		let selectedTwice = tabBar.selectedItem == item

		super.tabBar(tabBar, didSelect: item)

		if selectedTwice {
			let selectedViewController = (viewControllers?[selectedIndex] as? KNavigationController)?.visibleViewController
			switch selectedIndex {
			case 0:
				(selectedViewController as? UICollectionViewController)?.collectionView.safeScrollToItem(at: [0, 0], at: .top, animated: true)
			case 1:
				((selectedViewController as? KTabbedViewController)?.currentViewController as? UICollectionViewController)?.collectionView.safeScrollToItem(at: [0, 0], at: .top, animated: true)
			case 2:
				(selectedViewController as? UITableViewController)?.tableView.safeScrollToRow(at: [0, 0], at: .top, animated: true)
			case 3:
				(selectedViewController as? UITableViewController)?.tableView.safeScrollToRow(at: [0, 0], at: .top, animated: true)
			case 4:
				(selectedViewController as? UICollectionViewController)?.navigationItem.searchController?.searchBar.textField?.becomeFirstResponder()
			default: break
			}
		}
	}
}

/**
	The list of available tab bar items.
 */
enum TabBarItem: Int, CaseIterable {
	// MARK: - Cases
	/// Representing the home tab.
	case home = 0

	/// Representing the library tab.
	case library

	/// Representing the feed tab.
	case feed

	/// Representing the notification tab.
	case notifications

	#if !targetEnvironment(macCatalyst)
	/// Representing the search tab.
	case search
	#endif

	// MARK: - Structs
	/**
		List of row identifiers.
	 */
	private struct RowIdentifier {
		/// The unique identifier for the home tab.
		static let home = UUID()

		/// The unique identifier for the library tab.
		static let library = UUID()

		/// The unique identifier for the feed tab.
		static let feed = UUID()

		/// The unique identifier for the notification tab.
		static let notifications = UUID()

		#if !targetEnvironment(macCatalyst)
		/// The unique identifier for the search tab.
		static let search = UUID()
		#endif
	}

	// MARK: - Properties
	/// The string value of the tab bar item.
	var stringValue: String {
		switch self {
		case .home:
			return "Explore"
		case .library:
			return "Library"
		case .feed:
			return "Feed"
		case .notifications:
			return "Notifications"
		#if !targetEnvironment(macCatalyst)
		case .search:
			return "Search"
		#endif
		}
	}

	/// The image value of the tab bar item.
	var imageValue: UIImage {
		switch self {
		case .home:
			return UIImage(systemName: "house")!
		case .library:
			return UIImage(systemName: "rectangle.stack")!
		case .feed:
			return UIImage(systemName: "person.crop.circle")!
		case .notifications:
			return UIImage(systemName: "app.badge")!
		#if !targetEnvironment(macCatalyst)
		case .search:
			return UIImage(systemName: "magnifyingglass")!
		#endif
		}
	}

	/// The selected image value of the tab bar item.
	var selectedImageValue: UIImage {
		switch self {
		case .home:
			return UIImage(systemName: "house.fill")!
		case .library:
			return UIImage(systemName: "rectangle.stack.fill")!
		case .feed:
			return UIImage(systemName: "person.crop.circle.fill")!
		case .notifications:
			return UIImage(systemName: "app.badge.fill")!
		#if !targetEnvironment(macCatalyst)
		case .search:
			return R.image.symbols.magnifyingglassFill()!
		#endif
		}
	}

	/// The view controller value of the tab bar item.
	var viewControllerValue: UIViewController {
		switch self {
		case .home:
			return R.storyboard.home.homeCollectionViewController()!
		case .library:
			return R.storyboard.library.libraryViewController()!
		case .feed:
			return R.storyboard.feed.feedTableViewController()!
		case .notifications:
			return R.storyboard.notifications.notificationsTableViewController()!
		#if !targetEnvironment(macCatalyst)
		case .search:
			return R.storyboard.search.searchResultsCollectionViewController()!
		#endif
		}
	}

	/// The navigation controller value of the tab bar item.
	var kViewControllerValue: UIViewController {
		switch self {
		case .home:
			return R.storyboard.home.homeKNavigationController()!
		case .library:
			return R.storyboard.library.libraryKNavigationController()!
		case .feed:
			return R.storyboard.feed.feedTableKNavigationController()!
		case .notifications:
			return R.storyboard.notifications.notificationKNvaigationController()!
		#if !targetEnvironment(macCatalyst)
		case .search:
			return R.storyboard.search.searchKNvaigationController()!
		#endif
		}
	}

	/// The unique row identifier value of the tab bar item.
	var rowIdentifierValue: UUID {
		switch self {
		case .home:
			return RowIdentifier.home
		case .library:
			return RowIdentifier.library
		case .feed:
			return RowIdentifier.feed
		case .notifications:
			return RowIdentifier.notifications
		#if !targetEnvironment(macCatalyst)
		case .search:
			return RowIdentifier.search
		#endif
		}
	}
}
