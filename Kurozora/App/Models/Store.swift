//
//  Store.swift
//  Store
//
//  Created by Khoren Katklian on 14/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import Foundation
import StoreKit
import KurozoraKit

/// Information that represents the customer’s purchase of a product in your app.
///
/// A _transaction_ represents a successful in-app purchase. The App Store generates a transaction each time a customer purchases an in-app purchase product or renews a subscription. For each transaction that represents a current purchase, your app unlocks the purchased content or service and finishes the transaction.
///
/// Use the `Transaction` type to perform these transaction-related tasks:
/// - Get the user’s transaction history, latest transactions, and current entitlements to unlock content and services.
/// - Access transaction properties.
/// - Finish a transaction after your app delivers the purchased content or service.
/// - Access the raw JSON Web Signature (JWS) string and supporting values to verify the transaction information.
/// - Listen for new transactions while the app is running.
/// - Begin a refund request from within your app.
typealias Transaction = StoreKit.Transaction

/// The renewal information for an auto-renewable subscription.
///
/// The `Product.SubscriptionInfo.RenewalInfo` provides information about the next subscription renewal period.
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo

/// The renewal states of auto-renewable subscriptions.
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

/// The object responsible for managing in-app purchases with StoreKit.
final class Store: NSObject, ObservableObject {
	// MARK: - Properties
	/// An array containing all `Tips` products.
	@Published private(set) var tips: [Product] = []

	/// An array containing all `Subscription` products.
	@Published private(set) var subscriptions: [Product] = []

	/// An array containing all `Non-Consumable` products.
	@Published private(set) var nonConsumables: [Product] = []

	/// The set of pruchased product identifiers.
	@Published private(set) var purchasedIdentifiers = Set<String>()

	/// The transaction listener `Task` object.
	var updateListenerTask: Task<Void, Error>? = nil

	/// The dictionary containing all `StoreKit` products.
	private var products: [String: String] = [:]

	// MARK: - Initializers
	override init() {
		super.init()
		print("------ StoreKit 2 initialized.")
		print("------ Add SKPaymentQueue observer.")

		SKPaymentQueue.default().add(self)

//		#if DEBUG
//		if let path = Bundle.main.path(forResource: "Debug Products", ofType: "plist"),
//		   let plist = FileManager.default.contents(atPath: path) {
//			products = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
//		} else {
//			products = [:]
//		}
//		#else
		if let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			self.products = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
		} else {
			self.products = [:]
		}
//		#endif

		// Initialize empty products then do a product request asynchronously to fill them in.
		self.tips = []
		self.subscriptions = []
		self.nonConsumables = []

		// Start a transaction listener as close to app launch as possible so you don't miss any transactions.
		self.updateListenerTask = self.listenForTransactions()

