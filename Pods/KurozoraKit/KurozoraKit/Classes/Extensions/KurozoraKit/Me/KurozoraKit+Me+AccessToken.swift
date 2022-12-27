//
//  KurozoraKit+AccessToken.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of access tokens for the authenticated user.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getTokens(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<AccessTokenResponse, KKAPIError>) -> Void) {
		let meAccessTokensIndex = next ?? KKEndpoint.Me.AccessTokens.index.endpointValue
		let request: APIRequest<AccessTokenResponse, KKAPIError> = tron.codable.request(meAccessTokensIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { accessTokenResponse in
			completionHandler(.success(accessTokenResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Access Tokens 😔", message: error.message)
			}
			print("❌ Received get access tokens error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the access token details for the given access token.
	///
	/// - Parameters:
	///    - accessToken: The access token for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getDetails(forAccessToken accessToken: String, completion completionHandler: @escaping (_ result: Result<[AccessToken], KKAPIError>) -> Void) {
		let tokenID = accessToken.components(separatedBy: "|")[0]
		let meAccessTokensDetail = KKEndpoint.Me.AccessTokens.details(tokenID).endpointValue
		let request: APIRequest<AccessTokenResponse, KKAPIError> = tron.codable.request(meAccessTokensDetail)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { accessTokenResponse in
			completionHandler(.success(accessTokenResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Access Token's Details 😔", message: error.message)
			}
			print("❌ Received get access token details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Update a access token with the specified data.
	///
	/// - Parameters:
	///    - apnDeviceToken: The updated APN Device Token.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func updateAccessToken(withAPNToken apnDeviceToken: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let tokenID = self.authenticationKey.components(separatedBy: "|")[0]
		let meAccessTokensUpdate = KKEndpoint.Me.AccessTokens.update(tokenID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meAccessTokensUpdate)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"apn_device_token": apnDeviceToken
		]
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			print("❌ Received update access token error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Delete the specified access token from the user's active access tokens.
	///
	/// - Parameters:
	///    - accessToken: The access token to be deleted.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func deleteAccessToken(_ accessToken: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let tokenID = accessToken.components(separatedBy: "|")[0]
		let meAccessTokensDelete = KKEndpoint.Me.AccessTokens.delete(tokenID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meAccessTokensDelete)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Delete Access Token 😔", message: error.message)
			}
			print("❌ Received delete access token error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Sign out the given user access token.
	///
	/// - Returns: An instance of `RequestSender` with the results of the sign out response.
	public func signOut() -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let meAccessTokensDelete = KKEndpoint.Me.AccessTokens.delete(self.authenticationKey).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meAccessTokensDelete)
			.method(.post)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
