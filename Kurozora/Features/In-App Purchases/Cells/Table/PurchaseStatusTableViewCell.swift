//
//  PurchaseStatusTableViewCell.swift
//  PurchaseStatusTableViewCell
//
//  Created by Khoren Katklian on 25/08/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseStatusTableViewCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var purchaseStatusLabel: KLabel!

	// MARK: - Properties
	var product: Product!
	var status: Product.SubscriptionInfo.Status! {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		self.purchaseStatusLabel.text = self.statusDescription()
	}

	// Build a string description of the subscription status to display to the user.
	fileprivate func statusDescription() -> String {
		guard case .verified(let renewalInfo) = status.renewalInfo,
			  case .verified(let transaction) = status.transaction else {
				  return "The App Store could not verify your subscription status."
			  }

		var description = ""

		switch status.state {
		case .subscribed:
			description = subscribedDescription()
		case .expired:
			if let expirationDate = transaction.expirationDate,
			   let expirationReason = renewalInfo.expirationReason {
				description = expirationDescription(expirationReason, expirationDate: expirationDate)
			}
		case .revoked:
			if let revokedDate = transaction.revocationDate {
				description = "The App Store refunded your subscription to \(product.displayName) on \(revokedDate.formatted(date: .abbreviated, time: .omitted))."
			}
		case .inGracePeriod:
			description = gracePeriodDescription(renewalInfo)
		case .inBillingRetryPeriod:
			description = billingRetryDescription()
		default:
			break
		}

		if let expirationDate = transaction.expirationDate {
			description += renewalDescription(renewalInfo, expirationDate)
		}
		return description
	}

	fileprivate func billingRetryDescription() -> String {
		var description = "The App Store could not confirm your billing information for \(product.displayName)."
		description += " Please verify your billing information to resume service."
		return description
	}

	fileprivate func gracePeriodDescription(_ renewalInfo: RenewalInfo) -> String {
		var description = "The App Store could not confirm your billing information for \(product.displayName)."
		if let untilDate = renewalInfo.gracePeriodExpirationDate {
			description += " Please verify your billing information to continue service after \(untilDate.formatted(date: .abbreviated, time: .omitted))"
		}

		return description
	}

	fileprivate func subscribedDescription() -> String {
		return "You are currently subscribed to \(product.displayName)."
	}

	fileprivate func renewalDescription(_ renewalInfo: RenewalInfo, _ expirationDate: Date) -> String {
		var description = ""

		if let newProductID = renewalInfo.autoRenewPreference {
			if let newProduct = store.subscriptions.first(where: { $0.id == newProductID }) {
				description += "\nYour subscription to \(newProduct.displayName)"
				description += " will begin when your current subscription expires on \(expirationDate.formatted(date: .abbreviated, time: .omitted))."
			}
		} else if renewalInfo.willAutoRenew {
			description += "\nNext billing date: \(expirationDate.formatted(date: .abbreviated, time: .omitted))."
		}

		return description
	}

	// Build a string description of the `expirationReason` to display to the user.
	fileprivate func expirationDescription(_ expirationReason: RenewalInfo.ExpirationReason, expirationDate: Date) -> String {
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
