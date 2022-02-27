//
//  ShowSongDetails.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2022.
//

/**
	A root object that stores information about a collection of show songs.
*/
public struct ShowSongResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a show song object request.
	public let data: [ShowSong]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
