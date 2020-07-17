//
//  WorkflowController+User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit

// MARK: - User
extension WorkflowController {
	/**
		Repopulates the current user's data.

		This method can be used to restore the current user's data after the app has been completely closed.
	*/
	func restoreCurrentUserSession() {
		let accountKey = UserSettings.selectedAccount
		if let authenticationKey = Kurozora.shared.keychain[accountKey] {
			DispatchQueue.global(qos: .background).async {
				KService.restoreDetails(forUserWith: authenticationKey) { result in
					switch result {
					case .success(let newAuthenticationKey):
						try? Kurozora.shared.keychain.set(newAuthenticationKey, key: accountKey)
					case .failure:
						try? Kurozora.shared.keychain.remove(accountKey)
					}
				}
			}
		}
	}
}
