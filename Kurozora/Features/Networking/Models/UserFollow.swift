//
//  UserFollow.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

class UserFollow: JSONDecodable {
	let success: Bool?
	let currentPage: Int?
	let lastPage: Int?
	let followers: [UserProfile]?
	let following: [UserProfile]?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.currentPage = json["page"].intValue
		self.lastPage = json["last_page"].intValue

		var followers = [UserProfile]()
		let followersArray = json["followers"].arrayValue
		for followerItem in followersArray {
			if let followerElement = try? UserProfile(json: followerItem) {
				followers.append(followerElement)
			}
		}
		self.followers = followers

		var followings = [UserProfile]()
		let followingsArray = json["following"].arrayValue
		for followingItem in followingsArray {
			if let followingElement = try? UserProfile(json: followingItem) {
				followings.append(followingElement)
			}
		}
		self.following = followings
	}
}
