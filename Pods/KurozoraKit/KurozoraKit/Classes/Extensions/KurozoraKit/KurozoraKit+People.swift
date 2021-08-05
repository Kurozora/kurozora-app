//
//  KurozoraKit+People.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 28/06/2020.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the person details for the given person id.

		- Parameter personID: The id of the person for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forPersonID personID: Int, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Person], KKAPIError>) -> Void) {
		let peopleDetails = KKEndpoint.Shows.People.details(personID).endpointValue
		let request: APIRequest<PersonResponse, KKAPIError> = tron.codable.request(peopleDetails)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		request.perform(withSuccess: { personResponse in
			completionHandler(.success(personResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Person's Details 😔", message: error.message)
			}
			print("❌ Received get person details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the characters for the given person id.

		- Parameter personID: The person id for which the characters should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCharacters(forPersonID personID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<CharacterResponse, KKAPIError>) -> Void) {
		let charactersPeople = next ?? KKEndpoint.Shows.People.characters(personID).endpointValue
		let request: APIRequest<CharacterResponse, KKAPIError> = tron.codable.request(charactersPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { characterResponse in
			completionHandler(.success(characterResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Person's Characters 😔", message: error.message)
			}
			print("❌ Received get person characters error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the shows for the given person id.

		- Parameter personID: The person id for which the shows should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getShows(forPersonID personID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) {
		let charactersShows = next ?? KKEndpoint.Shows.People.shows(personID).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(charactersShows).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Person's Shows 😔", message: error.message)
			}
			print("❌ Received get person shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
