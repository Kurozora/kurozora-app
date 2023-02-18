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
	var subscriptionFeatures: [SubscriptionFeature] = [
		SubscriptionFeature(title: "Unified Anime Linking", description: "Seamlessly transition from other services to Kurozora. Add 'kurozora.app' to any URL and let us bring all your anime data in one place.", image: R.image.promotional.inAppPurchases.unifiedAnimeLinking()),
		SubscriptionFeature(title: "Calendar Integration", description: "Integrate your anime schedule into your calendar. Never miss an episode again with reminders for new airings.", image: R.image.promotional.inAppPurchases.reminders()),
		SubscriptionFeature(title: "Dynamic Themes", description: "Choose from a range of themes to create a look that reflects your personality and style.", image: R.image.promotional.inAppPurchases.themes()),
		SubscriptionFeature(title: "Stylish App Icons", description: "Make your home screen stand out with premium and limited time app icons.", image: R.image.promotional.inAppPurchases.icons()),
		SubscriptionFeature(title: "Get Animated!", description: "Upgrade your profile with a gif image that captures your unique style.", image: R.image.promotional.inAppPurchases.gifs()),
		SubscriptionFeature(title: "Support the Community!", description: "Your contribution helps with maintaining the servers, paying for software licenses, and fund events and activities.", image: R.image.promotional.inAppPurchases.support())
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

		// Warn the user if they are not allowed to make purchases.
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
		guard WorkflowController.shared.isSignedIn() else { return }
		Task { [weak self] in
			guard let self = self else { return }
			await self.purchase(cell.product)
		}
	}
}

// MARK: - PurchaseFooterCollectionViewCellDelegate
extension SubscriptionCollectionViewController: PurchaseFooterCollectionViewCellDelegate {
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
		/// The heder section of the table view.
		case header

		/// The current supscription section of the table view
		case currentSubscription

		/// The subscriptions section of the table view.
		case subscriptions

		/// The heder section of the table view.
		case features

		/// The heder section of the table view.
		case footer
	}

	enum ItemKind: Hashable {
		case product(Product, id: UUID = UUID())
		case subscriptionFeature(SubscriptionFeature, id: UUID = UUID())
		case other(id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .product(let product, let id):
				hasher.combine(product)
				hasher.combine(id)
			case .subscriptionFeature(let subscriptionFeature, let id):
				hasher.combine(subscriptionFeature.title)
				hasher.combine(id)
			case .other(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.product(let product1, let id1), .product(let product2, let id2)):
				return product1 == product2 && id1 == id2
			case (.subscriptionFeature(let subscriptionFeature1, let id1), .subscriptionFeature(let subscriptionFeature2, let id2)):
				return subscriptionFeature1.title == subscriptionFeature2.title && id1 == id2
			case (.other(let id1), .other(let id2)):
				return id1 == id2
			default:
				return false
			}
		}
	}
}
