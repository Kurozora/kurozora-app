//
//  KurozoraKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Alamofire
import KeychainAccess
import TRON

public struct KurozoraKit {
	// MARK: - Properties
	/// The current user's authentication token.
	internal var _userAuthToken: String = ""

	/// The current user's authentication token.
	public var userAuthToken: String? {
		get {
			fatalError("Access to authentication token denied.")
		}
		set {
			guard let newValue = newValue else { return }
			_userAuthToken = newValue
		}
	}

	/// The app's identifier prefix.
	internal let appIdentifierPrefix = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as! String

	/// A collection of Kurozora API endpoints.
	internal let kurozoraKitEndpoints: KurozoraKitEndpoints = KurozoraKitEndpoints()

	/**
		Most common HTTP headers for the Kurozora API.

		Current headers are:
		```
		"Content-Type": "application/x-www-form-urlencoded",
		"Accept": "application/json"
		```
	*/
	internal let headers: HTTPHeaders = [
		"Content-Type": "application/x-www-form-urlencoded",
		"Accept": "application/json"
	]

	/// The TRON singleton used to perform API requests.
	internal let tron = TRON(baseURL: "https://kurozora.app/api/v1/", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])

	// MARK: - Initializers
	/**
		Initializes `KurozoraKit` with the given user authentication key and Keychain access group.

		- Parameter authenticationKey: The current signed in user's authentication key.
		- Parameter accessGroup: The keychain group to which the app belongs.
	*/
	public init(authenticationKey: String? = nil, accessGroup: String? = nil) {
		print("----- App Identifier Prefix: ", appIdentifierPrefix)
		let accessGroup = accessGroup ?? "\(appIdentifierPrefix)app.kurozora.shared"

		self.userAuthToken = authenticationKey
		KKServices.shared.KeychainDefaults = Keychain(service: "Kurozora", accessGroup: accessGroup).synchronizable(true).accessibility(.afterFirstUnlock)
	}
}

let kurozoraKit = KurozoraKit(authenticationKey: "edc954868bb006959e45", accessGroup: "")
