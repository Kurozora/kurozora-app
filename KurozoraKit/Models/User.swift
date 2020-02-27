//
//  User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import CoreLocation
import Kingfisher
import SwiftyJSON
import TRON

class User: JSONDecodable {
	let success: Bool?
	let message: String?
	let profile: UserProfile?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.message = json["message"].stringValue
		self.profile = try? UserProfile(json: json["user"])
	}
}

class UserProfile: JSONDecodable {
	let id: Int?
	let role: Int?

	let username: String?
	let profileImage: String?
	let banner: String?
	let bio: String?
	let badges: [BadgeElement]?
	let proBadge: Bool?
	let joinDate: String?

	var followerCount: Int?
	var followingCount: Int?
	let reputationCount: Int?
	let postCount: Int?

	let activeStart: String?
	let activeEnd: String?
	let active: Bool?

	var following: Bool?
	var currentRating: Double?
	var watchedEpisodes: Int?
	var libraryStatus: String?
	var isFavorite: Bool?

	let likeAction: Int?
	let themeBought: Bool?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.role = json["role"].intValue

		self.username = json["username"].stringValue
		self.profileImage = json["avatar_url"].stringValue
		self.banner = json["banner_url"].stringValue
		self.bio = json["biography"].stringValue
		var badges = [BadgeElement]()

		let badgesArray = json["badges"].arrayValue
		for badgeItem in badgesArray {
			if let badgeElement = try? BadgeElement(json: badgeItem) {
				badges.append(badgeElement)
			}
		}

		self.badges = badges
		self.proBadge = json["pro_badge"].boolValue
		self.joinDate = json["join_date"].stringValue

		self.followerCount = json["follower_count"].intValue
		self.followingCount = json["following_count"].intValue
		self.reputationCount = json["reputation_count"].intValue
		self.postCount = json["post_count"].intValue

		self.activeStart = json["active_start"].stringValue
		self.activeEnd = json["active_end"].stringValue
		self.active = json["active"].boolValue

		self.following = json["current_user", "following"].boolValue
		self.currentRating = json["given_rating"].doubleValue
		self.watchedEpisodes = json["watched_episodes"].intValue
		self.libraryStatus = json["library_status"].stringValue
		self.isFavorite = json["is_favorite"].boolValue

		self.likeAction = json["like_action"].intValue
		self.themeBought = json["theme_bought"].boolValue
	}
}

// MARK: - Properties
//extension User {
//	/// The object used to start and stop the delivery of location-related events to the app.
//	fileprivate static let locationManager = CLLocationManager()
//
//	/// Returns the username saved in KDefaults.
//	static var username: String {
//		guard let username = Kurozora.shared.KDefaults["username"], !username.isEmpty else { return "" }
//		return username
//	}
//
//	/// Returns the profile image saved in KDefaults.
//	static var profileImage: String {
//		guard let profileImage = Kurozora.shared.KDefaults["profile_image"], !profileImage.isEmpty else { return "" }
//		return profileImage
//	}
//
//	/// Returns the Kurozora ID saved in KDefaults.
//	static var kurozoraID: String {
//		guard let kurozoraID = Kurozora.shared.KDefaults["kurozora_id"], !kurozoraID.isEmpty else { return "" }
//		return kurozoraID
//	}
//
//	/// Returns the current User ID saved in KDefaults.
//	static var currentID: Int {
//		guard let userID = Kurozora.shared.KDefaults["user_id"]?.int else { return 0 }
//		return userID
//	}
//
//	/// Returns the current User 'Sign In With Apple' ID saved in KDefaults.
//	static var currentSIWAID: Int {
//		guard let currentSIWAID = Kurozora.shared.KDefaults["SIWA_user"]?.int else { return 0 }
//		return currentSIWAID
//	}
//
//	/// Returns the current User ID Token saved in KDefaults.
//	static var currentIDToken: String {
//		guard let currentIDToken = Kurozora.shared.KDefaults["id_token"], !currentIDToken.isEmpty else { return ""}
//		return currentIDToken
//	}
//
//	/// Returns the Auth Token saved in KDefaults.
//	static var authToken: String {
//		guard let authToken = Kurozora.shared.KDefaults["auth_token"], !authToken.isEmpty else { return "" }
//		return authToken
//	}
//
//	/// The coordinates of the current location of the user.
//	fileprivate static var currentUserLocation: CLLocationCoordinate2D {
//		locationManager.requestWhenInUseAuthorization()
//
//		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//			CLLocationManager.authorizationStatus() ==  .authorizedAlways {
//			if let currentLocation: CLLocation = locationManager.location {
//				try? Kurozora.shared.KDefaults.set("\(currentLocation.coordinate.latitude)", key: "latitude")
//				try? Kurozora.shared.KDefaults.set("\(currentLocation.coordinate.longitude)", key: "longitude")
//				return currentLocation.coordinate
//			}
//		}
//
//		return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
//	}
//
//	/// Returns the user's latitude saved in KDefaults.
//	static var latitude: Double {
//		guard let latitudeString = Kurozora.shared.KDefaults["latitude"], !latitudeString.isEmpty,
//			let latitude = Double(latitudeString) else { return currentUserLocation.latitude }
//		return latitude
//	}
//
//	/// Returns the user's longitude saved in KDefaults.
//	static var longitude: Double {
//		guard let longitudeString = Kurozora.shared.KDefaults["longitude"], !longitudeString.isEmpty,
//			let longitude = Double(longitudeString) else { return currentUserLocation.longitude }
//		return longitude
//	}
//
//	/// Returns the current Session ID saved in KDefaults
//	static var currentSessionID: Int? {
//		guard let sessionID = Kurozora.shared.KDefaults["session_id"], !sessionID.isEmpty else { return nil }
//		return Int(sessionID)
//	}
//
//	/// Returns the current device name
//	static var currentDevice: String {
//		return UIDevice.modelName
//	}
//
//	/// Returns a boolean indicating if the current user is signed in.
//	static var isSignedIn: Bool {
//		return !User.kurozoraID.isEmpty
//	}
//
//	/// Returns a boolean indicating if the current user has purchased PRO.
//	static var isPro: Bool {
//		return true
//	}
//}
