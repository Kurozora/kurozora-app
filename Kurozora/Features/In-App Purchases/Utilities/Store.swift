//
//  Store.swift
//  Store
//
//  Created by Khoren Katklian on 14/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
	case failedVerification
}

public enum SubscriptionTier: Int, Comparable {
	case none = 0
	case plus1Month = 1
	case plus6Months = 2
	case plus12Months = 3

	public static func < (lhs: Self, rhs: Self) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}

final class Store: ObservableObject {
	@Published private(set) var tips: [Product]
	@Published private(set) var subscriptions: [Product]
	@Published private(set) var purchasedIdentifiers = Set<String>()

	var updateListenerTask: Task<Void, Error>? = nil

	private let products: [String: String]

	private static let subscriptionTier: [String: SubscriptionTier] = [
		"app.kurozora.temporary.kurozoraPlus1Month": .plus1Month,
		"app.kurozora.temporary.kurozoraPlus6Months": .plus6Months,
		"app.kurozora.temporary.kurozoraPlus12Months": .plus12Months
	]

	init() {
		print("------ StoreKit 2 initialized.")
		if let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			products = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
		} else {
			products = [:]
		}

		// Initialize empty products then do a product request asynchronously to fill them in.
		tips = []
		subscriptions = []

		// Start a transaction listener as close to app launch as possible so you don't miss any transactions.
		updateListenerTask = listenForTransactions()

		Task {
			// Initialize the store by starting a product request.
			await requestProducts()
		}
	}

	deinit {
		print("----- StoreKit 2 deinitialized.")
		updateListenerTask?.cancel()
	}

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
					print("Transaction failed verification")
				}
			}
		}
	}

	@MainActor
	func requestProducts() async {
		do {
			// Request products from the App Store using the identifiers defined in the Products.plist file.
			let storeProducts = try await Product.products(for: products.keys)

			var newTips: [Product] = []
			var newSubscriptions: [Product] = []

			// Filter the products into different categories based on their type.
			for product in storeProducts {
				switch product.type {
				case .consumable:
					newTips.append(product)
				case .autoRenewable:
					newSubscriptions.append(product)
				default:
					// Ignore this product.
					print("Unknown product")
				}
			}

			// Sort each product category by price, lowest to highest, to update the store.
			tips = sortByPrice(newTips)
			subscriptions = sortByPrice(newSubscriptions)
		} catch {
			print("Failed product request: \(error)")
		}
	}

	func purchase(_ product: Product) async throws -> Transaction? {
		// Begin a purchase.
		let result = try await product.purchase()

		switch result {
		case .success(let verification):
			let transaction = try checkVerified(verification)

			// Deliver content to the user.
			await updatePurchasedIdentifiers(transaction)

			// Always finish a transaction.
			await transaction.finish()

			return transaction
		case .userCancelled, .pending:
			return nil
		default:
			return nil
		}
	}

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

	func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
		// Check if the transaction passes StoreKit verification.
		switch result {
		case .unverified:
			// StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
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

	func image(for productId: String) -> String {
		return products[productId]!
	}

	func sortByPrice(_ products: [Product]) -> [Product] {
		products.sorted(by: { return $0.price < $1.price })
	}

	func tier(for productId: String) -> SubscriptionTier {
		switch productId {
		case "app.kurozora.temporary.kurozoraPlus1Month":
			return .plus1Month
		case "app.kurozora.temporary.kurozoraPlus6Months":
			return .plus6Months
		case "app.kurozora.temporary.kurozoraPlus12Months":
			return .plus12Months
		default:
			return .none
		}
	}
}
