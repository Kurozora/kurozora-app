//
//  KurozoraKit+Library.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import Alamofire
import TRON

extension KurozoraKit {
	/// Fetch the list of shows with the given show status in the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryKind: In which library the item should be added.
	///    - libraryStatus: The library status to retrieve the library items for.
	///    - sortType: The sort value by which the retrived items should be sorted.
	///    - sortOption: The sort option value by which the retrived items should be sorted.
	///    - next: The URL string of the next page in the paginated response. Use `nil` to get first page.
	///    - limit: The limit on the number of objects, or number of objects in the specified relationship, that are returned. The default value is 25 and the maximum value is 100.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get episode detail response.
	public func getLibrary(_ libraryKind: KKLibrary.Kind, withLibraryStatus libraryStatus: KKLibrary.Status, withSortType sortType: KKLibrary.SortType, withSortOption sortOption: KKLibrary.SortType.Options, next: String? = nil, limit: Int = 25) -> RequestSender<LibraryResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		var parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"status": libraryStatus.sectionValue,
			"limit": limit
		]
		if sortType != .none {
			parameters["sort"] = "\(sortType.parameterValue)\(sortOption.parameterValue)"
		}

		// Prepare request
		let meLibraryIndex = next ?? KKEndpoint.Me.Library.index.endpointValue
		let request: APIRequest<LibraryResponse, KKAPIError> = tron.codable.request(meLibraryIndex).buildURL(.relativeToBaseURL)
			.method(.get)
			.headers(headers)
			.parameters(parameters)

		// Send request
		return request.sender()
	}

	/// Add an item with the given show id to the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryKind: In which library the item should be added.
	///    - libraryStatus: The library status to assign to the item.
	///    - modelID: The id of the model to add.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get episode detail response.
	public func addToLibrary(_ libraryKind: KKLibrary.Kind, withLibraryStatus libraryStatus: KKLibrary.Status, modelID: String) -> RequestSender<LibraryUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"model_id": modelID,
			"status": libraryStatus.rawValue
		]

		// Prepare request
		let meLibraryIndex = KKEndpoint.Me.Library.index.endpointValue
		let request: APIRequest<LibraryUpdateResponse, KKAPIError> = tron.codable.request(meLibraryIndex)
			.method(.post)
			.headers(headers)
			.parameters(parameters)

		// Send request
		return request.sender()
	}

	/// Remove an item with the given item id from the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryKind: From which library to delete the item.
	///    - modelID: The id of the model to be deleted.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get episode detail response.
	public func removeFromLibrary(_ libraryKind: KKLibrary.Kind, modelID: String) -> RequestSender<LibraryUpdateResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"model_id": modelID
		]

		// Prepare request
		let meLibraryDelete = KKEndpoint.Me.Library.delete.endpointValue
		let request: APIRequest<LibraryUpdateResponse, KKAPIError> = tron.codable.request(meLibraryDelete)
			.method(.post)
			.headers(headers)
			.parameters(parameters)

		// Send request
		return request.sender()
	}

	/// Import an exported library file into the authenticated user's library.
	///
	/// - Parameters:
	///    - libraryKind: To which library to import the file.
	///    - service: The preferred service for importing the file.
	///    - behavior: The preferred behavior of importing the file.
	///    - filePath: The path to the file to be imported.
	///
	/// - Returns: An instance of `RequestSender` with the results of the get episode detail response.
	public func importToLibrary(_ libraryKind: KKLibrary.Kind, importService service: LibraryImport.Service, importBehavior behavior: LibraryImport.Behavior, filePath: URL) -> RequestSender<KKSuccess, KKAPIError> {
		// Prepare headers
		var headers: HTTPHeaders = [
			.contentType("multipart/form-data"),
			.accept("application/json")
		]
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare parameters
		let parameters: [String: Any] = [
			"library": libraryKind.rawValue,
			"service": service.rawValue,
			"behavior": behavior.rawValue
		]

		// Prepare request
		let meLibraryImport = KKEndpoint.Me.Library.import.endpointValue
		let request: UploadAPIRequest<KKSuccess, KKAPIError> = tron.codable.uploadMultipart(meLibraryImport) { formData in
			formData.append(filePath, withName: "file", fileName: "LibraryImport.xml", mimeType: "text/xml")
		}
			.method(.post)
			.headers(headers)
			.parameters(parameters)

		// Send request
		return request.sender()
	}
}
