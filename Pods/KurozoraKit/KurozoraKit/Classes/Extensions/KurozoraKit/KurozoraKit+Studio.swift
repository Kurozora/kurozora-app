//
//  KurozoraKit+Studio.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Fetch the list of studios.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getStudios(completion completionHandler: @escaping (_ result: Result<[StudioElement], KKError>) -> Void) {
		let studios = self.kurozoraKitEndpoints.studios
		let request: APIRequest<Studios, KKError> = tron.swiftyJSON.request(studios)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { studios in
			completionHandler(.success(studios.studios ?? []))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get studios list 😔", subTitle: error.message)
			}
			print("Received get studios error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the studio details for the given studio id.

		- Parameter studioID: The id of the studio for which the details should be fetched.
		- Parameter includesShows: Set to `true` to include show data.
		- Parameter limit: The number of shows to get. Set to `nil` to get all shows.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forStudioID studioID: Int, includesShows: Bool? = nil, limit: Int? = nil, completion completionHandler: @escaping (_ result: Result<StudioElement, KKError>) -> Void) {
		let studio = self.kurozoraKitEndpoints.studio.replacingOccurrences(of: "?", with: "\(studioID)")
		let request: APIRequest<Studios, KKError> = tron.swiftyJSON.request(studio)
		request.headers = headers
		request.method = .get

		if includesShows != nil, let includesShows = includesShows {
			request.parameters["anime"] = includesShows ? 1 : 0
		}
		if limit != nil, let limit = limit {
			request.parameters["limit"] = limit
		}

		request.perform(withSuccess: { studios in
			completionHandler(.success(studios.studioElement ?? StudioElement()))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get studio details 😔", subTitle: error.message)
			}
			print("Received get studio details error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
