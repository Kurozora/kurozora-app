//
//  UserRating.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/06/2021.
//

/// A root object that stores information about a show's user rating.
public struct UserRating: Codable {
	/// The list of ratings per star.
	public let ratingCountList: [Int]

	/// The average rating of the show.
	public let averageRating: Double

	/// The number of ratings the show accumulated.
	public let ratingCount: Int
}
