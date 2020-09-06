//
//  FeedMessageAttributesMetrics.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

extension FeedMessage.Attributes {
	/**
		A root object that stores information about a single feed message metrics, such as the message's total hearts count, and replies count.
	*/
	public struct Metrics: Codable {
		// MARK: - Properties
		/// The total number of hearts.
		public var heartCount: Int

		/// The total number of replies.
		public var replyCount: Int

		/// The total number of re-shares.
		public var reShareCount: Int
	}
}
