//
//  RelatedShow.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/**
	A root object that stores information about a related show resource.
*/
public struct RelatedShow: Codable {
	// MARK: - Properties
	/// The show related to the parent show.
	public let show: Show

	/// The attributes belonging to the related show.
	public var attributes: RelatedShow.Attributes
}