		Task { [weak self] in
			guard let self = self else { return }
			// Initialize the store by starting a product request.
			await self.requestProducts()
		}
	}

	deinit {
		print("----- StoreKit 2 deinitialized.")
		self.updateListenerTask?.cancel()
	}

	// MARK: - Functions
	/// Start listening for `StoreKit` transactions.
	///
	/// - Returns: a `Task` that listenes to `StoreKit` transaction requests.
	func listenForTransactions() -> Task<Void, Error> {
		return Task.detached {
			// Iterate through any transactions which didn't come from a direct call to `purchase()`.
			for await result in Transaction.updates {
				do {
					let transaction = try self.checkVerified(result)

					// Deliver content to the user.
					await self.updatePurchasedIdentifiers(transaction)

					// Always finish a transaction.
					await transaction.finish()
				} catch {
					// StoreKit has a receipt it can read but it failed verification. Don't deliver content to the user.
					print("----- Transaction failed verification")
				}
			}
		}
	}

	/// Request the list of purchasable products.
	@MainActor
	func requestProducts() async {
		do {
			// Request products from the App Store using the identifiers defined in the Products.plist file.
			let storeProducts = try await Product.products(for: products.keys)

			var newTips: [Product] = []
			var newSubscriptions: [Product] = []
			var newNonConsumables: [Product] = []

			// Filter the products into different categories based on their type.
			for product in storeProducts {
				switch product.type {
				case .consumable:
					newTips.append(product)
				case .autoRenewable:
					newSubscriptions.append(product)
				case .nonConsumable:
					newNonConsumables.append(product)
				default:
					// Ignore this product.
					print("----- Unknown product", product)
				}
			}

			// Sort each product category by price, lowest to highest, to update the store.
			self.tips = sortByPrice(newTips)
			self.subscriptions = sortByPrice(newSubscriptions)
			self.nonConsumables = sortByPrice(newNonConsumables)
		} catch {
			print("----- Failed product request: \(error)")
		}
	}

	func refreshReceipt() {
		let request = SKReceiptRefreshRequest(receiptProperties: nil)
		request.start()
	}

	/// Handles successful purchase transactions.
	fileprivate func handleSuccess(_ transaction: Transaction) async {
		// Deliver content to the user.
		await self.updatePurchasedIdentifiers(transaction)
		print("----- Deliver content for \(transaction.productID).")

		self.verifyReceipt()
	}

	/// Verifies the receipt using Kurozora API.
	func verifyReceipt() {
		self.refreshReceipt()

		// Get the receipt if it's available
		if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
		   FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
			do {
				let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
				let receiptString = receiptData.base64EncodedString(options: [])
				print("----- Receipt string:", receiptString)

				_ = KService.verifyReceipt(receiptString)

				NotificationCenter.default.post(name: .KSubscriptionStatusDidUpdate, object: nil)

				// Finish the successful transaction.
				print("----- Transaction verified.")
			} catch {
				print("----- Transaction NOT verified.")
				print("----- Couldn't read receipt data with error: " + error.localizedDescription)
			}
		} else {
			print("----- Receipt verification failed: App Store receipt not found.")
		}
	}

	/// Purchase a product.
	///
	/// - Parameter product: The product to be purchased.
	///
	/// - Returns: The transaction of the purchase if succeeded, otherwise `nil`.
	func purchase(_ product: Product) async throws -> Transaction? {
		// Begin a purchase.
		guard let userID = User.current?.uuid else { return nil }
		let result = try await product.purchase(options: [.appAccountToken(userID)])

		switch result {
		case .success(let verification):
			let transaction = try self.checkVerified(verification)

			// Handle success
			await self.handleSuccess(transaction)

			// Always finish a transaction.
			await transaction.finish()

			return transaction
		case .userCancelled, .pending:
			return nil
		default:
			return nil
		}
	}

	/// Restores the purchases of the user.
	///
	/// This call displays a system prompt that asks users to authenticate with their App Store credentials.
	///
	/// Call this function only in response to an explicit user action, such as tapping a button.
	func restore() async {
		do {
			try await AppStore.sync()

			self.verifyReceipt()
		} catch let error as KKAPIError {
			print("----- Restore failed", error.message)
		} catch {
			print("----- Restore failed", error.localizedDescription)
		}
	}

	#if !targetEnvironment(macCatalyst)
	/// Presents the user with the manage subscription view.
	///
	/// - Parameters:
	///    - windowScene: the scene on which the subscription view is presented.
	func manageSubscriptions(in windowScene: UIWindowScene?) async {
		guard let windowScene = windowScene else { return }
		try? await AppStore.showManageSubscriptions(in: windowScene)
	}
	#endif

	/// Indicates whether a product is purchased.
	///
	/// - Parameter productIdentifier: The identifier used to determin the product to be checked.
	///
	/// - Returns: a boolean indicating whether a product is purchased.
	func isPurchased(_ productIdentifier: String) async throws -> Bool {
		// Get the most recent transaction receipt for this `productIdentifier`.
		guard let result = await Transaction.latest(for: productIdentifier) else {
			// If there is no latest transaction, the product has not been purchased.
			return false
		}

		let transaction = try checkVerified(result)

		// Ignore revoked transactions, they're no longer purchased.

		// For subscriptions, a user can upgrade in the middle of their subscription period. The lower service
		// tier will then have the `isUpgraded` flag set and there will be a new transaction for the higher service
		// tier. Ignore the lower service tier transactions which have been upgraded.
		return transaction.revocationDate == nil && !transaction.isUpgraded
	}

	/// Checks whether the transaction passses StoreKit verification.
	///
	/// - Parameter result: The verification result.
	///
	/// - Returns: the result of the transaction verification check.
	func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
		// Check if the transaction passes StoreKit verification.
		switch result {
		case .unverified:
			// has failed.
			throw StoreError.failedVerification
		case .verified(let safe):
			// If the transaction is verified, unwrap and return it.
			return safe
		}
	}

	@MainActor
	func updatePurchasedIdentifiers(_ transaction: Transaction) async {
		if transaction.revocationDate == nil {
			// If the App Store has not revoked the transaction, add it to the list of `purchasedIdentifiers`.
			purchasedIdentifiers.insert(transaction.productID)
		} else {
			// If the App Store has revoked this transaction, remove it from the list of `purchasedIdentifiers`.
			purchasedIdentifiers.remove(transaction.productID)
		}
	}

	/// Returns the title of a product.
	///
	/// - Parameter productId: The id of the product used to determine the title.
	///
	/// - Returns: The product's title.
	func title(for productId: String) -> String {
		return self.products[productId]!
	}

	/// Returns the image of a product.
	///
	/// - Parameter productId: The id of the product used to determine the image.
	///
	/// - Returns: The product's image.
	func image(for productId: String) -> UIImage? {
		let product = self.title(for: productId)
		return product.toImage(withFrameSize: CGRect(x: 0, y: 0, width: 150, height: 150), backgroundColor: .secondaryLabel, fontSize: 40, placeholder: #imageLiteral(resourceName: "Icons/Tip Jar"))
	}

	/// How much money the user saves between subscription tiers.
	///
	/// - Parameter product: The object of the product used to compare the price with.
	///
	/// - Returns: a string indicating how much money the user saves between tiers.
	func saving(for product: Product) -> String {
		guard let subscription = product.subscription,
			  let firstProduct = store.subscriptions.first else {
			return ""
		}

		let subscriptionDescription: String = subscription.subscriptionPeriod.displayUnit + " at " + product.displayPricePerMonth + "mo. Save " + product.priceSaved(comparedTo: firstProduct.pricePerMonth)

		// If it has an introduction price. For example a week of trial period.
		if let introductoryOffer = product.subscription?.introductoryOffer {
			let subscriptionPeriod = introductoryOffer.period.displayUnit
			let subscriptionTrialPeriod = "Includes " + subscriptionPeriod + " free trial!"

			if self.tier(for: product.id) == .plus1Month {
				return subscriptionTrialPeriod
			} else {
				return """
				\(subscriptionTrialPeriod)
				(\(subscriptionDescription))
				"""
			}
		}

		return ""
	}

	/// Sorts the products in place, using the price as predicate for the comparison between the products.
	///
	/// - Parameter products: The products to sort by price.
	func sortedByPrice(_ products: inout [Product]) {
		products.sort(by: { return $0.price < $1.price })
	}

	/// Returns the products, using the price as predicate for the comparison between the products.
	///
	/// - Parameter products: The products to sort by price.
	///
	/// - Returns: a sorted array of the products.
	func sortByPrice(_ products: [Product]) -> [Product] {
		products.sorted(by: { return $0.price < $1.price })
	}

	/// Returns a `SubscriptionTier` object using the given product id.
	///
	/// - Parameter productID: The id of the product used to determine the subscription tier.
	///
	/// - Returns: a `SubscriptionTier` object.
	func tier(for productID: String) -> SubscriptionTier {
//		#if DEBUG
//		switch productID {
//		case "app.kurozora.temporary.kurozoraPlus1Month":
//			return .plus1Month
//		case "app.kurozora.temporary.kurozoraPlus6Months":
//			return .plus6Months
//		case "app.kurozora.temporary.kurozoraPlus12Months":
//			return .plus12Months
//		default:
//			return .none
//		}
//		#else
		switch productID {
		case "app.kurozora.autoRenewableSubscription.kPlus1Month":
			return .plus1Month
		case "app.kurozora.autoRenewableSubscription.kPlus6Months":
			return .plus6Months
		case "app.kurozora.autoRenewableSubscription.kPlus12Months":
			return .plus12Months
		default:
			return .none
		}
//		#endif
	}
}

// MARK: - SKPaymentTransactionObserver
extension Store: SKPaymentTransactionObserver {
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .purchasing:
				// Do not block your UI. Allow the user to continue using your app.
				print("----- Transaction in progress: \(transaction)")
			case .deferred:
				// Do not block your UI. Allow the user to continue using your app.
				print("----- Transaction deferred: \(transaction)")
			case .purchased:
				// The purchase was successful.
				print("----- Transaction purchased: \(transaction)")
				self.verifyReceipt()
				queue.finishTransaction(transaction)
			case .restored:
				print("----- Transaction restore: \(transaction)")
				self.verifyReceipt()
				queue.finishTransaction(transaction)
			case .failed:
				print("----- Transaction failed: \(transaction)")
				queue.finishTransaction(transaction)
			@unknown default:
				queue.finishTransaction(transaction)
			}
		}
	}

	func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			print("----- \(transaction.payment.productIdentifier) was removed from the payment queue.")
		}
	}

	func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
		return AppStore.canMakePayments
	}
}
