//
//  SubscriptionCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import SPConfetti
import StoreKit
import UIKit

class SubscriptionCollectionViewController: KCollectionViewController {
	// MARK: - Views
	private var closeBarButtonItem: UIBarButtonItem?

	// MARK: - Properties
	var products: [Product] {
		return Store.shared.subscriptions.filter {
			$0.id != self.currentSubscription?.id
		}
	}

	var currentSubscription: Product?
	var status: Product.SubscriptionInfo.Status?
	var productFeatures: [ProductFeature] = [
		ProductFeature(title: L10n.featureUnifiedLinkingTitle, description: L10n.featureUnifiedLinkingDescription, image: .Promotional.Purchases.unifiedLinking),
		ProductFeature(title: L10n.featureCalendarTitle, description: L10n.featureCalendarDescription, image: .Promotional.Purchases.reminders),
		ProductFeature(title: L10n.featureDynamicThemesTitle, description: L10n.featureDynamicThemesDescription, image: .Promotional.Purchases.themes),
		ProductFeature(title: L10n.featureAppIconsTitle, description: L10n.featureAppIconsDescription, image: .Promotional.Purchases.icons),
		ProductFeature(title: L10n.featureStartupChimesTitle, description: L10n.featureStartupChimesDescription, image: .Promotional.Purchases.chimes),
		ProductFeature(title: L10n.featureGetAnimatedTitle, description: L10n.featureGetAnimatedDescription, image: .Promotional.Purchases.gifs),
		ProductFeature(title: L10n.featureChangeIdentityTitle, description: L10n.featureChangeIdentityDescription, image: .Promotional.Purchases.username),
		ProductFeature(title: L10n.featureUpToCharacters(1000), description: L10n.featureSubscriptionCharacterLimitDescription, image: .Promotional.Purchases.characterCount1000),
		ProductFeature(title: L10n.featureSubscriberBadgeTitle, description: L10n.featureSubscriberBadgeDescription, image: .Promotional.Purchases.badgeSubscriber),
		ProductFeature(title: L10n.featureSupportCommunityTitle, description: L10n.featureSupportCommunityDescription, image: .Promotional.Purchases.support)
	]
	var serviceType: ServiceType = .subscription

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.becomeASubscriber

		// Disable refresh control
		self._prefersRefreshControlDisabled = true

		// Disable activity indicator
		self._prefersActivityIndicatorHidden = true

		// Configure data source
		self.configureDataSource()
		self.configureNavigationItems()

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
			guard try await Store.shared.purchase(product) != nil else { return }

			let success = await self.updateSubscriptionStatus()
			self.updateDataSource()

			if success {
				SPConfetti.startAnimating(.fullWidthToDown, particles: [.star, .arc], duration: 3000)
			}
		} catch StoreError.failedVerification {
			_ = self.presentAlertController(title: L10n.purchaseFailedTitle, message: L10n.purchaseVerificationFailedMessage)
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
			guard let product = Store.shared.subscriptions.first,
			      let statuses = try await product.subscription?.status
			else {
				return false
			}

			var highestStatus: Product.SubscriptionInfo.Status?
			var highestProduct: Product?

			// Iterate through `statuses` for this subscription group and find
			// the `Status` with the highest level of service which isn't
			// expired or revoked.
			for status in statuses {
				switch status.state {
				case .expired, .revoked:
					continue
				default:
					let renewalInfo = try Store.shared.checkVerified(status.renewalInfo)

					guard let newSubscription = Store.shared.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
						continue
					}

					guard let currentProduct = highestProduct else {
						highestStatus = status
						highestProduct = newSubscription
						continue
					}

					// Every tier sits at the same App Store Connect subscription level, so price stands in for the highest level of service.
					if newSubscription.price > currentProduct.price {
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

	/// Configures the close bar button item.
	private func configureCloseBarButtonItem() {
		let isRootInNavigation = self.navigationController?.viewControllers.first == self
		let isInsideSplitView = self.splitViewController != nil
		let hasPresenter = self.presentingViewController != nil

		if isRootInNavigation, hasPresenter, !isInsideSplitView {
			self.closeBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
				guard let self = self else { return }
				self.dismiss(animated: true, completion: nil)
			})
			self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
		}
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.configureCloseBarButtonItem()
	}
}

// MARK: - PurchaseButtonCollectionViewCellDelegate
extension SubscriptionCollectionViewController: PurchaseButtonCollectionViewCellDelegate {
	func purchaseButtonCollectionViewCell(_ cell: PurchaseButtonCollectionViewCell, didPressButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		await self.purchase(cell.product)
	}
}

// MARK: - PurchaseFooterCollectionViewCellDelegate
extension SubscriptionCollectionViewController: PurchaseFooterCollectionViewCellDelegate {
	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressRestorePurchaseButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		await Store.shared.restore()
	}

	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressTermsOfUseButton button: UIButton) async {
		UIApplication.shared.kOpen(URL.appStoreEULA)
	}

	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressPrivacyButton button: UIButton) async {
		let legalViewController = LegalViewController()
		let kNavigationViewController = KNavigationController(rootViewController: legalViewController)
		self.present(kNavigationViewController, animated: true)
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
