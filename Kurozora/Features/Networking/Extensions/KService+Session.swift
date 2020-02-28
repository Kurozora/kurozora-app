//
//  KService+Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import AuthenticationServices
import TRON
import SCLAlertView

extension KService {
	/**
		Create a new session a.k.a sign in.

		- Parameter kurozoraID: The Kurozora id of the user to be signed in.
		- Parameter password: The password of the user to be signed in.
		- Parameter device: The name of the device the sign in is occuring from.
		- Parameter successHandler: A closure returning a boolean indicating whether sign in is successful.
		- Parameter isSuccess: A boolean value indicating whether sign in is successful.
	*/
	func signIn(_ kurozoraID: String?, _ password: String?, _ device: String?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let kurozoraID = kurozoraID else { return }
		guard let password = password else { return }
		guard let device = device else { return }

		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("sessions")
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
					try? Kurozora.shared.KDefaults.set(kurozoraID, key: "kurozora_id")
					WorkflowController.shared.processUserData(fromSession: userSession)
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

		- Parameter apnDeviceToken: The updated APN Device Token.
		- Parameter successHandler: A closure returning a boolean indicating whether session validation is successful.
		- Parameter isSuccess: A boolean value indicating whether session validation is successful.
	*/
	func updateSession(withToken apnDeviceToken: String, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let sessionID = User.currentSessionID else { return }

		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/update")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
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
	func validateSession(withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let sessionID = User.currentSessionID else { return }
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/validate")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.perform(withSuccess: { user in
			if let success = user.success {
				successHandler(success)
			}
		}, failure: { error in
			WorkflowController.shared.signOut()
			SCLAlertView().showError("Can't validate session 😔", subTitle: error.message)
			print("Received validate session error: \(error.message ?? "No message available")")
		})
	}

	/**
		Delete a session with the given session id.

		- Parameter sessionID: The id of the session to be deleted.
		- Parameter successHandler: A closure returning a boolean indicating whether session delete is successful.
		- Parameter isSuccess: A boolean value indicating whether session delete is successful.
	*/
	func deleteSession(with sessionID: Int?, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let sessionID = sessionID else { return }

		let request: APIRequest<UserSessions, JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
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

		- Parameter successHandler: A closure returning a boolean indicating whether sign out is successful.
		- Parameter isSuccess: A boolean value indicating whether sign out is successful.
	*/
	func signOut(withSuccess successHandler: ((_ isSuccess: Bool) -> Void)?) {
		guard let sessionID = User.currentSessionID else { return }

		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request("sessions/\(sessionID)/delete")
		request.headers = [
			"Content-Type": "application/x-www-form-urlencoded",
			"kuro-auth": User.authToken
		]
		request.method = .post
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					WorkflowController.shared.signOut()
					successHandler?(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't sign out 😔", subTitle: error.message)
			print("Received sign out error: \(error.message ?? "No message available")")
		})
	}
}
