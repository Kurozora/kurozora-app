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
		Fetch the studio details for the given studio id.

		- Parameter studioID: The id of the studio for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forStudioID studioID: Int, including relationships: [String] = [], limit: Int? = nil, completion completionHandler: @escaping (_ result: Result<[Studio], KKAPIError>) -> Void) {
		let studiosDetails = KKEndpoint.Shows.Studios.details(studioID).endpointValue
		let request: APIRequest<StudioResponse, KKAPIError> = tron.codable.request(studiosDetails)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		request.perform(withSuccess: { studioResponse in
			completionHandler(.success(studioResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get studio details 😔", subTitle: error.message)
			}
			print("❌ Received get studio details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the shows for the given studio id.

		- Parameter studioID: The studio id for which the shows should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getShows(forStudioID studioID: Int, completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let studiosShows = KKEndpoint.Shows.Studios.shows(studioID).endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(studiosShows)

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
				SCLAlertView().showError("Can't get studio shows list 😔", subTitle: error.message)
			}
			print("❌ Received get studio shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
