//
//  RelatedShow.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/**
	A root object that stores information about a related show resource.
*/
public struct RelatedShow: Codable, Hashable {
	// MARK: - Properties
	/// The id of the related show.
	public let id: UUID = UUID()

	/// The show related to the parent show.
	public let show: Show

	/// The attributes belonging to the related show.
	public var attributes: RelatedShow.Attributes

	// MARK: - Enums
	/**
		The keys to encode and decode.

		Necessary since UUID shouldn't be a codable property.
	*/
	enum CodingKeys: String, CodingKey {
		/// The key of the `show` property.
		case show

		/// The key of the `attributes` property.
		case attributes
	}

	// MARK: - Functions
	public static func == (lhs: RelatedShow, rhs: RelatedShow) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
