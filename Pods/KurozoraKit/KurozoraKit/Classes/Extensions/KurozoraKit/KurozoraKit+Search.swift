//
//  KurozoraKit+Search.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 21/05/2022.
//

import TRON

extension KurozoraKit {
	/// Fetch a list of resources matching the search query.
	///
	/// - Parameters:
	///    - scope: The scope of the search.
	///    - types: The types of the search.
	///    - query: The search query.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 5 and the maximum value is 25.
	///
	/// - Returns: An instance of `RequestSender` with the results of the search response.
	public func search(_ scope: KKSearchScope, of types: [KKSearchType], for query: String, next: String? = nil, limit: Int = 5, filter: KKSearchFilter?) -> RequestSender<SearchResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		var parameters: [String: Any] = [:]
		if next == nil {
			let types: [String] = types.map { kkSearchType in
				return kkSearchType.rawValue
			}

			parameters = [
				"scope": scope.queryValue,
				"types": types,
				"query": query,
				"limit": limit
			]

			if let filter = filter {
				var filters: [String: Any] = [:]

				switch filter {
				case .appTheme(let filter as Filterable),
						.character(let filter as Filterable),
						.episode(let filter as Filterable),
						.game(let filter as Filterable),
						.literature(let filter as Filterable),
						.person(let filter as Filterable),
						.show(let filter as Filterable),
						.song(let filter as Filterable),
						.studio(let filter as Filterable),
						.user(let filter as Filterable):
					filters = filter.toFilterArray().compactMapValues { value in
						return value
					}
				}

				do {
					let filterData = try JSONSerialization.data(withJSONObject: filters, options: [])
					parameters["filter"] = filterData.base64EncodedString()
				} catch {
					print("❌ Encode error: Could not make base64 string from filter data", filters)
				}
			}
		}

		// Prepare request
		let searchIndex = next ?? KKEndpoint.Search.index.endpointValue
		let request: APIRequest<SearchResponse, KKAPIError> = tron.codable.request(searchIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}

	/// Fetch a list of resources matching the search query.
	///
	/// - Parameters:
	///    - scope: The scope of the search.
	///    - types: The types of the search.
	///    - query: The search query.
	///
	/// - Returns: An instance of `RequestSender` with the results of the search suggestions response.
	public func getSearchSuggestions(_ scope: KKSearchScope, of types: [KKSearchType], for query: String) -> RequestSender<SearchSuggestionsResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		if !self.authenticationKey.isEmpty {
			headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Prepare parameters
		let types: [String] = types.map { kkSearchType in
			return kkSearchType.rawValue
		}

		let parameters: [String : Any] = [
			"scope": scope.queryValue,
			"types": types,
			"query": query
		]

		// Prepare request
		let searchSuggestions = KKEndpoint.Search.suggestions.endpointValue
		let request: APIRequest<SearchSuggestionsResponse, KKAPIError> = tron.codable.request(searchSuggestions).buildURL(.relativeToBaseURL)
			.method(.get)
			.parameters(parameters)
			.headers(headers)

		// Send request
		return request.sender()
	}
}
