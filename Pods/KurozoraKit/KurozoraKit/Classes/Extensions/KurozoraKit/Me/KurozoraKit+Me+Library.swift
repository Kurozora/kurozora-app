//
//  KurozoraKit+Library.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the list of shows with the given show status in the authenticated user's library.

		- Parameter libraryStatus: The library status to retrieve the library items for.
		- Parameter sortType: The sort value by which the retrived items should be sorted.
		- Parameter sortOption: The sort option value by which the retrived items should be sorted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getLibrary(withLibraryStatus libraryStatus: KKLibrary.Status, withSortType sortType: KKLibrary.SortType, withSortOption sortOption: KKLibrary.SortType.Options, completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let meLibraryIndex = KKEndpoint.Me.Library.index.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meLibraryIndex)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .get
		request.parameters = [
			"status": libraryStatus.sectionValue
		]
		if sortType != .none {
			request.parameters["sort"] = "\(sortType.parameterValue)\(sortOption.parameterValue)"
		}
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse.data))
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

	/**
		Add a show with the given show id to the authenticated user's library.

		- Parameter libraryStatus: The watch status to assign to the Anime.
		- Parameter showID: The id of the show to add.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func addToLibrary(withLibraryStatus libraryStatus: KKLibrary.Status, showID: Int, completion completionHandler: @escaping (_ result: Result<LibraryUpdate, KKAPIError>) -> Void) {
		let meLibraryIndex = KKEndpoint.Me.Library.index.endpointValue
		let request: APIRequest<LibraryUpdateResponse, KKAPIError> = tron.codable.request(meLibraryIndex)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

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

	/**
		Remove a show with the given show id from the authenticated user's library.

		- Parameter showID: The id of the show to be deleted.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func removeFromLibrary(showID: Int, completion completionHandler: @escaping (_ result: Result<LibraryUpdate, KKAPIError>) -> Void) {
		let meLibraryDelete = KKEndpoint.Me.Library.delete.endpointValue
		let request: APIRequest<LibraryUpdateResponse, KKAPIError> = tron.codable.request(meLibraryDelete)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

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

	/**
		Import a MAL export file into the authenticated user's library.

		- Parameter filePath: The path to the file to be imported.
		- Parameter behavior: The preferred behavior of importing the file.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func importMALLibrary(filePath: URL, importBehavior behavior: MALImport.Behavior, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let meLibraryMALImport = KKEndpoint.Me.Library.malImport.endpointValue
		let request: UploadAPIRequest<KKSuccess, KKAPIError> = tron.codable.uploadMultipart(meLibraryMALImport) { formData in
			formData.append(filePath, withName: "file", fileName: "MALAnimeImport.xml", mimeType: "text/xml")
		}

		request.headers = [
			"accept": "application/json",
			"Content-Type": "multipart/form-data"
		]
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .post
		request.parameters = [
			"behavior": behavior.stringValue
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

	/**
		Fetch a list of shows matching the search query in the authenticated user's library.

		- Parameter show: The search query by which the search list should be fetched.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func searchLibrary(forShow show: String, completion completionHandler: @escaping (_ result: Result<[Show], KKAPIError>) -> Void) {
		let meLibrarySearch = KKEndpoint.Me.Library.search.endpointValue
		let request: APIRequest<ShowResponse, KKAPIError> = tron.codable.request(meLibrarySearch)

		request.headers = headers
		request.headers["kuro-auth"] = self.authenticationKey

		request.method = .get
		request.parameters = [
			"query": show
		]
		request.perform(withSuccess: { showResponse in
			completionHandler(.success(showResponse.data))
		}, failure: { error in
			print("❌ Received library search error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
