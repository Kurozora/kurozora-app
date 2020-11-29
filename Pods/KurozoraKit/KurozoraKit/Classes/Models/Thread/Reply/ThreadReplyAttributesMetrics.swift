//
//  ThreadReplyAttributesMetrics.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

extension ThreadReply.Attributes {
	/**
		A root object that stores information about a single thread reply metrics, such as the reply's total likes, total dislikes and the weighted score.
	*/
	public struct Metrics: Codable {
		// MARK: - Properties
		/// The total count of likes and dislikes.
		public var count: Int

		/// The total weight of likes and dislikes.
		public var weight: Int

		/// The total number of likes.
		public var likes: Int

		/// The total number of dislikes.
		public var dislikes: Int
	}
}

