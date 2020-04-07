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

public class User: JSONDecodable {
	public let success: Bool?
	public let message: String?
	public let profile: UserProfile?

	public var current: CurrentUser? = nil

	// MARK: - Initializers
	public init() {
		success = nil
		message = nil
		profile = nil
	}

	required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.message = json["message"].stringValue
		self.profile = try? UserProfile(json: json["user"])
	}
}

public class CurrentUser: UserProfile {
	// MARK: - Properties
	public var sessionID: Int {
		guard let sessionID = KKServices.shared.KeychainDefaults["session_id"], !sessionID.isEmpty else { return 0 }
		return Int(sessionID) ?? 0
	}

	/// The object used to start and stop the delivery of location-related events to the app.
	fileprivate let locationManager = CLLocationManager()

	/// The coordinates of the current location of the user.
	fileprivate var currentUserLocation: CLLocationCoordinate2D {
		locationManager.requestWhenInUseAuthorization()

		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
			CLLocationManager.authorizationStatus() ==  .authorizedAlways {
			if let currentLocation: CLLocation = locationManager.location {
				try? KKServices.shared.KeychainDefaults.set("\(currentLocation.coordinate.latitude)", key: "latitude")
				try? KKServices.shared.KeychainDefaults.set("\(currentLocation.coordinate.longitude)", key: "longitude")
				return currentLocation.coordinate
			}
		}

		return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
	}

	public var latitude: Double {
		guard let latitudeString = KKServices.shared.KeychainDefaults["latitude"], !latitudeString.isEmpty,
			let latitude = Double(latitudeString) else { return currentUserLocation.latitude }
		return latitude
	}

	public var longitude: Double {
		guard let longitudeString = KKServices.shared.KeychainDefaults["longitude"], !longitudeString.isEmpty,
			let longitude = Double(longitudeString) else { return currentUserLocation.longitude }
		return longitude
	}

	public var deviceName: String {
		return UIDevice.modelName
	}

	// MARK: - Initializers
	public required init(json: JSON) throws {
		try super.init(json: json)
	}
}

public class UserProfile: JSONDecodable {
	// MARK: - Properties
	public let id: Int?
	public let role: Int?

	public let username: String?
	public let activityStatus: String?
	public let profileImage: String?
	public let banner: String?
	public let bio: String?
	public let badges: [BadgeElement]?
	public let proBadge: Bool?
	public let joinDate: String?

	public var followerCount: Int?
	public var followingCount: Int?
	public let reputationCount: Int?
	public let postCount: Int?

	public var following: Bool?
	public var currentRating: Double?
	public var watchedEpisodes: Int?
	public var libraryStatus: String?
	public var isFavorite: Bool?

	public let likeAction: Int?
	public let themeBought: Bool?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.role = json["role"].intValue

		self.username = json["username"].stringValue
		self.activityStatus = json["activity_status"].stringValue
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
extension User {
	/// Returns the Kurozora ID saved in KDefaults.
	static var kurozoraID: String {
		guard let kurozoraID = KKServices.shared.KeychainDefaults["kurozora_id"], !kurozoraID.isEmpty else { return "" }
		return kurozoraID
	}

	/// Returns the current User 'Sign In With Apple' ID saved in KDefaults.
	static var currentSIWAID: Int {
		guard let currentSIWAID = KKServices.shared.KeychainDefaults["SIWA_user"] else { return 0 }
		return Int(currentSIWAID) ?? 0
	}

	/// Returns the current user's Sign In With Apple ID Token saved in KDefaults.
	static var currentIDToken: String {
		guard let currentIDToken = KKServices.shared.KeychainDefaults["id_token"], !currentIDToken.isEmpty else { return ""}
		return currentIDToken
	}

	/// Returns the Auth Token saved in KDefaults.
	static var authToken: String {
		guard let authToken = KKServices.shared.KeychainDefaults["auth_token"], !authToken.isEmpty else { return "" }
		return authToken
	}

	/// Returns a boolean indicating if the current user is signed in.
	public static var isSignedIn: Bool {
		return User().current != nil
	}

	/// Returns a boolean indicating if the current user has purchased PRO.
	static var isPro: Bool {
		return true
	}
}
