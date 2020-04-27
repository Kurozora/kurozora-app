//
//  EpisodeUserDetails.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single user's details, such as the watch status of the episode.
*/
public class EpisodeUserDetails: JSONDecodable {
	// MARK: - Properties
	/// The watch status of the episode.
	public var watchStatus: WatchStatus?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.watchStatus = WatchStatus(rawValue: json["watched"].intValue)
	}
}
