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
		Fetch the list of actors.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getActors(completion completionHandler: @escaping (_ result: Result<[Actor], KKAPIError>) -> Void) {
		let actors = self.kurozoraKitEndpoints.actors
		let request: APIRequest<ActorResponse, KKAPIError> = tron.codable.request(actors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { actorResponse in
			completionHandler(.success(actorResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get actors list 😔", subTitle: error.message)
			}
			print("❌ Received get actors error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the actor details for the given actor id.

		- Parameter actorID: The id of the actor for which the details should be fetched.
		- Parameter includesShows: Set to `true` to include show data.
		- Parameter limit: The number of shows to get. Set to `nil` to get all shows.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forActorID actorID: Int, includesShows: Bool? = nil, limit: Int? = nil, completion completionHandler: @escaping (_ result: Result<[Actor], KKAPIError>) -> Void) {
		let actor = self.kurozoraKitEndpoints.actor.replacingOccurrences(of: "?", with: "\(actorID)")
		let request: APIRequest<ActorResponse, KKAPIError> = tron.codable.request(actor)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if includesShows != nil, let includesShows = includesShows {
			request.parameters["anime"] = includesShows ? 1 : 0
		}
		if limit != nil, let limit = limit {
			request.parameters["limit"] = limit
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
}
