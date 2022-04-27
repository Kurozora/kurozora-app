//
//  ServiceHeaderString.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/// Set of available service header strings.
///
/// - Tag: ServiceHeaderString
struct ServiceHeaderString {
	/// The headline string for the MAL Improt view.
	static let malImportHeadline: String = "Move from MyAnimeList"
	/// The subhead string for the MAL Improt view.
	static let malImportSubhead: String = "If you have an export of your anime library from MyAnimeList you can select it below."

	/// The headline string for the Redeem view.
	static let redeemHeadline: String = "Redeem your code using the camera on your device."
	/// The subhead string for the Redeem view.
	static let redeemSubhead: String = "Found a Kurozora code in the wild? This is the place to redeem it!"

	/// The headline string for the Sign in with Apple view.
	static let signInWithAppleHeadline: String = "Start using Sign in with Apple"
	/// The subhead string for the Sign in with Apple view.
	static let signInWithAppleSubhead: String = "Sign in with Apple is the fast, easy way for you to sign in to Kurozora using the Apple ID you already have."
}
