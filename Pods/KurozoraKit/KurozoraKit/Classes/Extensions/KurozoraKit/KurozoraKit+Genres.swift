//
//  KurozoraKit+Genre.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the list of genres.
	///
	/// - Parameters:
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getGenres(completion completionHandler: @escaping (_ result: Result<[Genre], KKAPIError>) -> Void) -> DataRequest {
		let genresIndex = KKEndpoint.Shows.Genres.index.endpointValue
		let request: APIRequest<GenreResponse, KKAPIError> = tron.codable.request(genresIndex)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		return request.perform(withSuccess: { genreResponse in
			completionHandler(.success(genreResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Genres 😔", message: error.message)
			}
			print("❌ Received get genres error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the genre details for the given genre identity.
	///
	/// - Parameters:
	///    - genreIdentity: The genre identity object of the genre for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forGenre genreIdentity: GenreIdentity, completion completionHandler: @escaping (_ result: Result<[Genre], KKAPIError>) -> Void) -> DataRequest {
		let genresDetails = KKEndpoint.Shows.Genres.details(genreIdentity).endpointValue
		let request: APIRequest<GenreResponse, KKAPIError> = tron.codable.request(genresDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		return request.perform(withSuccess: { genreResponse in
			completionHandler(.success(genreResponse.data))
		}, failure: { error in
			print("❌ Received get genre details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
