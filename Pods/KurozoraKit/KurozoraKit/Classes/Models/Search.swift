//
//  Search.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of search results.
*/
public class Search: JSONDecodable {
	// MARK: - Properties
	/// The collection of shows in the search result.
	public let showResults: [ShowDetailsElement]?

	/// The collection of threads in the search result.
	public let threadResults: [ForumsThreadElement]?

	/// The collection of users in the search result.
	public let userResults: [UserProfile]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		var showResults = [ShowDetailsElement]()
		let showResultsArray = json["results"].arrayValue
		for showResultsItem in showResultsArray {
			if let searchElement = try? ShowDetailsElement(json: showResultsItem) {
				showResults.append(searchElement)
			}
		}
		self.showResults = showResults

		var threadResults = [ForumsThreadElement]()
		let threadResultsArray = json["results"].arrayValue
		for threadResultsItem in threadResultsArray {
			if let searchElement = try? ForumsThreadElement(json: threadResultsItem) {
				threadResults.append(searchElement)
			}
		}
		self.threadResults = threadResults

		var userResults = [UserProfile]()
		let userResultsArray = json["results"].arrayValue
		for userResultsItem in userResultsArray {
			if let searchElement = try? UserProfile(json: userResultsItem) {
				userResults.append(searchElement)
			}
		}
		self.userResults = userResults
	}
}
