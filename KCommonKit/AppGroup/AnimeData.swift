//
//  AnimeData.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation

public class AnimeData: NSObject, NSCoding {
	public var title = ""
	public var firstAired = Date()
	public var currentEpisode = 1
	public var episodes = 1
	public var status = AnimeStatus.notYetAired

	public init(title: String, firstAired: Date, currentEpisode: Int, episodes: Int, status: AnimeStatus) {
		self.title = title
		self.firstAired = firstAired
		self.currentEpisode = currentEpisode
		self.episodes = episodes
		self.status = status
		super.init()
	}

	required public init?(coder aDecoder: NSCoder) {

		guard
			let title = aDecoder.decodeObject(forKey: "title") as? String,
			let firstAired = aDecoder.decodeObject(forKey: "firstAired") as? Date,
			let currentEpisode = aDecoder.decodeObject(forKey: "currentEpisode") as? Int,
			let episodes = aDecoder.decodeObject(forKey: "episodes") as? Int,
			let status = aDecoder.decodeObject(forKey: "status") as? String
			else {
				super.init()
				return nil
		}

		self.title = title
		self.firstAired = firstAired
		self.currentEpisode = currentEpisode
		self.episodes = episodes
		self.status = AnimeStatus(rawValue: status) ?? .notYetAired

		super.init()
	}

	public func encode(with aCoder: NSCoder) {
		aCoder.encode(title, forKey: "title")
		aCoder.encode(firstAired, forKey: "firstAired")
		aCoder.encode(currentEpisode, forKey: "currentEpisode")
		aCoder.encode(episodes, forKey: "episodes")
		aCoder.encode(status.rawValue, forKey: "status")
	}
}
