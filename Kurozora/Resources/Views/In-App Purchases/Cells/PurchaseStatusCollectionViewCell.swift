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
	@IBOutlet weak var purchaseStatusLabel: KLabel!

	// MARK: - Functions
	func configureCell(using product: Product?, status: Product.SubscriptionInfo.Status?) {
		guard let product = product, let status = status else {
			return
		}

		self.purchaseStatusLabel.text = self.description(for: product, status: status)
	}

	/// Build a string description of the subscription status to display to the user.
	fileprivate func description(for product: Product, status: Product.SubscriptionInfo.Status) -> String {
		guard case .verified(let renewalInfo) = status.renewalInfo,
			  case .verified(let transaction) = status.transaction else {
			return "The App Store could not verify your subscription status."
		}

		var description = ""

		switch status.state {
		case .subscribed:
			description = self.subscribedDescription(for: product)
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
		default:
			break
		}

		if let expirationDate = transaction.expirationDate {
			description += self.renewalDescription(renewalInfo, expirationDate)
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

	fileprivate func subscribedDescription(for product: Product) -> String {
		return "You are currently subscribed to \(product.displayName)."
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
