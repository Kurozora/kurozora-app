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
	///
	/// - Returns: An instance of `RequestSender` with the results of the get song details response.
	public func getDetails(forSong songIdentity: SongIdentity, including relationships: [String] = []) -> RequestSender<SongResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [:]
		if !relationships.isEmpty {
			parameters["include"] = relationships.joined(separator: ",")
		}

		// Prepare request
		let songsDetails = KKEndpoint.Songs.details(songIdentity).endpointValue
		let request: APIRequest<SongResponse, KKAPIError> = tron.codable.request(songsDetails)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	///	Fetch the shows for the given song identity.
	///
	/// - Parameters:
	///    - songIdentity: The song identity object for which the shows should be fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///	   - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get song shows response.
	public func getShows(forSong songIdentity: SongIdentity, next: String? = nil, limit: Int = 25) -> RequestSender<ShowIdentityResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [:]
		parameters["limi"] = limit

		// Prepare request
		let songShows = next ?? KKEndpoint.Songs.shows(songIdentity).endpointValue
		let request: APIRequest<ShowIdentityResponse, KKAPIError> = tron.codable.request(songShows).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
