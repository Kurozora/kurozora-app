//
//  KurozoraKit+Show.swift
//  Kurozora
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
	public func getExplore(_ genreID: Int? = nil, completion completionHandler: @escaping (_ result: Result<Explore, JSONError>) -> Void) {
		let explore = self.kurozoraKitEndpoints.explore
		let request: APIRequest<Explore, JSONError> = tron.swiftyJSON.request(explore)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		if genreID != nil || genreID != 0 {
			if let genreID = genreID {
				request.parameters = [
					"genre_id": String(genreID)
				]
			}
		}

		request.method = .get
		request.perform(withSuccess: { explore in
			completionHandler(.success(explore))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get explore page 😔", subTitle: error.message)
			}
			print("Received explore error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the show details for the given show id.

		- Parameter showID: The id of the show for which the details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forShowID showID: Int, completion completionHandler: @escaping (_ result: Result<ShowDetailsElement, JSONError>) -> Void) {
		let anime = self.kurozoraKitEndpoints.anime.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request(anime)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .get
		request.perform(withSuccess: { showDetails in
			DispatchQueue.main.async {
				completionHandler(.success(showDetails.showDetailsElement ?? ShowDetailsElement()))
			}
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get show details 😔", subTitle: error.message)
			}
			print("Received get details error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the cast details for the given show id.

		- Parameter showID: The show id for which the cast details should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getCast(forShowID showID: Int, completion completionHandler: @escaping (_ result: Result<[ActorsElement], JSONError>) -> Void) {
		let animeActors = self.kurozoraKitEndpoints.animeActors.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<Actors, JSONError> = tron.swiftyJSON.request(animeActors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { actors in
			completionHandler(.success(actors.actors ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get casts list 😔", subTitle: error.message)
			}
			print("Received get cast error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the seasons for a the given show id.

		- Parameter showID: The show id for which the seasons should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getSeasons(forShowID showID: Int, completion completionHandler: @escaping (_ result: Result<[SeasonsElement], JSONError>) -> Void) {
		let animeSeasons = self.kurozoraKitEndpoints.animeSeasons.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<Seasons, JSONError> = tron.swiftyJSON.request(animeSeasons)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { seasons in
			completionHandler(.success(seasons.seasons ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get seasons list 😔", subTitle: error.message)
			}
			print("Received get show seasons error: \(error.message ?? "No message available")")
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
	public func rateShow(_ showID: Int, with score: Double, completion completionHandler: @escaping (_ result: Result<Bool, JSONError>) -> Void) {
		let animeRate = self.kurozoraKitEndpoints.animeRate.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request(animeRate)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"rating": score
		]
		request.perform(withSuccess: { _ in
			completionHandler(.success(true))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't rate this show 😔", subTitle: error.message)
			}
			print("Received rating error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch a list of shows matching the search query.

		- Parameter show: The search query by which the search list should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func search(forShow show: String, completion completionHandler: @escaping (_ result: Result<[ShowDetailsElement], JSONError>) -> Void) {
		let animeSearch = self.kurozoraKitEndpoints.animeSearch
		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request(animeSearch)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .get
		request.parameters = [
			"query": show
		]
		request.perform(withSuccess: { search in
			completionHandler(.success(search.showResults ?? []))
		}, failure: { error in
//			if self.services.showAlerts {
//				SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
//			}
			print("Received show search error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
