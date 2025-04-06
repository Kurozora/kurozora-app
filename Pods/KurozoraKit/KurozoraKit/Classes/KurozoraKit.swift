//
//  KurozoraKit.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 11/07/2018.
//

import Alamofire
import TRON

/// `KurozoraKit` is a root object that serves as a provider for single API endpoint. It is used to send and get data from [Kurozora](https://kurozora.app).
///
/// For more flexibility when using `KurozoraKit` you can provide your own endpoint using ``KurozoraAPI``.
/// You can also provide your own ``KKServices``. This enables you to provide extra functionality such as storing sensetive information in `Keychain`.
/// For further control over the information saved in `Keychain`, you can provide your own `Keychain` object with your specified properties.
///
/// - Tag: KurozoraKit
public class KurozoraKit {
	// MARK: - Properties
	/// Storage of the app's api key.
	internal var _apiKey: String = ""
	/// The current app's api key.
	public var apiKey: String {
		get {
			return self._apiKey
		}
		set {
			self._apiKey = newValue
		}
	}

	/// Storage of the current user's authentication key.
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

	/// Storage of the current API endpoint.
	internal var _apiEndpoint: KurozoraAPI = .v1
	/// The current API Endpoint.
	public var apiEndpoint: KurozoraAPI {
		get {
			return self._apiEndpoint
		}
		set {
			self._apiEndpoint = newValue
		}
	}

	/// Most common HTTP headers for the Kurozora API.
	///
	/// Current headers are:
	/// ```
	/// "Content-Type": "application/x-www-form-urlencoded",
	/// "Accept": "application/json"
	/// ```
	internal let headers: HTTPHeaders

	/// The TRON singleton used to perform API requests.
	internal var tron: TRON!

	/// The ``KKServices`` object used to perform API requests.
	public var services: KKServices!

	// MARK: - Initializers
	/// Initializes `KurozoraKit` with the given API endpoint, user authentication key and services.
	///
	/// - Parameters:
	///    - apiEndpoint: The ``KurozoraAPI`` endpoint to be used.
	///    - authenticationKey: The current signed in user's authentication key.
	///    - services: The desired ``KKServices`` to be used.
	public init(apiEndpoint: KurozoraAPI? = nil, apiKey: String = "", authenticationKey: String = "", services: KKServices = KKServices()) {
		self.headers = [
			.contentType("application/x-www-form-urlencoded"),
			.accept("application/json"),
			.init(name: "X-API-Key", value: apiKey)
		]

		self.apiEndpoint(apiEndpoint ?? .v1)
			.apiKey(apiKey)
			.authenticationKey(authenticationKey)
			.services(services)
	}

	// MARK: - Functions
	/// Sets the API endpoint for the Kurozora API.
	///
	/// - Parameter apiEndpoint: The desired ``KurozoraAPI`` endpoint to be used.
	///
	/// - Returns: Reference to `self`.
	@discardableResult
	public func apiEndpoint(_ apiEndpoint: KurozoraAPI) -> Self {
		let plugins: [Plugin] = switch apiEndpoint {
		case .v1:
			[]
		case .custom(_, let plugin):
			plugin ?? [NetworkLoggerPlugin()]
		}

		self.apiEndpoint = apiEndpoint
		self.tron = TRON(baseURL: apiEndpoint.baseURL, plugins: plugins)
		self.tron.codable.modelDecoder.dateDecodingStrategy = .secondsSince1970

		return self
	}

	/// Sets the `apiKey` property with the given auth key.
	///
	/// - Parameter apiKey: The current user's authentication key.
	///
	/// - Returns: Reference to `self`.
	@discardableResult
	public func apiKey(_ apiKey: String) -> Self {
		self.apiKey = apiKey
		return self
	}


	/// Sets the `authenticationKey` property with the given auth key.
	///
	/// - Parameter authenticationKey: The current user's authentication key.
	///
	/// - Returns: Reference to `self`.
	@discardableResult
	public func authenticationKey(_ authenticationKey: String) -> Self {
		self.authenticationKey = authenticationKey
		return self
	}

	/// Sets the `services` property with the given ``KKServices`` object.
	///
	/// - Parameter services: The ``KKServices`` object to be used when performin API requests.
	///
	/// - Returns: Reference to `self`.
	@discardableResult
	public func services(_ services: KKServices) -> Self {
		self.services = services
		return self
	}
}
