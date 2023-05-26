//
//  SearchSuggestionsResponse.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2023.
//

/// A root object that stores information about a collection of searche suggestions.
public struct SearchSuggestionsResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a search suggesion object request.
	public let data: [String]
}
