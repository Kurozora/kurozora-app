//
//  KurozoraKit+Characters.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the character details for the given character id.

		- Parameter characterID: The id of the character for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forCharacterID characterID: Int, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Character], KKAPIError>) -> Void) {
		let character = KKEndpoint.Shows.Characters.details(characterID).endpointValue
		let request: APIRequest<CharacterResponse, KKAPIError> = tron.codable.request(character)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		request.perform(withSuccess: { characterResponse in
			completionHandler(.success(characterResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get character details 😔", subTitle: error.message)
			}
			print("❌ Received get character details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the actors for the given character id.

		- Parameter characterID: The character id for which the actors should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getActors(forCharacterID characterID: Int, completion completionHandler: @escaping (_ result: Result<[Actor], KKAPIError>) -> Void) {
		let charactersActors = KKEndpoint.Shows.Characters.actors(characterID).endpointValue
		let request: APIRequest<ActorResponse, KKAPIError> = tron.codable.request(charactersActors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { actorResponse in
			completionHandler(.success(actorResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get character actors list 😔", subTitle: error.message)
			}
			print("❌ Received get character actors error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the shows for the given character id.

		- Parameter characterID: The character id for which the shows should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getShows(forCharacterID characterID: Int, completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let charactersShows = KKEndpoint.Shows.Characters.shows(characterID).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(charactersShows)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get character shows list 😔", subTitle: error.message)
			}
			print("❌ Received get character shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
