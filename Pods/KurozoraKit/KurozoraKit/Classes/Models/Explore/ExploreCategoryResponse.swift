//
//  ExploreCategoryResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 14/08/2020.
//

/// A root object that stores information about a collection of explore category.
public struct ExploreCategoryResponse: Codable, Sendable {
	// MARK: - Properties
	/// The data included in the response for an explore category object request.
	public let data: [ExploreCategory]
}
