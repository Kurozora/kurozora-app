//
//  AlertType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

extension KStoreObserver {
	/// List of available alert types.
	enum AlertType {
		case setProductIDs
		case disabled
		case restoreFailed
		case restoreSucceeded

		/// The message linked to an alert type.
		var message: String {
			switch self {
			case .setProductIDs:
				return "Product ids not set, call setProductIDs method!"
			case .disabled:
				return "You are not authorized to make payments. In-App Purchases may be restricted on your device."
			case .restoreFailed:
				return "There are no restorable purchases.\nOnly previously bought non-consumable products and auto-renewable subscriptions can be restored."
			case .restoreSucceeded:
				return "All purchases have been restored.\nPlease remember that only previously bought non-consumable products and auto-renewable subscriptions can be restored."
			}
		}
	}
}
