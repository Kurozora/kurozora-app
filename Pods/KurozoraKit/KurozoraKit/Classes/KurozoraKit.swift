//
//  KurozoraKit.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 11/07/2018.
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
	/// Storage to the current user's authentication key.
	internal var _authenticationKey: String = ""
	/// The current user's authentication key.
	public var authenticationKey: String {
		get {
			return self._authenticationKey
		}
		set {
			self._authenticationKey = newValue
		}
	}

	/**
		Most common HTTP headers for the Kurozora API.

		Current headers are:
		```
		"Content-Type": "application/x-www-form-urlencoded",
		"Accept": "application/json"
		```
	*/
	internal let headers: HTTPHeaders = [
		.contentType("application/x-www-form-urlencoded"),
		.accept("application/json")
	]

	/// The TRON singleton used to perform API requests.
	internal let tron: TRON!

	/// The [KKServices](x-source-tag://KKServices) object used to perform API requests.
	public var services: KKServices!

	// MARK: - Initializers
	/**
		Initializes `KurozoraKit` with the given user authentication key and services.

		- Parameter debugURL: The backend API URL used for debugging.
		- Parameter authenticationKey: The current signed in user's authentication key.
		- Parameter services: The desired [KKServices](x-source-tag://KKServices) to be used.
	*/
	public init(debugURL: String? = nil, authenticationKey: String = "", services: KKServices = KKServices()) {
		let plugins: [Plugin] = debugURL != nil ? [NetworkLoggerPlugin()] : []

		self.tron = TRON(baseURL: debugURL ?? "https://api.kurozora.app/v1/", plugins: plugins)
		self.tron.codable.modelDecoder.dateDecodingStrategy = .secondsSince1970
		self.authenticationKey = authenticationKey
		self.services = services
	}

	// MARK: - Functions
	/**
		Sets the `authenticationKey` property with the given auth key.

		- Parameter authenticationKey: The current user's authentication key.

		- Returns: Reference to `self`.
	*/
	public func authenticationKey(_ authenticationKey: String) -> Self {
		self.authenticationKey = authenticationKey
		return self
	}

	/**
		Sets the `services` property with the given [KKServices](x-source-tag://KKServices) object.

		- Parameter services: The [KKServices](x-source-tag://KKServices) object to be used when performin API requests.

		- Returns: Reference to `self`.
	*/
	public func services(_ services: KKServices) -> Self {
		self.services = services
		return self
	}
}
