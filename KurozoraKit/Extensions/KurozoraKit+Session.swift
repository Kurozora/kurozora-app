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
		Create a new session a.k.a sign in.

		- Parameter kurozoraID: The Kurozora id of the user to be signed in.
		- Parameter password: The password of the user to be signed in.
		- Parameter successHandler: A closure returning a boolean indicating whether sign in is successful.
		- Parameter isSuccess: A boolean value indicating whether sign in is successful.
	*/
	public func signIn(_ kurozoraID: String, _ password: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let sessions = self.kurozoraKitEndpoints.sessions
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request(sessions)
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

		request.perform(withSuccess: { userSession in
			if let success = userSession.success {
				if success {
//					try? Kurozora.shared.KDefaults.set(kurozoraID, key: "kurozora_id")
//					WorkflowController.shared.processUserData(fromSession: userSession)
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't sign in 😔", subTitle: error.message)
			print("Received sign in error: \(error.message ?? "No message available")")
			successHandler(false)
		})
	}

	/**
		Update a session with the specified data.

		- Parameter sessionID: The ID of the session whose data should be updated.
		- Parameter apnDeviceToken: The updated APN Device Token.
		- Parameter successHandler: A closure returning a boolean indicating whether session validation is successful.
		- Parameter isSuccess: A boolean value indicating whether session validation is successful.
	*/
	public func updateSession(_ sessionID: Int, withToken apnDeviceToken: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let sessionsUpdate = self.kurozoraKitEndpoints.sessionsUpdate.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request(sessionsUpdate)

		request.headers = headers
		if self._userAuthToken != "" {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"apn_device_token": apnDeviceToken
		]
		request.perform(withSuccess: { session in
			if let success = session.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
//			SCLAlertView().showError("Can't update session 😔", subTitle: error.message)
			print("Received update session error: \(error.message ?? "No message available")")
		})
	}

	/**
		Delete the specified session ID from the user's active sessions.

		- Parameter sessionID: The session ID to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether session delete is successful.
		- Parameter isSuccess: A boolean value indicating whether session delete is successful.
	*/
	public func deleteSession(_ sessionID: Int, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let sessionsDelete = self.kurozoraKitEndpoints.sessionsDelete.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request(sessionsDelete)

		request.headers = headers
		if self._userAuthToken != "" {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.perform(withSuccess: { session in
			if let success = session.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't delete session 😔", subTitle: error.message)
			print("Received delete session error: \(error.message ?? "No message available")")
		})
	}

	/**
		Sign out the given user session.

		After the user has been signed out successfully, a notification with the `KUserIsSignedInDidChange` name is posted.
		This notification can be observed to perform UI changes regarding the user's sign in status. For example you can remove buttons the user should not have access to if not signed in.

		- Parameter sessionID: The session ID to be signed out of.
		- Parameter successHandler: A closure returning a boolean indicating whether sign out is successful.
		- Parameter isSuccess: A boolean value indicating whether sign out is successful.
	*/
	public func signOut(ofSessionID sessionID: Int, withSuccess successHandler: ((_ isSuccess: Bool) -> Void)? = nil) {
		let sessionsDelete = self.kurozoraKitEndpoints.sessionsDelete.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request(sessionsDelete)

		request.headers = headers
		if self._userAuthToken != "" {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					try? KKServices.shared.KeychainDefaults.removeAll()
					NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
					successHandler?(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't sign out 😔", subTitle: error.message)
			print("Received sign out error: \(error.message ?? "No message available")")
		})
	}
}
