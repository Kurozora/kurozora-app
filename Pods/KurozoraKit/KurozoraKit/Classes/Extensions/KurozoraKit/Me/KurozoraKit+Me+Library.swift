//
//  KurozoraKit+Library.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON

extension KurozoraKit {
	/// Fetch the list of shows with the given show status in the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryStatus: The library status to retrieve the library items for.
	///    - sortType: The sort value by which the retrived items should be sorted.
	///    - sortOption: The sort option value by which the retrived items should be sorted.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getLibrary(withLibraryStatus libraryStatus: KKLibrary.Status, withSortType sortType: KKLibrary.SortType, withSortOption sortOption: KKLibrary.SortType.Options, next: String? = nil, limit: Int = 25, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) {
		let meLibraryIndex = next ?? KKEndpoint.Me.Library.index.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meLibraryIndex).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .get
		request.parameters = [
			"status": libraryStatus.sectionValue,
			"limit": limit
		]
		if sortType != .none {
			request.parameters["sort"] = "\(sortType.parameterValue)\(sortOption.parameterValue)"
		}
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Library 😔", message: error.message)
			}
			print("❌ Received get library error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Add a show with the given show id to the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryStatus: The watch status to assign to the Anime.
	///    - showID: The id of the show to add.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func addToLibrary(withLibraryStatus libraryStatus: KKLibrary.Status, showID: Int, completion completionHandler: @escaping (_ result: Result<LibraryUpdate, KKAPIError>) -> Void) {
		let meLibraryIndex = KKEndpoint.Me.Library.index.endpointValue
		let request: APIRequest<LibraryUpdateResponse, KKAPIError> = tron.codable.request(meLibraryIndex)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"status": libraryStatus.sectionValue,
			"anime_id": showID
		]
		request.perform(withSuccess: { libraryUpdateResponse in
			completionHandler(.success(libraryUpdateResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
			}
			print("❌ Received add library error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Remove a show with the given show id from the authenticated user's library.
	///
	/// - Parameters:
	///    - showID: The id of the show to be deleted.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func removeFromLibrary(showID: Int, completion completionHandler: @escaping (_ result: Result<LibraryUpdate, KKAPIError>) -> Void) {
		let meLibraryDelete = KKEndpoint.Me.Library.delete.endpointValue
		let request: APIRequest<LibraryUpdateResponse, KKAPIError> = tron.codable.request(meLibraryDelete)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"anime_id": showID
		]
		request.perform(withSuccess: { libraryUpdateResponse in
			completionHandler(.success(libraryUpdateResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
			}
			print("❌ Received remove library error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Import a MAL export file into the authenticated user's library.
	///
	/// - Parameters:
	///    - filePath: The path to the file to be imported.
	///    - behavior: The preferred behavior of importing the file.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func importMALLibrary(filePath: URL, importBehavior behavior: MALImport.Behavior, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let meLibraryMALImport = KKEndpoint.Me.Library.malImport.endpointValue
		let request: UploadAPIRequest<KKSuccess, KKAPIError> = tron.codable.uploadMultipart(meLibraryMALImport) { formData in
			formData.append(filePath, withName: "file", fileName: "MALAnimeImport.xml", mimeType: "text/xml")
		}

		request.headers = [
			.contentType("multipart/form-data"),
			.accept("application/json")
		]
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .post
		request.parameters = [
			"behavior": behavior.rawValue
		]
		request.perform(withSuccess: { [weak self] success in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Processing Request", message: success.message)
			}
			completionHandler(.success(success))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Import MAL Library 😔", message: error.message)
			}
			print("❌ Received library MAL import error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}

	/// Fetch a list of shows matching the search query in the authenticated user's library.
	///
	/// - Parameters:
	///    - show: The search query by which the search list should be fetched.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func searchLibrary(forShow show: String, next: String?, completion completionHandler: @escaping (_ result: Result<ShowResponse, KKAPIError>) -> Void) {
		let meLibrarySearch = next ?? KKEndpoint.Me.Library.search.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meLibrarySearch).buildURL(.relativeToBaseURL)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.method = .get
		if next == nil {
			request.parameters = [
				"query": show
			]
		}
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse))
		}, failure: { error in
			print("❌ Received library search error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
