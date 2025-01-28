//
//  RelatedLiterature.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/01/2023.
//

/// A root object that stores information about a related literature resource.
public struct RelatedLiterature: Codable, Hashable, Sendable {
	// MARK: - Properties
	/// The id of the related literature.
	public let id: UUID = UUID()

	/// The literature related to the parent literature.
	public let literature: Literature

	/// The attributes belonging to the related literature.
	public var attributes: RelatedLiterature.Attributes

	// MARK: - CodingKeys
	enum CodingKeys: String, CodingKey {
		case literature
		case attributes
	}

	// MARK: - Functions
	public static func == (lhs: RelatedLiterature, rhs: RelatedLiterature) -> Bool {
		return lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}
