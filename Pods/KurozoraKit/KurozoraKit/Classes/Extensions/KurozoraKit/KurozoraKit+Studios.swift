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
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getDetails(forStudio studioIdentity: StudioIdentity, including relationships: [String] = [], limit: Int? = nil) -> DataTask<StudioResponse> {
		let studiosDetails = KKEndpoint.Studios.details(studioIdentity).endpointValue
		let request: APIRequest<StudioResponse, KKAPIError> = tron.codable.request(studiosDetails)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if !relationships.isEmpty {
			request.parameters["include"] = relationships.joined(separator: ",")
		}

		request.method = .get
		return request.perform().serializingDecodable(StudioResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the shows for the given studio identity.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity object for which the shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getShows(forStudio studioIdentity: StudioIdentity, next: String? = nil, limit: Int = 25) -> DataTask<ShowIdentityResponse> {
		let studiosShows = next ?? KKEndpoint.Studios.shows(studioIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(studiosShows).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(ShowIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}

	///	Fetch the literatures for the given studio identity.
	///
	/// - Parameters:
	///    - studioIdentity: The studio identity object for which the literatures should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getLiteratures(forStudio studioIdentity: StudioIdentity, next: String? = nil, limit: Int = 25) -> DataTask<LiteratureIdentityResponse> {
		let studiosLiteratures = next ?? KKEndpoint.Studios.literatures(studioIdentity).endpointValue
		let request: APIRequest<LiteratureIdentityResponse, KKAPIError> = tron.codable.request(studiosLiteratures).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.parameters["limit"] = limit

		request.method = .get
		return request.perform().serializingDecodable(LiteratureIdentityResponse.self, decoder: self.tron.codable.modelDecoder)
	}
}
