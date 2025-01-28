//
//  SearchSuggestionsResponse.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2023.
//

/// A root object that stores information about a collection of search suggestions.
public struct SearchSuggestionsResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for a search suggestion object request.
	public let data: [String]
}
