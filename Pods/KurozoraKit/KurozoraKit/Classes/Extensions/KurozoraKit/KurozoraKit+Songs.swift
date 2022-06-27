//
//  KurozoraKit+Songs.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/02/2022.
//

import TRON
import Alamofire

extension KurozoraKit {
	/// Fetch the song details for the given song identity.
	///
	/// - Parameters:
	///    - songIdentity: The identity of the song for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forSong songIdentity: SongIdentity, including relationships: [String] = [], completion completionHandler: @escaping (_ result: Result<[Song], KKAPIError>) -> Void) -> DataRequest {
		let songsDetails = KKEndpoint.Songs.details(songIdentity).endpointValue
		let request: APIRequest<SongResponse, KKAPIError> = tron.codable.request(songsDetails)

		request.headers = headers

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { SongResponse in
			completionHandler(.success(SongResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Song's Details 😔", message: error.message)
			}
			print("❌ Received get song details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
