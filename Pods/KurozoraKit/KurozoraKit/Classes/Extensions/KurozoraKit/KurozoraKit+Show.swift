//
//  KurozoraKit+Show.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the explore page content. Explore page can be filtered by a specific genre by passing the genre id.

		Leaving the `genreID` empty will return the global explore page which contains hand picked and staff curated shows.

		- Parameter genreID: The id of a genre by which the explore page should be filtered.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getExplore(_ genreID: Int? = nil, completion completionHandler: @escaping (_ result: Result<[ExploreCategory], KKAPIError>) -> Void) {
		let explore = self.kurozoraKitEndpoints.explore
		let request: APIRequest<ExploreCategoryResponse, KKAPIError> = tron.codable.request(explore)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if genreID != nil || genreID != 0 {
			if let genreID = genreID {
				request.parameters = [
					"genre_id": String(genreID)
				]
			}
		}

		request.method = .get
		request.perform(withSuccess: { exploreCategoryResponse in
			completionHandler(.success(exploreCategoryResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get explore page 😔", subTitle: error.message)
			}
			print("❌ Received explore error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the show details for the given show id.

		- Parameter showID: The id of the show for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forShowID showID: Int, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let anime = self.kurozoraKitEndpoints.anime.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(anime)

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
				SCLAlertView().showError("Can't get show details 😔", subTitle: error.message)
			}
			print("❌ Received get details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the actor details for the given show id.

		- Parameter showID: The show id for which the actor details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getActors(forShowID showID: Int, completion completionHandler: @escaping (_ result: Result<[Actor], KKAPIError>) -> Void) {
		let animeActors = self.kurozoraKitEndpoints.animeActors.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<ActorResponse, KKAPIError> = tron.codable.request(animeActors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { actorResponse in
			completionHandler(.success(actorResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get actors list 😔", subTitle: error.message)
			}
			print("❌ Received get actros error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the cast details for the given show id.

		- Parameter showID: The show id for which the cast details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCast(forShowID showID: Int, completion completionHandler: @escaping (_ result: Result<[Cast], KKAPIError>) -> Void) {
		let animeActors = self.kurozoraKitEndpoints.animeCast.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<CastResponse, KKAPIError> = tron.codable.request(animeActors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { castResponse in
			completionHandler(.success(castResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get cast list 😔", subTitle: error.message)
			}
			print("❌ Received get cast error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the character details for the given show id.

		- Parameter showID: The show id for which the character details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCharacters(forShowID showID: Int, completion completionHandler: @escaping (_ result: Result<[Character], KKAPIError>) -> Void) {
		let animeActors = self.kurozoraKitEndpoints.animeCharacters.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<CharacterResponse, KKAPIError> = tron.codable.request(animeActors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { characterResponse in
			completionHandler(.success(characterResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get characters list 😔", subTitle: error.message)
			}
			print("❌ Received get characters error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the seasons for a the given show id.

		- Parameter showID: The show id for which the seasons should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getSeasons(forShowID showID: Int, completion completionHandler: @escaping (_ result: Result<[Season], KKAPIError>) -> Void) {
		let animeSeasons = self.kurozoraKitEndpoints.animeSeasons.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<SeasonResponse, KKAPIError> = tron.codable.request(animeSeasons)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { seasonResponse in
			completionHandler(.success(seasonResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get seasons list 😔", subTitle: error.message)
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
		let animeRate = self.kurozoraKitEndpoints.animeRate.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(animeRate)

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
				SCLAlertView().showError("Can't rate this show 😔", subTitle: error.message)
			}
			print("❌ Received rating error:", error.errorDescription ?? "Unknown error")
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
		let animeSearch = self.kurozoraKitEndpoints.animeSearch
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(animeSearch)

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
//			if self.services.showAlerts {
//				SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
//			}
			print("❌ Received show search error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
