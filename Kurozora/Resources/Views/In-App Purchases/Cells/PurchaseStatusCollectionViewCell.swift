//
//  PurchaseStatusCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseStatusCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var productImageView: UIImageView!
	@IBOutlet weak var productNameLabel: KLabel!
	@IBOutlet weak var priceImageView: UIImageView!
	@IBOutlet weak var priceLabel: KLabel!
	@IBOutlet weak var renewalStatusImageView: UIImageView!
	@IBOutlet weak var renewalStatusLabel: KLabel!
	@IBOutlet weak var purchaseStatusLabel: KLabel!

	// MARK: - Functions
	func configureCell(using product: Product?, status: Product.SubscriptionInfo.Status?) {
		// Configure cell
		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		// Configure accessories
		self.priceImageView.theme_tintColor = KThemePicker.textColor.rawValue
		self.renewalStatusImageView.theme_tintColor = KThemePicker.textColor.rawValue

		// Configure product details
		if let product = product, let status = status, let subscription = product.subscription {
			self.productImageView.image = #imageLiteral(resourceName: "Promotional/In App Purchases/Subscriptions/\(Store.shared.title(for: product.id))")
			self.productNameLabel.text = product.displayName
			self.priceLabel.text = "\(product.displayPrice) per \(subscription.subscriptionPeriod.displayUnit)"
			self.renewalStatusLabel.text = self.renewalDescription(for: product, status: status)
			self.purchaseStatusLabel.text = self.description(for: product, status: status)
		} else {
			self.productImageView.image = nil
			self.productNameLabel.text = "Unknown"
			self.priceLabel.text = "Unknown"
			self.renewalStatusLabel.text = "Unknown"
			self.purchaseStatusLabel.text = "Unknown"
		}
	}

	/// Get the renewal info and transaction from the subscription status.
	fileprivate func getRenewalInfoAndTransaction(from status: Product.SubscriptionInfo.Status) -> (Product.SubscriptionInfo.RenewalInfo, Transaction)? {
		guard case .verified(let renewalInfo) = status.renewalInfo,
			  case .verified(let transaction) = status.transaction else {
			return nil
		}

		return (renewalInfo, transaction)
	}

	/// Build a string description of the renewal status to display to the user.
	fileprivate func renewalDescription(for product: Product, status: Product.SubscriptionInfo.Status) -> String {
		guard let (_, transaction) = self.getRenewalInfoAndTransaction(from: status), let expirationDate = transaction.expirationDate else {
			return "Date unknown."
		}

		return "Renews \(expirationDate.formatted(date: .abbreviated, time: .omitted))"
	}

	/// Build a string description of the subscription status to display to the user.
	fileprivate func description(for product: Product, status: Product.SubscriptionInfo.Status) -> String {
		guard let (renewalInfo, transaction) = self.getRenewalInfoAndTransaction(from: status) else {
			return "The App Store could not verify your subscription status."
		}

		var description = ""

		switch status.state {
		case .subscribed: break
		case .expired:
			if let expirationDate = transaction.expirationDate,
			   let expirationReason = renewalInfo.expirationReason {
				description = self.expirationDescription(for: product, expirationReason: expirationReason, expirationDate: expirationDate)
			}
		case .revoked:
			if let revokedDate = transaction.revocationDate {
				description = "The App Store refunded your subscription to \(product.displayName) on \(revokedDate.formatted(date: .abbreviated, time: .omitted))."
			}
		case .inGracePeriod:
			description = self.gracePeriodDescription(for: product, renewalInfo: renewalInfo)
		case .inBillingRetryPeriod:
			description = self.billingRetryDescription(for: product)
		default: break
		}

		return description
	}

	fileprivate func billingRetryDescription(for product: Product) -> String {
		var description = "The App Store could not confirm your billing information for \(product.displayName)."
		description += " Please verify your billing information to resume service."
		return description
	}

	fileprivate func gracePeriodDescription(for product: Product, renewalInfo: RenewalInfo) -> String {
		var description = "The App Store could not confirm your billing information for \(product.displayName)."
		if let untilDate = renewalInfo.gracePeriodExpirationDate {
			description += " Please verify your billing information to continue service after \(untilDate.formatted(date: .abbreviated, time: .omitted))"
		}

		return description
	}

	fileprivate func renewalDescription(_ renewalInfo: RenewalInfo, _ expirationDate: Date) -> String {
		var description = ""

		if let newProductID = renewalInfo.autoRenewPreference {
			if let newProduct = Store.shared.subscriptions.first(where: { $0.id == newProductID }) {
				description += "\nYour subscription to \(newProduct.displayName)"
				description += " will begin when your current subscription expires on \(expirationDate.formatted(date: .abbreviated, time: .omitted))."
			}
		} else if renewalInfo.willAutoRenew {
			description += "\nNext billing date: \(expirationDate.formatted(date: .abbreviated, time: .omitted))."
		}

		return description
	}

	/// Build a string description of the `expirationReason` to display to the user.
	fileprivate func expirationDescription(for product: Product, expirationReason: RenewalInfo.ExpirationReason, expirationDate: Date) -> String {
		var description = ""

		switch expirationReason {
		case .autoRenewDisabled:
			if expirationDate > Date() {
				description += "Your subscription to \(product.displayName) will expire on \(expirationDate.formatted(date: .abbreviated, time: .omitted))."
			} else {
				description += "Your subscription to \(product.displayName) expired on \(expirationDate.formatted(date: .abbreviated, time: .omitted))."
			}
		case .billingError:
			description = "Your subscription to \(product.displayName) was not renewed due to a billing error."
		case .didNotConsentToPriceIncrease:
			description = "Your subscription to \(product.displayName) was not renewed due to a price increase that you disapproved."
		case .productUnavailable:
			description = "Your subscription to \(product.displayName) was not renewed because the product is no longer available."
		default:
			description = "Your subscription to \(product.displayName) was not renewed."
		}

		return description
	}
}
