//
//  KurozoraKit+Explore.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/08/2020.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the explore page content. Explore page can be filtered by a specific genre by passing the genre id.
	///
	/// Leaving the `genreID` and `themeID` empty or passing `nil` will return the global explore page which contains hand picked and staff curated shows.
	///
	/// - Parameters:
	///    - genreID: The id of a genre by which the explore page should be filtered.
	///    - themeID: The id of a theme by which the explore page should be filtered.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getExplore(genreID: String? = nil, themeID: String?, completion completionHandler: @escaping (_ result: Result<[ExploreCategory], KKAPIError>) -> Void) {
		let exploreIndex = KKEndpoint.Explore.index.endpointValue
		let request: APIRequest<ExploreCategoryResponse, KKAPIError> = tron.codable.request(exploreIndex)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		// Check if genre was passed
		if !(genreID?.isEmpty ?? true) {
			if let genreID = genreID {
				request.parameters["genre_id"] = genreID
			}
		}

		// Check if theme was passed
		if !(themeID?.isEmpty ?? true) {
			if let themeID = themeID {
				request.parameters["theme_id"] = themeID
			}
		}

		request.method = .get
		request.perform(withSuccess: { exploreCategoryResponse in
			completionHandler(.success(exploreCategoryResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Explore Page 😔", message: error.message)
			}
			print("❌ Received explore error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message)
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch the content of an explore category.
	///
	/// - Parameters:
	///    - genreID: The id of a genre by which the explore page should be filtered.
	///	   - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 5 and the maximum value is 25.
	///    
	/// - Returns: An instance of `DataTask` with the results of the request.
	public func getExplore(_ exploreCategoryIdentity: ExploreCategoryIdentity, next: String? = nil, limit: Int = 5) -> DataTask<ExploreCategoryResponse> {
		let exploreIndex = next ?? KKEndpoint.Explore.details(exploreCategoryIdentity).endpointValue
		let request: APIRequest<ExploreCategory, KKAPIError> = tron.codable.request(exploreIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		if !self.authenticationKey.isEmpty {
			request.headers.add(.authorization(bearerToken: self.authenticationKey))
		}

		request.method = .get
		if next == nil {
			request.parameters = [
				"limit": limit
			]
		}
		return request.perform().serializingDecodable(ExploreCategoryResponse.self, decoder: self.tron.codable.modelDecoder)
	}
}
