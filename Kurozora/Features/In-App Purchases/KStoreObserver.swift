//
//  KStoreObserver.swift
//  Kurozora
//
//  Created by Khoren Katklian on 03/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

protocol KStoreObserverDelegate: AnyObject {
	/// Tells the delegate that the restore operation was successful.
	func storeObserverRestoreDidSucceed()

	/// Provides the delegate with messages.
	func storeObserverDidReceiveMessage(_ message: String)
}

class KStoreObserver: NSObject {
	//MARK:- Shared Object
	static let shared = KStoreObserver()
	private override init() { }

	//MARK:- Properties
	fileprivate var productIDs = [String]()
	fileprivate var productID = ""
	fileprivate var iapProducts = [SKProduct]()
	fileprivate var productsRequest = SKProductsRequest()
	fileprivate var fetchProductComplition: (([SKProduct]) -> Void)?

	fileprivate var productToPurchase: SKProduct?
	fileprivate var purchaseProductComplition: ((AlertType, SKProduct?, SKPaymentTransaction?) -> Void)?

	/// Indicates whether there are restorable purchases.
	fileprivate var hasRestorablePurchases = false

	/// Keeps track of all purchases.
	var purchased = [SKPaymentTransaction]()

	/// Keeps track of all restored purchases.
	var restored = [SKPaymentTransaction]()

	/// Returns a boolean indicating whehter the user can make purchases.
	var isAuthorizedForPayments: Bool {
		return SKPaymentQueue.canMakePayments()
	}

	weak var delegate: KStoreObserverDelegate?

	/// Indicates whether payment actions should be logged.
	#if DEBUG
	var isLogEnabled: Bool = true
	#else
	var isLogEnabled: Bool = false
	#endif

	//MARK: - Functions
	/// Sets the product ids.
	func setProductIDs(ids: [String]) {
		self.productIDs = ids
	}

	/// Makes the purchase of the selected item.
	func purchase(product: SKProduct, withComplition complition:@escaping ((AlertType, SKProduct?, SKPaymentTransaction?) -> Void)) {
		self.purchaseProductComplition = complition
		self.productToPurchase = product

		if self.isAuthorizedForPayments {
			let payment = SKPayment(product: product)
			SKPaymentQueue.default().add(payment)

			log("PRODUCT TO PURCHASE: \(product.productIdentifier)")
			productID = product.productIdentifier
		} else {
			complition(AlertType.disabled, nil, nil)
		}
	}

	/// Restores all previously completed purchases.
	func restorePurchase() {
		if !restored.isEmpty {
			restored.removeAll()
		}
		SKPaymentQueue.default().restoreCompletedTransactions()
	}

	/// Fetches available IAP products.
	func fetchAvailableProducts(withComplition complition:@escaping (([SKProduct]) -> Void)) {
		self.fetchProductComplition = complition

		if self.productIDs.isEmpty {
			log(AlertType.setProductIDs.message)
			fatalError(AlertType.setProductIDs.message)
		} else {
			productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIDs))
			productsRequest.delegate = self
			productsRequest.start()
		}
	}

	/// Handles successful purchase transactions.
	fileprivate func handlePurchased(_ transaction: SKPaymentTransaction) {
		purchased.append(transaction)
		log("Deliver content for \(transaction.payment.productIdentifier).")

		// Finish the successful transaction.
		SKPaymentQueue.default().finishTransaction(transaction)
	}

	func handleFailed(_ transaction: SKPaymentTransaction) {
		log("Product purchase failed")
		/// Handles failed purchase transactions.
		var message = "Purchase of \(transaction.payment.productIdentifier) failed."

		if let error = transaction.error {
			message += "\nError: \(error.localizedDescription)"
			print("Error: \(error.localizedDescription)")
		}

		// Do not send any notifications when the user cancels the purchase.
		if (transaction.error as? SKError)?.code != .paymentCancelled {
			DispatchQueue.main.async {
				self.delegate?.storeObserverDidReceiveMessage(message)
			}
		}
		// Finish the failed transaction.
		SKPaymentQueue.default().finishTransaction(transaction)
	}

	/// Handles restored purchase transactions.
	fileprivate func handleRestored(_ transaction: SKPaymentTransaction) {
		hasRestorablePurchases = true
		restored.append(transaction)
		log("Restore content for \(transaction.payment.productIdentifier).")

		DispatchQueue.main.async {
			self.delegate?.storeObserverRestoreDidSucceed()
		}
		// Finishes the restored transaction.
		SKPaymentQueue.default().finishTransaction(transaction)
	}

	/// Custom print function. Prints only when `isLogEnabled` is `true`.
	fileprivate func log<T>(_ object: T) {
		if isLogEnabled {
			print("\(object)")
		}
	}
}

//MARK:- SKProductsRequestDelegate
extension KStoreObserver: SKProductsRequestDelegate {
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		if response.products.count > 0 {
			iapProducts = response.products

			if let complition = self.fetchProductComplition {
				complition(response.products)
			}
		}
	}
}

// MARK: - SKPaymentTransactionObserver
extension KStoreObserver: SKPaymentTransactionObserver {
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .purchasing: break
			case .deferred:
				// Do not block your UI. Allow the user to continue using your app.
				log("Transaction in progress: \(transaction)")
			case .purchased:
				// The purchase was successful.
				handlePurchased(transaction)
			case .restored:
				handleRestored(transaction)
			case .failed:
				handleFailed(transaction)
			@unknown default: fatalError("Unknown payment transaction case.")
			}
		}
	}

	#if !targetEnvironment(macCatalyst)
	func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
		if let purchaseTableViewController = PurchaseTableViewController.instantiateFromStoryboard() {
			UIApplication.shared.keyWindow?.rootViewController?.present(purchaseTableViewController)
		}

		return true
	}
	#endif

	func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
		if let error = error as? SKError, error.code != .paymentCancelled {
			DispatchQueue.main.async {
				self.delegate?.storeObserverDidReceiveMessage(error.localizedDescription)
			}
		}
	}

	func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			log("\(transaction.payment.productIdentifier) was removed from the payment queue.")
		}
	}

	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		log("All restorable transactions have been processed by the payment queue.")

		if !hasRestorablePurchases {
			if let complition = self.purchaseProductComplition {
				complition(AlertType.restored, nil, nil)
			}
		}
	}
}

// MARK: - AlertType
extension KStoreObserver {
	enum AlertType {
		case setProductIDs
		case disabled
		case restored

		/// The message linked to an alert type.
		var message: String {
			switch self {
			case .setProductIDs:
				return "Product ids not set, call setProductIDs method!"
			case .disabled:
				return "You are not authorized to make payments. In-App Purchases may be restricted on your device."
			case .restored:
				return "There are no restorable purchases.\nOnly previously bought non-consumable products and auto-renewable subscriptions can be restored.!"
			}
		}
	}
}
