//
//  SearchResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 22/05/2022.
//

/// A root object that stores information about a collection of searches.
public struct SearchResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a search object request.
	public let data: Search
}
