//
//  KurozoraKit+Characters.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/06/2020.
//

import TRON

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
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Character's Details 😔", message: error.message)
			}
			print("❌ Received get character details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the people for the given character id.

		- Parameter characterID: The character id for which the people should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getPeople(forCharacterID characterID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<PersonResponse, KKAPIError>) -> Void) {
		let charactersPeople = next ?? KKEndpoint.Shows.Characters.people(characterID).endpointValue
		let request: APIRequest<PersonResponse, KKAPIError> = tron.codable.request(charactersPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { personResponse in
			completionHandler(.success(personResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Character's People 😔", message: error.message)
			}
			print("❌ Received get character people error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the shows for the given character id.

		- Parameter characterID: The character id for which the shows should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getShows(forCharacterID characterID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) {
		let charactersShows = next ?? KKEndpoint.Shows.Characters.shows(characterID).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(charactersShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Character's Shows 😔", message: error.message)
			}
			print("❌ Received get character shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
