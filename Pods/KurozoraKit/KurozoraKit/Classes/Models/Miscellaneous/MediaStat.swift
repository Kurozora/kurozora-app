//
//  MediaStat.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 20/11/2021.
//

/// A root object that stores information about a media stat resource.
public struct MediaStat: Codable {
	// MARK: - Properties
	/// The count of ratings sorted from `0.5` to `5.0`.
	public let ratingCountList: [Int]

	/// The average of all ratings.
	public let ratingAverage: Double

	/// The total count of all ratings.
	public let ratingCount: Int

	/// The rank compared to all other models.
	public let rankGlobal: Int

	/// The rank compared to resources of the same model.
	public let rankTotal: Int

	/// The collective user sentiment.
	public let sentiment: String

	/// The percentage of the highest rating compared to the total rating.
	public let highestRatingPercentage: Double
}
