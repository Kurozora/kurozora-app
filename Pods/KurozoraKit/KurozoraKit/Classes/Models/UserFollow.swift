//
//  UserFollow.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of follow lists, such as the follow list's current page number, and last page number.
*/
public class UserFollow: JSONDecodable {
	// MARK: - Properties
	/// The current page number of the follow list.
	public let currentPage: Int?

	/// The last page number of the follow list.
	public let lastPage: Int?

	/// The collection of followers list.
	public let followers: [UserProfile]?

	/// The collection of following list.
	public let following: [UserProfile]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
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
