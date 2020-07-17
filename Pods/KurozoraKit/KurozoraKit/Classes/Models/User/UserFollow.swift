//
//  UserFollow.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a collection of follow lists, such as the follow list's next page url, and collection of followers it contains.
*/
public class UserFollow: JSONDecodable {
	// MARK: - Properties
	/// The URL to the next page in the paginated response.
	public let nextPageURL: String?

	/// The collection of followers list.
	public let followers: [UserProfile]?

	/// The collection of following list.
	public let following: [UserProfile]?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.nextPageURL = json["next"].stringValue

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
