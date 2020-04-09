//
//  KurozoraKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Alamofire
import TRON

/**
	`KurozoraKit` is a root object that serves as a provider for single API endpoint. It is used to send and get data from [Kurozora](https://kurozora.app).

	For more flexibility when using `KurozoraKit` you can provide your own [KKServices](x-source-tag://KKServices). This enables you to provide extra functionality such as storing sensetive information in `Keychain` and showing success/error alerts.
	For further control over the information saved in `Keychain`, you can provide your own `Keychain` object with your specified properties.

	- Tag: KurozoraKit
*/
public class KurozoraKit {
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

	/// The [KKServices](x-source-tag://KKServices) object used to perform API requests.
	public var services: KKServices!

	// MARK: - Initializers
	/**
		Initializes `KurozoraKit` with the given user authentication key and services.

		- Parameter authenticationKey: The current signed in user's authentication key.
		- Parameter services: The desired [KKServices](x-source-tag://KKServices) to be used.
	*/
	public init(authenticationKey: String? = nil, services: KKServices = KKServices()) {
		self.userAuthToken = authenticationKey
		self.services = services
	}

	// MARK: - Functions
	/**
		Sets the `authenticationKey` property with the given auth key.

		- Parameter authKey: The current user's authentication token.

		- Returns: Reference to `self`.
	*/
	public func authenticationKey(_ authKey: String) -> KurozoraKit {
		self.userAuthToken = authKey
		return self
	}

	/**
		Sets the `services` property with the given [KKServices](x-source-tag://KKServices) object.

		- Parameter services: The [KKServices](x-source-tag://KKServices) object to be used when performin API requests.

		- Returns: Reference to `self`.
	*/
	public func services(_ services: KKServices) -> KurozoraKit {
		self.services = services
		return self
	}
}

//let appIdentifierPrefix = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as! String
//let keychain = Keychain(service: "AppName", accessGroup: "\(appIdentifierPrefix)com.company.shared").synchronizable(true).accessibility(.afterFirstUnlock)
//let services = KKServices()
//let kurozoraKit = KurozoraKit(authenticationKey: "bearer-token").services(services)
