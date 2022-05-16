//
//  OAuthAction.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/08/2020.
//

import Foundation

/// The set of available OAuth action types.
public enum OAuthAction: String, Codable {
	// MARK: - Cases
	/// The next action should be to sign in.
	case signIn = "signIn"

	/// The next action should be to setup the account.
	case setupAccount = "setupAccount"
}
