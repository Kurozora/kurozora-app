//
//  RecapItemAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/01/2024.
//

extension RecapItem {
	/// A root object that stores information about a single recap item, such as the recap item's year, and type.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The year of the recap.
		public let year: Int

		/// The type of the recap.
		public let type: String

		/// The total series count of the recap type.
		public let totalSeriesCount: Int

		/// The total parts count of the recap type.
		public let totalPartsCount: Int

		/// The total parts duration of the recap type.
		public let totalPartsDuration: Int

		/// The top percentile of the recap type.
		public let topPercentile: String
	}
}

// MARK: - Helpers
extension RecapItem.Attributes {
	/// The type of the recap item.
	public var recapItemType: RecapItemType {
		return RecapItemType(rawValue: self.type) ?? .shows
	}
}
