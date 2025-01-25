//
//  TipJarCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import SPConfetti

class TipJarCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	/// The left navigation bar button of the navigation controller's `navigationItem`.
	@IBOutlet weak var leftNavigationBarButton: UIBarButtonItem?

	// MARK: - Properties
	var products: [Product] {
		return store.tips
	}
	var productFeatures: [ProductFeature] = [
		ProductFeature(title: "Stylish App Icons", description: "Make your home screen stand out with premium and limited time app icons.", image: R.image.promotional.inAppPurchases.icons()),
		ProductFeature(title: "Startup Chimes", description: "Immerse yourself in the world of anime from the very start with serene chimes and iconic anime sounds.", image: R.image.promotional.inAppPurchases.chimes()),
		ProductFeature(title: "Get Animated", description: "Upgrade your profile with a gif image that captures your unique style.", image: R.image.promotional.inAppPurchases.gifs()),
		ProductFeature(title: "Change Your Identity", description: "Switch things up every now an then with a fresh username that truly represents you.", image: R.image.promotional.inAppPurchases.username()),
		ProductFeature(title: "Up to 500 Characters", description: "Have more to say? Express yourself fully with a 500 character limit for your feed messages.", image: R.image.promotional.inAppPurchases.characterCount500()),
		ProductFeature(title: "Unlock Pro Badge", description: "Elevate your status in the Kurozora community with the prestigious Pro badge next to your username, and show your support for Kurozora.", image: R.image.promotional.inAppPurchases.proBadge()),
		ProductFeature(title: "Support the Community", description: "Your contribution helps with maintaining the servers, paying for software licenses, and fund events and activities.", image: R.image.promotional.inAppPurchases.support())
	]
	var serviceType: ServiceType = .tipJar

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	/// A storage for the `leftBarButtonItems` of `navigationItem`.
	fileprivate var _leftBarButtonItems: [UIBarButtonItem]?
	/// Set to `false` to hide the left navigation bar.
	var leftNavigationBarButtonIsHidden: Bool = false {
		didSet {
			if leftNavigationBarButtonIsHidden {
				let leftBarButtonItems = navigationItem.leftBarButtonItems
				if leftBarButtonItems != nil {
					_leftBarButtonItems = navigationItem.leftBarButtonItems
					navigationItem.leftBarButtonItems = nil
				}
			} else {
				navigationItem.leftBarButtonItems = _leftBarButtonItems
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
			self.updateDataSource()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		SPConfetti.stopAnimating()
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - PurchaseButtonCollectionViewCellDelegate
extension TipJarCollectionViewController: PurchaseButtonCollectionViewCellDelegate {
	func purchaseButtonCollectionViewCell(_ cell: PurchaseButtonCollectionViewCell, didPressButton button: UIButton) {
		WorkflowController.shared.isSignedIn(on: self) { [weak self] in
			guard let self = self else { return }

			Task {
				await self.purchase(cell.product)
			}
		}
	}

	func purchase(_ product: Product) async {
		do {
			guard try await store.purchase(product) != nil else { return }

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

// MARK: - Section
extension TipJarCollectionViewController {
	/// Set of available tip jar table view sections.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// The header section of the collection view.
		case header

		/// The prodcuts section of the collection view.
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
