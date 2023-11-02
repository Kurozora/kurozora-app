//
//  ReviewAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/07/2023.
//

extension Review {
	/// A root object that stores information about a single review, such as the review's score, and description.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The score of the review.
		public let score: Int

		/// The description of the review.
		public let description: String?

		/// The creation date of the review.
		public let createdAt: Date
	}
}
