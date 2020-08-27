//
//  FeedMessageAttributesMetrics.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

extension FeedMessage.Attributes {
	/**
		A root object that stores information about a single feed message metrics, such as the message's total hearts, and weighted score.
	*/
	public struct Metrics: Codable {
		// MARK: - Properties
		/// The total count of hearts.
		public let count: Int

		/// The total weight of hearts.
		public let weight: Int

		/// The total number of hearts.
		public let hearts: Int
	}
}
