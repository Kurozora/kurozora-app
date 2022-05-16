//
//  KKAPIError.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 12/08/2020.
//

import TRON

/// An immutable object that stores information about a single failed request, such as the error message.
public class KKAPIError: APIError {
	// MARK: - Properties
	/// The errors included in the repsonse.
	fileprivate var kkErrors: [KKError] = []

	/// The message of a failed request.
	var _message: String?

	// MARK: - Initializers
	/// Initialize an error with the given `request` url, http `response`, `data` and `error`.
	///
	/// - Parameters:
	///    - request: A URL load request that is independent of protocol or URL scheme.
	///    - response: The metadata associated with the response to an HTTP protocol URL load request.
	///    - data: A byte buffer in memory.
	///    - error: A type representing an error value that can be thrown.
	required public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
		super.init(request: request, response: response, data: data, error: error)
		self.processData()
	}

	/// Initialize an error with the given `request` url, http `response`, `fileURL` and `error`.
	///
	/// - Parameters:
	///    - request: A URL load request that is independent of protocol or URL scheme.
	///    - response: The metadata associated with the response to an HTTP protocol URL load request.
	///    - fileURL: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
	///    - error: A type representing an error value that can be thrown.
	required public init(request: URLRequest?, response: HTTPURLResponse?, fileURL: URL?, error: Error?) {
		super.init(request: request, response: response, fileURL: fileURL, error: error)
		self.processData()
	}

	// MARK: - Functions
	/// Processes the received data into a usable info by extracting the errors from the response.
	fileprivate func processData() {
		if let data = self.data {
			do {
				let decodedJSON = try JSONDecoder().decode(KKErrorResponse.self, from: data)
				self.kkErrors = decodedJSON.errors
				print("❌ Received errors:", self.kkErrors)
			} catch {
				print("❌ Decode error:", error.localizedDescription)
			}
		}

		guard self.message == nil else { return }
		if let responseCode = error?.asAFError?.responseCode {
			switch responseCode {
			default:
				self._message = "There was an error while connecting to the server. If this error persists, check out our Twitter account @KurozoraApp for more information!"
			}
		}
	}
}

// MARK: - Helpers
extension KKAPIError {
	// MARK: - Properties
	/// The message of a failed request.
	var message: String? {
		return self._message ?? kkErrors.first?.detail
	}
}
