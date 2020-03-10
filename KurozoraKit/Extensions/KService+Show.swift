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
		Fetch the explore page content.

		- Parameter successHandler: A closure returning an Explore object.
		- Parameter explore: The returned Explore object.
	*/
	func getExplore(withSuccess successHandler: @escaping (_ explore: Explore?) -> Void) {
		let explore = self.kurozoraEndpoints.explore
		let request: APIRequest<Explore, JSONError> = tron.swiftyJSON.request(explore)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .get
		request.perform(withSuccess: { explore in
			if let success = explore.success {
				if success {
					successHandler(explore)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get explore page 😔", subTitle: error.message)
			print("Received explore error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the show details for the given show id.

		- Parameter showID: The id of the show for which the details should be fetched.
		- Parameter successHandler: A closure returning a ShowDetailsElement object.
		- Parameter showDetailsElement: The returned ShowDetailsElement object.
	*/
	func getDetails(forShow showID: Int, withSuccess successHandler: @escaping (_ showDetailsElement: ShowDetailsElement) -> Void) {
		let anime = self.kurozoraEndpoints.anime.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<ShowDetails, JSONError> = tron.swiftyJSON.request(anime)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .get
		request.perform(withSuccess: { showDetails in
			DispatchQueue.main.async {
				if let showDetailsElement = showDetails.showDetailsElement {
					successHandler(showDetailsElement)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get show details 😔", subTitle: error.message)
			print("Received get details error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the cast details for the given show id.

		- Parameter showID: The show id for which the cast details should be fetched.
		- Parameter successHandler: A closure returning an ActorsElement array.
		- Parameter actors: The returned ActorsElement array.
	*/
	func getCastFor(_ showID: Int, withSuccess successHandler: @escaping (_ actors: [ActorsElement]?) -> Void) {
		let animeActors = self.kurozoraEndpoints.animeActors.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<Actors, JSONError> = tron.swiftyJSON.request(animeActors)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { actors in
			if let success = actors.success {
				if success {
					successHandler(actors.actors)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get casts list 😔", subTitle: error.message)
			print("Received get cast error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch the seasons for a the given show id.

		- Parameter showID: The show id for which the seasons should be fetched.
		- Parameter successHandler: A closure returning a SeasonsElement array.
		- Parameter seasons: The returned SeasonsElement array.
	*/
	func getSeasonsFor(_ showID: Int, withSuccess successHandler: @escaping (_ seasons: [SeasonsElement]?) -> Void) {
		let animeSeasons = self.kurozoraEndpoints.animeSeasons.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<Seasons, JSONError> = tron.swiftyJSON.request(animeSeasons)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { seasons in
			if let success = seasons.success {
				if success {
					successHandler(seasons.seasons)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get seasons list 😔", subTitle: error.message)
			print("Received get show seasons error: \(error.message ?? "No message available")")
		})
	}

	/**
		Rate the show with the given show id.

		- Parameter showID: The id of the show which should be rated.
		- Parameter score: The rating to leave.
		- Parameter successHandler: A closure returning a boolean indicating whether rating is successful.
		- Parameter isSuccess: A boolean value indicating whether rating is successful.
	*/
	func rateShow(_ showID: Int, with score: Double, withSuccess successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let animeRate = self.kurozoraEndpoints.animeRate.replacingOccurrences(of: "?", with: "\(showID)")
		let request: APIRequest<User, JSONError> = tron.swiftyJSON.request(animeRate)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .post
		request.parameters = [
			"rating": score
		]
		request.perform(withSuccess: { user in
			if let success = user.success {
				if success {
					successHandler(success)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't rate this show 😔", subTitle: error.message)
			print("Received rating error: \(error.message ?? "No message available")")
		})
	}

	/**
		Fetch a list of shows matching the search query.

		- Parameter show: The search query by which the search list should be fetched.
		- Parameter successHandler: A closure returning a SearchElement array.
		- Parameter search: The returned SearchElement array.
	*/
	func search(forShow show: String, withSuccess successHandler: @escaping (_ search: [ShowDetailsElement]?) -> Void) {
		let animeSearch = self.kurozoraEndpoints.animeSearch
		let request: APIRequest<Search, JSONError> = tron.swiftyJSON.request(animeSearch)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .get
		request.parameters = [
			"query": show
		]
		request.perform(withSuccess: { search in
			if let success = search.success {
				if success {
					successHandler(search.showResults)
				}
			}
		}, failure: { error in
//			SCLAlertView().showError("Can't get search results 😔", subTitle: error.message)
			print("Received show search error: \(error.message ?? "No message available")")
		})
	}
}
