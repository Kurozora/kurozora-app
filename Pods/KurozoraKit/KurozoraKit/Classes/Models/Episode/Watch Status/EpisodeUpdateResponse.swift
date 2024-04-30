//
//  EpisodeUpdateResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/08/2020.
//

/// A root object that stores information about an episode's update.
public struct EpisodeUpdateResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for an episode update object request.
	public let data: EpisodeUpdate
}
