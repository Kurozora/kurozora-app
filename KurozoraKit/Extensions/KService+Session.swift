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
		- Parameter device: The name of the device the sign in is occuring from.
		- Parameter successHandler: A closure returning a boolean indicating whether sign in is successful.
		- Parameter isSuccess: A boolean value indicating whether sign in is successful.
	*/
	func signIn(_ kurozoraID: String, _ password: String, _ device: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let sessions = self.kurozoraEndpoints.sessions
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request(sessions)
		request.headers = headers
		request.method = .post
		request.parameters = [
			"email": kurozoraID,
			"password": password,
			"device": device
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
		Update the user's current session with the specified data.

		- Parameter sessionID: The session ID to be updated.
		- Parameter apnDeviceToken: The updated APN Device Token.
		- Parameter successHandler: A closure returning a boolean indicating whether session validation is successful.
		- Parameter isSuccess: A boolean value indicating whether session validation is successful.
	*/
	func updateSession(_ sessionID: Int, withToken apnDeviceToken: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let sessionsUpdate = self.kurozoraEndpoints.sessionsUpdate.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request(sessionsUpdate)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

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
		Check if the current session is valid.

		- Parameter successHandler: A closure returning a boolean indicating whether session validation is successful.
		- Parameter isSuccess: A boolean value indicating whether session validation is successful.
	*/
	func validateSession(_ sessionID: Int, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let sessionsValidate = self.kurozoraEndpoints.sessionsValidate.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request(sessionsValidate)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .post
		request.perform(withSuccess: { user in
			if let success = user.success {
				successHandler(success)
			}
		}, failure: { error in
//			WorkflowController.shared.signOut()
			SCLAlertView().showError("Can't validate session 😔", subTitle: error.message)
			print("Received validate session error: \(error.message ?? "No message available")")
		})
	}

	/**
		Delete the specified session ID from the user's active sessions.

		- Parameter sessionID: The session ID to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether session delete is successful.
		- Parameter isSuccess: A boolean value indicating whether session delete is successful.
	*/
	func deleteSession(_ sessionID: Int, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let sessionsDelete = self.kurozoraEndpoints.sessionsDelete.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request(sessionsDelete)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

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
		Sign out the current user by deleting the current session.

		- Parameter sessionID: The current session ID of the user to be signed out.
		- Parameter successHandler: A closure returning a boolean indicating whether sign out is successful.
		- Parameter isSuccess: A boolean value indicating whether sign out is successful.
	*/
	func signOut(ofSessionID sessionID: Int, withSuccess successHandler: ((_ isSuccess: Bool) -> Void)?) {
		let sessionsDelete = self.kurozoraEndpoints.sessionsDelete.replacingOccurrences(of: "?", with: "\(sessionID)")
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request(sessionsDelete)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .post
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
//					WorkflowController.shared.signOut()
					successHandler?(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't sign out 😔", subTitle: error.message)
			print("Received sign out error: \(error.message ?? "No message available")")
		})
	}
}
