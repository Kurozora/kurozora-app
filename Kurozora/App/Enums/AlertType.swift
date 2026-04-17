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
		// MARK: - Cases
		/// Indicates that the product ID is not set.
		case setProductIDs

		/// Indicates that IAP is disabled.
		case disabled

		/// Indicates that the restoring IAP has failed.
		case restoreFailed

		/// Indicates that restoring IAP has succeeded.
		case restoreSucceeded

		// MARK: - Properties
		/// The message linked to an alert type.
		var message: String {
			switch self {
			case .setProductIDs:
				return L10n.productIDsNotSet
			case .disabled:
				return L10n.iapDisabled
			case .restoreFailed:
				return L10n.iapRestoreFailed
			case .restoreSucceeded:
				return L10n.iapRestoreSucceeded
			}
		}
	}
}
