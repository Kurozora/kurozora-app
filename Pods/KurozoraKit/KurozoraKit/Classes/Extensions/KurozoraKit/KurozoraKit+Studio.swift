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

		- Parameter relationships: The relationships to include in the response.
		- Parameter limit: The number of shows to get. Set to `nil` to get all shows.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getStudios(including relationships: [String] = [], limit: Int? = nil, completion completionHandler: @escaping (_ result: Result<[Studio], KKAPIError>) -> Void) {
		let studios = self.kurozoraKitEndpoints.studios
		let request: APIRequest<StudioResponse, KKAPIError> = tron.codable.request(studios)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}
		if limit != nil, let limit = limit {
			request.parameters["limit"] = limit
		}

		request.method = .get
		request.perform(withSuccess: { studioResponse in
			completionHandler(.success(studioResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get studios list 😔", subTitle: error.message)
			}
			print("❌ Received get studios error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/**
		Fetch the studio details for the given studio id.

		- Parameter studioID: The id of the studio for which the details should be fetched.
		- Parameter relationships: The relationships to include in the response.
		- Parameter limit: The number of shows to get. Set to `nil` to get all shows.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getDetails(forStudioID studioID: Int, including relationships: [String] = [], limit: Int? = nil, completion completionHandler: @escaping (_ result: Result<[Studio], KKAPIError>) -> Void) {
		let studio = self.kurozoraKitEndpoints.studio.replacingOccurrences(of: "?", with: "\(studioID)")
		let request: APIRequest<StudioResponse, KKAPIError> = tron.codable.request(studio)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}
		if limit != nil, let limit = limit {
			request.parameters["limit"] = limit
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
}
