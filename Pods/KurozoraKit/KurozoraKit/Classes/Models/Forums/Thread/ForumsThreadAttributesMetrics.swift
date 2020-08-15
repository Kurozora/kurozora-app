//
//  ForumsThreadAttributesMetrics.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

extension ForumsThread.Attributes {
	/**
		A root object that stores information about a single forums thread metrics, such as the thread's total likes, total dislikes and the weighted score.
	*/
	public struct Metrics: Codable {
		// MARK: - Properties
		/// The total count of likes and dislikes.
		public let count: Int

		/// The total weight of likes and dislikes.
		public let weight: Int

		/// The total number of likes.
		public let likes: Int

		/// The total number of dislikes.
		public let dislikes: Int
	}
}
