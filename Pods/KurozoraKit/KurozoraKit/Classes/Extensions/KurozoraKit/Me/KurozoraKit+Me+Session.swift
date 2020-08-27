//
//  KurozoraKit+Session.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the list of sessions for the authenticated user.

		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getSessions(next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<SessionResponse, KKAPIError>) -> Void) {
		let meSessionsIndex = next ?? KKEndpoint.Me.Sessions.index.endpointValue
		let request: APIRequest<SessionResponse, KKAPIError> = tron.codable.request(meSessionsIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { sessionResponse in
			completionHandler(.success(sessionResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get session 😔", subTitle: error.message)
			}
			print("Received get session error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the session details for the given session id.

		- Parameter sessionID: The id of the session for which the details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forSessionID sessionID: Int, completion completionHandler: @escaping (_ result: Result<[Session], KKAPIError>) -> Void) {
		let meSessionsDetail = KKEndpoint.Me.Sessions.details(sessionID).endpointValue
		let request: APIRequest<SessionResponse, KKAPIError> = tron.codable.request(meSessionsDetail)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { sessionResponse in
			completionHandler(.success(sessionResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get session details 😔", subTitle: error.message)
			}
			print("❌ Received get session details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Update a session with the specified data.

		- Parameter sessionID: The ID of the session whose data should be updated.
		- Parameter apnDeviceToken: The updated APN Device Token.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func updateSession(_ sessionID: Int, withToken apnDeviceToken: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let meSessionsUpdate = KKEndpoint.Me.Sessions.update(sessionID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meSessionsUpdate)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.parameters = [
			"apn_device_token": apnDeviceToken
		]
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
//			if self.services.showAlerts {
//				SCLAlertView().showError("Can't update session 😔", subTitle: error.message)
//			}
			print("❌ Received update session error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Delete the specified session ID from the user's active sessions.

		- Parameter sessionID: The session ID to be deleted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func deleteSession(_ sessionID: Int, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let meSessionsDelete = KKEndpoint.Me.Sessions.delete(sessionID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meSessionsDelete)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't delete session 😔", subTitle: error.message)
			}
			print("❌ Received delete session error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Sign out the given user session.

		After the user has been signed out successfully, a notification with the `KUserIsSignedInDidChange` name is posted.
		This notification can be observed to perform UI changes regarding the user's sign in status. For example you can remove buttons the user should not have access to if not signed in.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func signOut(completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		guard let sessionID = User.current?.relationships?.sessions?.data.first?.id else {
			fatalError("User must be signed in and have a session attached to call the signOut(completion:) method.")
		}
		let meSessionsDelete = KKEndpoint.Me.Sessions.delete(sessionID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(meSessionsDelete)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.perform(withSuccess: { success in
			User.current = nil
			completionHandler(.success(success))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't sign out 😔", subTitle: error.message)
			}
			print("❌ Received sign out error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
