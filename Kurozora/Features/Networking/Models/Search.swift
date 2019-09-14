//
//  Search.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class Search: JSONDecodable {
	let success: Bool?
	let showResults: [ShowDetailsElement]?
	let threadResults: [ForumsThreadElement]?
	let userResults: [UserProfile]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue

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
