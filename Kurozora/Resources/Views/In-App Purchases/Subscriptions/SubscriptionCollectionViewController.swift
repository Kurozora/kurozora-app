//
//  SubscriptionCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import SPConfetti

class SubscriptionCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	/// The left navigation bar button of the navigation controller's `navigationItem`.
	@IBOutlet weak var leftNavigationBarButton: UIBarButtonItem?

	// MARK: - Properties
	var products: [Product] {
		return store.subscriptions.filter {
			return $0.id != self.currentSubscription?.id
		}
	}
	var currentSubscription: Product?
	var status: Product.SubscriptionInfo.Status?
	var productFeatures: [ProductFeature] = [
		ProductFeature(title: "Unified Anime Linking", description: "Seamlessly transition from other services to Kurozora. Add 'kurozora.app' to any URL and let us bring all your anime data in one place.", image: R.image.promotional.inAppPurchases.unifiedAnimeLinking()),
		ProductFeature(title: "Calendar Integration", description: "Integrate your anime schedule into your calendar. Never miss an episode again with reminders for new airings.", image: R.image.promotional.inAppPurchases.reminders()),
		ProductFeature(title: "Dynamic Themes", description: "Choose from a range of themes to create a look that reflects your personality and style.", image: R.image.promotional.inAppPurchases.themes()),
		ProductFeature(title: "Stylish App Icons", description: "Make your home screen stand out with premium and limited time app icons.", image: R.image.promotional.inAppPurchases.icons()),
		ProductFeature(title: "Startup Chimes", description: "Immerse yourself in the world of anime from the very start with serene chimes and iconic anime sounds.", image: R.image.promotional.inAppPurchases.chimes()),
		ProductFeature(title: "Get Animated!", description: "Upgrade your profile with a gif image that captures your unique style.", image: R.image.promotional.inAppPurchases.gifs()),
		ProductFeature(title: "Up to 1000 characters", description: "Dive even deeper into discussions with an extended 1000 character limit for your feed messages.", image: R.image.promotional.inAppPurchases.characterCount500()),
		ProductFeature(title: "Subscriber Badge", description: "Stand out in the community with an exclusive subscription badge that evolves over time as you continue to support Kurozora!", image: R.image.promotional.inAppPurchases.subscriberBadge()),
		ProductFeature(title: "Support the Community!", description: "Your contribution helps with maintaining the servers, paying for software licenses, and fund events and activities.", image: R.image.promotional.inAppPurchases.support())
	]
	var serviceType: ServiceType = .subscription

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	/// A storage for the `leftBarButtonItems` of `navigationItem`.
	fileprivate var _leftBarButtonItems: [UIBarButtonItem]?
	/// Set to `false` to hide the left navigation bar.
	var leftNavigationBarButtonIsHidden: Bool = false {
		didSet {
			if self.leftNavigationBarButtonIsHidden {
				let leftBarButtonItems = self.navigationItem.leftBarButtonItems
				if leftBarButtonItems != nil {
					self._leftBarButtonItems = self.navigationItem.leftBarButtonItems
					self.navigationItem.leftBarButtonItems = nil
				}
			} else {
				self.navigationItem.leftBarButtonItems = self._leftBarButtonItems
			}
		}
	}

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return _prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Disable refresh control
		self._prefersRefreshControlDisabled = true

		// Disable activity indicator
		self._prefersActivityIndicatorHidden = true

		// Configure data source
		self.configureDataSource()

		// Dismiss the view if the user is not allowed to make purchases.
		if !AppStore.canMakePayments {
			self.dismiss(animated: true)
		} else {
			Task { [weak self] in
				guard let self = self else { return }

				if await self.updateSubscriptionStatus() {
					self.updateDataSource()
				}
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		SPConfetti.stopAnimating()
	}

	// MARK: - Functions
	@MainActor
	func purchase(_ product: Product) async {
		do {
			guard try await store.purchase(product) != nil else { return }

			let success = await self.updateSubscriptionStatus()
			self.updateDataSource()

			if success {
				SPConfetti.startAnimating(.fullWidthToDown, particles: [.star, .arc], duration: 3000)
			}
		} catch StoreError.failedVerification {
			_ = self.presentAlertController(title: "Purchase Failed", message: "Your purchase could not be verified by App Store. If this continues to happen, please contact the developer.")
		} catch {
			print("------ Failed purchase: \(error)")
		}
	}

	@MainActor
	func updateSubscriptionStatus() async -> Bool {
		do {
			// This app has only one subscription group so products in the subscriptions
			// array all belong to the same group. The statuses returned by
			// `product.subscription.status` apply to the entire subscription group.
			guard let product = store.subscriptions.first,
				  let statuses = try await product.subscription?.status else {
				return false
			}

			var highestStatus: Product.SubscriptionInfo.Status? = nil
			var highestProduct: Product? = nil

			// Iterate through `statuses` for this subscription group and find
			// the `Status` with the highest level of service which isn't
			// expired or revoked.
			for status in statuses {
				switch status.state {
				case .expired, .revoked:
					continue
				default:
					let renewalInfo = try store.checkVerified(status.renewalInfo)

					guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
						continue
					}

					guard let currentProduct = highestProduct else {
						highestStatus = status
						highestProduct = newSubscription
						continue
					}

					let highestTier = store.tier(for: currentProduct.id)
					let newTier = store.tier(for: renewalInfo.currentProductID)

					if newTier > highestTier {
						highestStatus = status
						highestProduct = newSubscription
					}
				}
			}

			self.status = highestStatus
			self.currentSubscription = highestProduct
			return true
		} catch {
			print("----- Could not update subscription status \(error)")
			return false
		}
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - PurchaseButtonCollectionViewCellDelegate
extension SubscriptionCollectionViewController: PurchaseButtonCollectionViewCellDelegate {
	func purchaseButtonCollectionViewCell(_ cell: PurchaseButtonCollectionViewCell, didPressButton button: UIButton) {
		WorkflowController.shared.isSignedIn(on: self) { [weak self] in
			guard let self = self else { return }

			Task {
				await self.purchase(cell.product)
			}
		}
	}
}

// MARK: - PurchaseFooterCollectionViewCellDelegate
extension SubscriptionCollectionViewController: PurchaseFooterCollectionViewCellDelegate {
	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressRestorePurchaseButton button: UIButton) {
		WorkflowController.shared.isSignedIn(on: self) {
			Task {
				await store.restore()
			}
		}
	}

	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressTermsOfUseButton button: UIButton) {
		UIApplication.shared.kOpen(URL.appStoreEULA)
	}

	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressPrivacyButton button: UIButton) {
		guard let legalKNavigationViewController = R.storyboard.legal.instantiateInitialViewController() else { return }
		self.present(legalKNavigationViewController, animated: true)
	}
}

// MARK: - SectionLayoutKind
extension SubscriptionCollectionViewController {
	/// Set of available subscription table view sections.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// The header section of the collection view.
		case header

		/// The current subscription section of the table view
		case currentSubscription

		/// The subscriptions section of the collection view.
		case subscriptions

		/// The features section of the collection view.
		case features

		/// The footer section of the collection view.
		case footer
	}

	enum ItemKind: Hashable {
		case product(Product, id: UUID = UUID())
		case productFeature(ProductFeature, id: UUID = UUID())
		case other(id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .product(let product, let id):
				hasher.combine(product)
				hasher.combine(id)
			case .productFeature(let productFeature, let id):
				hasher.combine(productFeature.title)
				hasher.combine(id)
			case .other(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.product(let product1, let id1), .product(let product2, let id2)):
				return product1 == product2 && id1 == id2
			case (.productFeature(let productFeature1, let id1), .productFeature(let productFeature2, let id2)):
				return productFeature1.title == productFeature2.title && id1 == id2
			case (.other(let id1), .other(let id2)):
				return id1 == id2
			default:
				return false
			}
		}
	}
}
