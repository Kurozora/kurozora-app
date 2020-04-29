//
//  KurozoraKit+Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Create a new session with the given `kurozoraID` and `password`.

		This endpoint is used for signing in a user to their account. If the sign in was successful then a Kurozora authentication token is returned in the success closure.

		- Parameter kurozoraID: The Kurozora id of the user to be signed in.
		- Parameter password: The password of the user to be signed in.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func signIn(_ kurozoraID: String, _ password: String, completion completionHandler: @escaping (_ result: Result<String, KKError>) -> Void) {
		let sessions = self.kurozoraKitEndpoints.sessions
		let request: APIRequest<User, KKError> = tron.swiftyJSON.request(sessions)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": kurozoraID,
			"password": password,
			"platform": UIDevice.commonSystemName,
			"platform_version": UIDevice.current.systemVersion,
			"device_vendor": "Apple",
			"device_model": UIDevice.modelName
		]

		request.perform(withSuccess: { user in
			self.authenticationKey = user.kuroAuthToken ?? ""
			completionHandler(.success(self.authenticationKey))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't sign in 😔", subTitle: error.message)
			}
			print("Received sign in error: \(error.message ?? "No message available")")
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
	public func updateSession(_ sessionID: Int, withToken apnDeviceToken: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let sessionsUpdate = self.kurozoraKitEndpoints.sessionsUpdate.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(sessionsUpdate)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

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
			print("Received update session error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Delete the specified session ID from the user's active sessions.

		- Parameter sessionID: The session ID to be deleted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func deleteSession(_ sessionID: Int, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let sessionsDelete = self.kurozoraKitEndpoints.sessionsDelete.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(sessionsDelete)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't delete session 😔", subTitle: error.message)
			}
			print("Received delete session error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Sign out the given user session.

		After the user has been signed out successfully, a notification with the `KUserIsSignedInDidChange` name is posted.
		This notification can be observed to perform UI changes regarding the user's sign in status. For example you can remove buttons the user should not have access to if not signed in.

		- Parameter sessionID: The session ID to be signed out of.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func signOut(ofSessionID sessionID: Int, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKError>) -> Void) {
		let sessionsDelete = self.kurozoraKitEndpoints.sessionsDelete.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<KKSuccess, KKError> = tron.swiftyJSON.request(sessionsDelete)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.perform(withSuccess: { success in
			User.current = nil
			completionHandler(.success(success))
			NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't sign out 😔", subTitle: error.message)
			}
			print("Received sign out error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
