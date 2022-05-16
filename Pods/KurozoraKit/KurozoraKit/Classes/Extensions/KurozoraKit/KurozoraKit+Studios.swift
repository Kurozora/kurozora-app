//
//  KurozoraKit+Studio.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/06/2020.
//

import Alamofire
import TRON

extension KurozoraKit {
	///	Fetch the studio details for the given studio identiry.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity ibject of the studio for which the details should be fetched.
	///    - relationships: The relationships to include in the response.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getDetails(forStudio studioIdentity: StudioIdentity, including relationships: [String] = [], limit: Int? = nil, completion completionHandler: @escaping (_ result: Result<[Studio], KKAPIError>) -> Void) -> DataRequest {
		let studiosDetails = KKEndpoint.Shows.Studios.details(studioIdentity).endpointValue
		let request: APIRequest<StudioResponse, KKAPIError> = tron.codable.request(studiosDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform(withSuccess: { studioResponse in
			completionHandler(.success(studioResponse.data))
		}, failure: { error in
			print("❌ Received get studio details error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	///	Fetch the shows for the given studio identity.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity object for which the shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///	   - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///	   - result: A value that represents either a success or a failure, including an associated value in each case.
	@discardableResult
	public func getShows(forStudio studioIdentity: StudioIdentity, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowIdentityResponse, KKAPIError>) -> Void) -> DataRequest {
		let studiosShows = next ?? KKEndpoint.Shows.Studios.shows(studioIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(studiosShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform(withSuccess: { showIdentityResponse in
			completionHandler(.success(showIdentityResponse))
		}, failure: { error in
			print("❌ Received get studio shows error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
