//
//  KurozoraKit+Explore.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/08/2020.
//

import TRON

extension KurozoraKit {
	/// Fetch the explore page content. Explore page can be filtered by a specific genre by passing the genre id.
	///
	/// Leaving the `genreID` and `themeID` empty or passing `nil` will return the global explore page which contains hand picked and staff curated shows.
	///
	/// - Parameters:
	///    - genreID: The id of a genre by which the explore page should be filtered.
	///    - themeID: The id of a theme by which the explore page should be filtered.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get explore response.
	public func getExplore(genreID: String? = nil, themeID: String? = nil) -> RequestSender<ExploreCategoryResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [:]
		if !(genreID?.isEmpty ?? true) {
			if let genreID = genreID {
				parameters["genre_id"] = genreID
			}
		}
		if !(themeID?.isEmpty ?? true) {
			if let themeID = themeID {
				parameters["theme_id"] = themeID
			}
		}

		// Prepare request
		let exploreIndex = KKEndpoint.Explore.index.endpointValue
		let request: APIRequest<ExploreCategoryResponse, KKAPIError> = tron.codable.request(exploreIndex)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch the content of an explore category.
	///
	/// - Parameters:
	///    - exploreCategoryIdentity: The id of a explore category for which the content is fetched.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 5 and the maximum value is 25.
	///    
	/// - Returns: An instance of `RequestSender` with the results of the get explore response.
	public func getExplore(_ exploreCategoryIdentity: ExploreCategoryIdentity, next: String? = nil, limit: Int = 5) -> RequestSender<ExploreCategoryResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [:]
		if next == nil {
			parameters = [
				"limit": limit
			]
		}

		// Prepare request
		let exploreIndex = next ?? KKEndpoint.Explore.details(exploreCategoryIdentity).endpointValue
		let request: APIRequest<ExploreCategoryResponse, KKAPIError> = tron.codable.request(exploreIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
