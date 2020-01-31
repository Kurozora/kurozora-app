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
	let authToken: String?
	let sessionID: Int?
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
		self.authToken = json["kuro_auth_token"].stringValue
		self.sessionID = json["session_id"].intValue
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

//    var myAnimeListPassword: String? {
//        get {
//            return UserDefaults.standard.object(forKey: User.MyAnimeListPasswordKey) as! String?
//        }
//        set(object) {
//            UserDefaults.standard.set(object, forKey: User.MyAnimeListPasswordKey)
//            UserDefaults.standard.synchronize()
//        }
//    }
//    
//    class func signOutMyAnimeList() {
//        UserDefaults.standard.removeObject(forKey: User.MyAnimeListPasswordKey)
//        UserDefaults.standard.synchronize()
//    }

//    class func syncingWithMyAnimeList() -> Bool {
//        guard let user = User.currentUser() else {
//            return false
//        }
//        return user.myAnimeListPassword != nil
//    }
//
//    func incrementPostCount(byAmount: Int) {
//        details.incrementKey("posts", byAmount: byAmount)
//        details.saveInBackground()
//    }

// Trial
//    func hasTrial() -> Bool {
//        return trialExpiration?.compare(Date()) == .orderedDescending
//    }

// Muting
//    class func muted(viewController: UIViewController) -> Bool {
//        guard let currentUser = User.currentUser() else {
//            return false
//        }

//        var mutedUntil: Date?

//        do {
//            let details = try currentUser.details.fetchIfNeeded()
//            mutedUntil = details.mutedUntil

//        } catch _ { }

//        guard let muteDate = mutedUntil else {
//            return false
//        }

//        if muteDate.compare(Date()) == ComparisonResult.orderedAscending  {
//            currentUser.details.mutedUntil = nil
//            currentUser.saveInBackground()
//            return false
//        }

//        viewController.presentBasicAlertWithTitle(title: "Account muted", message: "Until \(muteDate.mediumDateTime()).\nContact admins for more information.")
//        return true
//    }

// MARK: - Properties
extension User {
	/// The object used to start and stop the delivery of location-related events to the app.
	fileprivate static let locationManager = CLLocationManager()

	/// Returns the username saved in KDefaults
	static var username: String {
		guard let username = Kurozora.shared.KDefaults["username"], !username.isEmpty else { return "" }
		return username
	}

	/// Returns the current User ID saved in KDefaults.
	static var currentID: Int {
		guard let userID = Kurozora.shared.KDefaults["user_id"]?.int else { return 0 }
		return userID
	}

	/// Returns the current User 'Sign In With Apple' ID saved in KDefaults.
	static var currentSIWAID: Int {
		guard let currentSIWAID = Kurozora.shared.KDefaults["SIWA_user"]?.int else { return 0 }
		return currentSIWAID
	}

	/// Returns the current User ID Token saved in KDefaults.
	static var currentIDToken: String {
		guard let currentIDToken = Kurozora.shared.KDefaults["id_token"], !currentIDToken.isEmpty else { return ""}
		return currentIDToken
	}

	/// Returns the Auth Token saved in KDefaults.
	static var authToken: String {
		guard let authToken = Kurozora.shared.KDefaults["auth_token"], !authToken.isEmpty else { return "" }
		return authToken
	}

	/// The coordinates of the current location of the user.
	fileprivate static var currentUserLocation: CLLocationCoordinate2D {
		locationManager.requestWhenInUseAuthorization()

		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
			CLLocationManager.authorizationStatus() ==  .authorizedAlways {
			if let currentLocation: CLLocation = locationManager.location {
				try? Kurozora.shared.KDefaults.set("\(currentLocation.coordinate.latitude)", key: "latitude")
				try? Kurozora.shared.KDefaults.set("\(currentLocation.coordinate.longitude)", key: "longitude")
				return currentLocation.coordinate
			}
		}

		return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
	}

	/// Returns the user's latitude saved in KDefaults
	static var latitude: Double {
		guard let latitudeString = Kurozora.shared.KDefaults["latitude"], !latitudeString.isEmpty,
			let latitude = Double(latitudeString) else { return currentUserLocation.latitude }
		return latitude
	}

	/// Returns the user's longitude saved in KDefaults
	static var longitude: Double {
		guard let longitudeString = Kurozora.shared.KDefaults["longitude"], !longitudeString.isEmpty,
			let longitude = Double(longitudeString) else { return currentUserLocation.longitude }
		return longitude
	}

	/// Returns the current user profile image from cache if available, otherwise returns default profile image
	static var currentUserProfileImage: UIImage {
		var profileImage = username.initials.toImage(placeholder: #imageLiteral(resourceName: "default_profile_image"))

		ImageCache.default.retrieveImage(forKey: "currentUserProfileImage", options: [], callbackQueue: .mainCurrentOrAsync) { (result) in
			switch result {
			case .success(let cacheResult):
				// If the `cacheType is `.none`, `image` will be `nil`.
				if cacheResult.cacheType != .none {
					profileImage = cacheResult.image ?? profileImage
				}
			case .failure(let error):
				print("Received image cache error: \(error.localizedDescription)")
			}
		}

		return profileImage
	}

	/// Returns the current Session ID saved in KDefaults
	static var currentSessionID: Int? {
		guard let sessionID = Kurozora.shared.KDefaults["session_id"], !sessionID.isEmpty else { return nil }
		return Int(sessionID)
	}

	/// Returns the current device name
	static var currentDevice: String {
		return UIDevice.modelName
	}

	/// Returns a boolean indicating if the current user is signed in
	static var isSignedIn: Bool {
		return User.username != ""
	}

	/// Returns a boolean indicating if the current user has purchased PRO
	static var isPro: Bool {
		return true
	}

	/// Returns a boolean indicating if the current user is an admin
	static var isAdmin: Bool {
		if let userTypeString = Kurozora.shared.KDefaults["user_role"], !userTypeString.isEmpty {
			guard let userTypeInt = Int(userTypeString) else { return false }
			guard let userType: UserType = UserType(rawValue: userTypeInt) else { return false }

			switch userType {
			case .admin:
				return true
			default:
				return false
			}
		}
		return false
	}

	/// Returns a boolean if the current user is a mod
	static var isMod: Bool {
		if let userType = Kurozora.shared.KDefaults["user_role"], !userType.isEmpty {
			guard let userType = Int(userType) else { return false }
			guard let type: UserType = UserType(rawValue: userType) else { return false }

			switch type {
			case .mod:
				return true
			default:
				return false
			}
		}
		return false
	}
}

// MARK: - Functions
extension User {
	/**
		Removes and adds the current user's profile image to the cache.

		- Parameter image: The image to add to the cache.
	*/
	static func refreshProfileImage(with image: UIImage?) {
		// Clear cache for user profile image.
		removeProfileImage()

		// Add new image to cache.
		if let profileImage = image {
			KingfisherManager.shared.cache.store(profileImage, forKey: "currentUserProfileImage")
		}
	}

	/// Removes the current user's profile image from the cache.
	static func removeProfileImage() {
		KingfisherManager.shared.cache.removeImage(forKey: "currentUserProfileImage")
	}
}
