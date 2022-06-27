//
//  KurozoraKit+Search.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 21/05/2022.
//

import Alamofire
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
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func search(_ scope: KKSearchScope, of types: [KKSearchType], for query: String, next: String? = nil, limit: Int = 5) -> DataTask<SearchResponse> {
		let showsSearch = next ?? KKEndpoint.Search.index.endpointValue
		let request: APIRequest<SearchResponse, KKAPIError> = tron.codable.request(showsSearch).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		if next == nil {
			let types: [String] = types.map { kkSearchType in
				return kkSearchType.rawValue
			}

			request.parameters = [
				"scope": scope.queryValue,
				"types": types,
				"query": query,
				"limit": limit
			]
		}

		request.method = .get
		return request.perform().serializingDecodable(SearchResponse.self)
	}
}
