//
//  Media.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/08/2020.
//

/// A root object that stores information about a media resource.
public struct Media: Codable, Sendable {
	// MARK: - Properties
	/// The url of the media.
	public let url: String

	/// The height of the media.
	public let height: Int?

	/// The width of the media.
	public let width: Int?

	/// The background color of the media.
	public let backgroundColor: String?

	/// The primary text color of the media.
	public let textColor1: String?

	/// The secondary text color of the media.
	public let textColor2: String?

	/// The tertiary text color of the media.
	public let textColor3: String?

	/// The quaternary text color of the media.
	public let textColor4: String?

	/// The relationships belonging to the media.
	public let relationships: Media.Relationships?
}
