//
//  KurozoraKit+Actors.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the actor details for the given actor id.

		- Parameter actorID: The id of the actor for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forActorID actorID: Int, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Actor], KKAPIError>) -> Void) {
		let actorsDetails = KKEndpoint.Shows.Actors.details(actorID).endpointValue
		let request: APIRequest<ActorResponse, KKAPIError> = tron.codable.request(actorsDetails)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		request.perform(withSuccess: { actorResponse in
			completionHandler(.success(actorResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get actor details 😔", subTitle: error.message)
			}
			print("❌ Received get actor details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the characters for the given actor id.

		- Parameter actorID: The actor id for which the characters should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCharacters(forActorID actorID: Int, completion completionHandler: @escaping (_ result: Result<[Character], KKAPIError>) -> Void) {
		let charactersActors = KKEndpoint.Shows.Actors.characters(actorID).endpointValue
		let request: APIRequest<CharacterResponse, KKAPIError> = tron.codable.request(charactersActors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { characterResponse in
			completionHandler(.success(characterResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get actor actors list 😔", subTitle: error.message)
			}
			print("❌ Received get actor actors error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the shows for the given actor id.

		- Parameter actorID: The actor id for which the shows should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getShows(forActorID actorID: Int, completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let charactersShows = KKEndpoint.Shows.Actors.shows(actorID).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(charactersShows)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get actor shows list 😔", subTitle: error.message)
			}
			print("❌ Received get actor shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
