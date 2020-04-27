//
//  KKError.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	An immutable object that stores information about a single failed request, such as the error message.
*/
public class KKError: ErrorSerializable {
	// MARK: - Properties
	/// The message of a failed request.
	public var message: String?

	// MARK: - Initializers
	/**
		Initialize an error with the given `request` url, http `response`, `data` and `error`.

		- Parameter request: A URL load request that is independent of protocol or URL scheme.
		- Parameter response: The metadata associated with the response to an HTTP protocol URL load request.
		- Parameter data: A byte buffer in memory.
		- Parameter error: A type representing an error value that can be thrown.
	*/
	required public init(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
		if let data = data {
			if let jsonFromData = try? JSON(data: data) {
				self.message = jsonFromData["error_message"].stringValue
				return
			}
		}

		if let responseCode = error?.asAFError?.responseCode {
			switch responseCode {
			case 401:
				self.message = "Session expired"
//				WorkflowController.shared.signOut()
			case 404:
				self.message = "API not found!"
			case 429:
				self.message = "You have sent too many requests. Please try again in a minute."
			default:
				self.message = "There was an error while connecting to the server. If this error persists, check out our Twitter account @KurozoraApp for more information!"
			}
		}
	}
}
