//
//  TipJarCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import SPConfetti
import StoreKit
import UIKit

class TipJarCollectionViewController: KCollectionViewController {
	// MARK: - Views
	private var closeBarButtonItem: UIBarButtonItem?

	// MARK: - Properties
	var products: [Product] {
		return Store.shared.tips
	}

	var productFeatures: [ProductFeature] = [
		ProductFeature(title: "Stylish App Icons", description: "Make your home screen stand out with premium and limited time app icons.", image: .Promotional.InAppPurchases.icons),
		ProductFeature(title: "Startup Chimes", description: "Immerse yourself in the world of anime from the very start with serene chimes and iconic anime sounds.", image: .Promotional.InAppPurchases.chimes),
		ProductFeature(title: "Get Animated", description: "Upgrade your profile with a gif image that captures your unique style.", image: .Promotional.InAppPurchases.gifs),
		ProductFeature(title: "Change Your Identity", description: "Switch things up every now an then with a fresh username that truly represents you.", image: .Promotional.InAppPurchases.username),
		ProductFeature(title: "Up to 500 Characters", description: "Have more to say? Express yourself fully with a 500 character limit for your feed messages.", image: .Promotional.InAppPurchases.characterCount500),
		ProductFeature(title: "Unlock Pro Badge", description: "Elevate your status in the Kurozora community with the prestigious Pro badge next to your username, and show your support for Kurozora.", image: .Promotional.InAppPurchases.proBadge),
		ProductFeature(title: "Support the Community", description: "Your contribution helps with maintaining the servers, paying for software licenses, and fund events and activities.", image: .Promotional.InAppPurchases.support)
	]
	var serviceType: ServiceType = .tipJar

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// A storage for the `leftBarButtonItems` of `navigationItem`.
	fileprivate var _leftBarButtonItems: [UIBarButtonItem]?
	/// Set to `false` to hide the left navigation bar.
	var leftNavigationBarButtonIsHidden: Bool = false {
		didSet {
			if self.leftNavigationBarButtonIsHidden {
				let leftBarButtonItems = navigationItem.leftBarButtonItems
				if leftBarButtonItems != nil {
					self._leftBarButtonItems = navigationItem.leftBarButtonItems
					navigationItem.leftBarButtonItems = nil
				}
			} else {
				navigationItem.leftBarButtonItems = self._leftBarButtonItems
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

		self.title = Trans.tipJar

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
			self.updateDataSource()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		SPConfetti.stopAnimating()
	}

	// MARK: - Functions
	/// Configures the close bar button item.
	private func configureCloseBarButtonItem() {
		self.closeBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismiss(animated: true, completion: nil)
		})
		self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
	}

	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.configureCloseBarButtonItem()
	}
}

// MARK: - PurchaseButtonCollectionViewCellDelegate
extension TipJarCollectionViewController: PurchaseButtonCollectionViewCellDelegate {
	func purchaseButtonCollectionViewCell(_ cell: PurchaseButtonCollectionViewCell, didPressButton button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		await self.purchase(cell.product)
	}

	func purchase(_ product: Product) async {
		do {
			guard try await Store.shared.purchase(product) != nil else { return }

			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.updateDataSource()
			}
		} catch StoreError.failedVerification {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				_ = self.presentAlertController(title: "Purchase Failed", message: "Your purchase could not be verified by App Store. If this continues to happen, please contact the developer.")
			}
		} catch {
			print("------ Failed purchase: \(error)")
		}
	}
}

// MARK: - PurchaseFooterCollectionViewCellDelegate
extension TipJarCollectionViewController: PurchaseFooterCollectionViewCellDelegate {
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

// MARK: - Section
extension TipJarCollectionViewController {
	/// Set of available tip jar table view sections.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// The header section of the collection view.
		case header

		/// The products section of the collection view.
		case products

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
