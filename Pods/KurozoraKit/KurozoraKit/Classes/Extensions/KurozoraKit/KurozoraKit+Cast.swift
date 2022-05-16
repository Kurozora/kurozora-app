//
//  KurozoraKit+Cast.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/02/2022.
//

import TRON
import Alamofire

extension KurozoraKit {
	/// Fetch the cast details for the given cast id.
	///
	/// - Parameters:
	///    - castID: The id of the cast for which the details should be fetched.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forCast castIdentity: CastIdentity, completion completionHandler: @escaping (_ result: Result<[Cast], KKAPIError>) -> Void) -> DataRequest {
		let castsDetails = KKEndpoint.Shows.Cast.details(castIdentity).endpointValue
		let request: APIRequest<CastResponse, KKAPIError> = tron.codable.request(castsDetails)
		request.headers = headers
		request.method = .get
		return request.perform(withSuccess: { castResponse in
			completionHandler(.success(castResponse.data))
		}, failure: { error in
			print("❌ Received get cast details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
