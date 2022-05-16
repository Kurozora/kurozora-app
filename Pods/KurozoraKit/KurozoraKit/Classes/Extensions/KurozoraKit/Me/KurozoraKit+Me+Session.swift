//
//  KurozoraKit+Session.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of sessions for the authenticated user.
	///
	/// - Parameters:
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getSessions(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<SessionResponse, KKAPIError>) -> Void) {
		let meSessionsIndex = next ?? KKEndpoint.Me.Sessions.index.endpointValue
		let request: APIRequest<SessionResponse, KKAPIError> = tron.codable.request(meSessionsIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { sessionResponse in
			completionHandler(.success(sessionResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Sessions 😔", message: error.message)
			}
			print("Received get session error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the session details for the given session id.
	///
	/// - Parameters:
	///    - sessionID: The id of the session for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getDetails(forSessionID sessionID: String, completion completionHandler: @escaping (_ result: Result<[Session], KKAPIError>) -> Void) {
		let meSessionsDetail = KKEndpoint.Me.Sessions.details(sessionID).endpointValue
		let request: APIRequest<SessionResponse, KKAPIError> = tron.codable.request(meSessionsDetail)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { sessionResponse in
			completionHandler(.success(sessionResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Session's Details 😔", message: error.message)
			}
			print("❌ Received get session details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Delete the specified session ID from the user's active sessions.
	///
	/// - Parameters:
	///    - sessionID: The session ID to be deleted.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func deleteSession(_ sessionID: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let meSessionsDelete = KKEndpoint.Me.Sessions.delete(sessionID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meSessionsDelete)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Delete Session 😔", message: error.message)
			}
			print("❌ Received delete session error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
