//
//  KurozoraKit+Show.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the show details for the given show id.

		- Parameter showID: The id of the show for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forShowID showID: Int, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let showsDetails = KKEndpoint.Shows.details(showID).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(showsDetails)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Show's Details 😔", message: error.message)
			}
			print("❌ Received get show details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the person details for the given show id.

		- Parameter showID: The show id for which the person details should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getPeople(forShowID showID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<PersonResponse, KKAPIError>) -> Void) {
		let showsPeople = next ?? KKEndpoint.Shows.people(showID).endpointValue
		let request: APIRequest<PersonResponse, KKAPIError> = tron.codable.request(showsPeople).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { personResponse in
			completionHandler(.success(personResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Show's People 😔", message: error.message)
			}
			print("❌ Received get show people error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the cast details for the given show id.

		- Parameter showID: The show id for which the cast details should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCast(forShowID showID: Int, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<CastResponse, KKAPIError>) -> Void) {
		let showsCast = next ?? KKEndpoint.Shows.cast(showID).endpointValue
		let request: APIRequest<CastResponse, KKAPIError> = tron.codable.request(showsCast).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { castResponse in
			completionHandler(.success(castResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Show's Cast 😔", message: error.message)
			}
			print("❌ Received get show cast error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the character details for the given show id.

		- Parameter showID: The show id for which the character details should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCharacters(forShowID showID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<CharacterResponse, KKAPIError>) -> Void) {
		let showsCharacters = next ?? KKEndpoint.Shows.characters(showID).endpointValue
		let request: APIRequest<CharacterResponse, KKAPIError> = tron.codable.request(showsCharacters).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { characterResponse in
			completionHandler(.success(characterResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Show's Characters 😔", message: error.message)
			}
			print("❌ Received get show characters error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the related shows for a the given show id.

		- Parameter showID: The show id for which the related shows should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getRelatedShows(forShowID showID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<RelatedShowResponse, KKAPIError>) -> Void) {
		let showsRelatedShows = next ?? KKEndpoint.Shows.relatedShows(showID).endpointValue
		let request: APIRequest<RelatedShowResponse, KKAPIError> = tron.codable.request(showsRelatedShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { relatedShowResponse in
			completionHandler(.success(relatedShowResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Related Shows 😔", message: error.message)
			}
			print("❌ Received get related shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the seasons for a the given show id.

		- Parameter showID: The show id for which the seasons should be fetched.
		- Parameter next: The URL string of the next page in the paginated response. Use `nil` to get first page.
		- Parameter limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getSeasons(forShowID showID: Int, next: String?, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<SeasonResponse, KKAPIError>) -> Void) {
		let showsSeasons = next ?? KKEndpoint.Shows.seasons(showID).endpointValue
		let request: APIRequest<SeasonResponse, KKAPIError> = tron.codable.request(showsSeasons).buildURL(.relativeToBaseURL)
		request.headers = headers

		request.parameters["limit"] = limit

		request.method = .get
		request.perform(withSuccess: { seasonResponse in
			completionHandler(.success(seasonResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Show's Seasons 😔", message: error.message)
			}
			print("❌ Received get show seasons error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Rate the show with the given show id.

		- Parameter showID: The id of the show which should be rated.
		- Parameter score: The rating to leave.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func rateShow(_ showID: Int, with score: Double, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let showsRate = KKEndpoint.Shows.rate(showID).endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(showsRate)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"rating": score
		]
		request.perform(withSuccess: { success in
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Rate Show 😔", message: error.message)
			}
			print("❌ Received show rating error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of shows matching the search query.

		- Parameter show: The search query by which the search list should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func search(forShow show: String, completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let showsSearch = KKEndpoint.Shows.search.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(showsSearch)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .get
		request.parameters = [
			"query": show
		]
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse.data))
		}, failure: { error in
			print("❌ Received show search error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
