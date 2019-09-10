//
//  User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import TRON
import SwiftyJSON
import Kingfisher
import CoreLocation

class User: JSONDecodable {
	let success: Bool?
	let message: String?

	let rating: Double?
	let currentlyFollowing: Bool?
	let profile: UserProfile?

	required init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.message = json["message"].stringValue

		self.rating = json["rating"].doubleValue
		self.currentlyFollowing = json["currently_following"].boolValue
		self.profile = try? UserProfile(json: json["user"])
	}
}

class UserProfile: JSONDecodable {
	let id: Int?
	let authToken: String?
	let sessionID: Int?
	let role: Int?

	let username: String?
	let avatar: String?
	let banner: String?
	let bio: String?
	let badges: [BadgeElement]?
	let proBadge: Bool?
	let joinDate: String?

	let followerCount: Int?
	let followingCount: Int?
	let reputationCount: Int?
	let postCount: Int?

	let activeStart: String?
	let activeEnd: String?
	let active: Bool?

	let currentRating: Double?
	var libraryStatus: String?

	let themeBought: Bool?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.authToken = json["kuro_auth_token"].stringValue
		self.sessionID = json["session_id"].intValue
		self.role = json["role"].intValue

		self.username = json["username"].stringValue
		self.avatar = json["avatar_url"].stringValue
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

		self.currentRating = json["current_rating"].doubleValue
		self.libraryStatus = json["library_status"].stringValue

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
//    class func logoutMyAnimeList() {
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

// MARK: - User variables
extension User {
	/// The object used to start and stop the delivery of location-related events to the app.
	fileprivate static let locationManager = CLLocationManager()

	/// Returns the username saved in KDefaults
	static var username: String? {
		guard let username = GlobalVariables().KDefaults["username"], !username.isEmpty else { return nil }
		return username
	}

	/// Returns the current User ID saved in KDefaults
	static var currentID: Int? {
		guard let userID = GlobalVariables().KDefaults["user_id"], !userID.isEmpty else { return nil }
		return Int(userID)
	}

	/// Returns the Auth Token saved in KDefaults
	static var authToken: String {
		guard let authToken = GlobalVariables().KDefaults["auth_token"], !authToken.isEmpty else { return "" }
		return authToken
	}

	/// The coordinates of the current location of the user.
	fileprivate static var currentUserLocation: CLLocationCoordinate2D {
		locationManager.requestWhenInUseAuthorization()

		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
			CLLocationManager.authorizationStatus() ==  .authorizedAlways {
			if let currentLocation: CLLocation = locationManager.location {
				try? GlobalVariables().KDefaults.set("\(currentLocation.coordinate.latitude)", key: "latitude")
				try? GlobalVariables().KDefaults.set("\(currentLocation.coordinate.longitude)", key: "longitude")
				return currentLocation.coordinate
			}
		}

		return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
	}

	/// Returns the user's latitude saved in KDefaults
	static var latitude: Double {
		guard let latitudeString = GlobalVariables().KDefaults["latitude"], !latitudeString.isEmpty,
			let latitude = Double(latitudeString) else { return currentUserLocation.latitude }
		return latitude
	}

	/// Returns the user's longitude saved in KDefaults
	static var longitude: Double {
		guard let longitudeString = GlobalVariables().KDefaults["longitude"], !longitudeString.isEmpty,
			let longitude = Double(longitudeString) else { return currentUserLocation.longitude }
		return longitude
	}

	/// Returns the current user avatar from cache if available, otherwise returns default avatar
	static var currentUserAvatar: UIImage? {
		var image = UIImage(named: "default_avatar")
		let cache = ImageCache.default

		cache.retrieveImage(forKey: "currentUserAvatar", options: [], callbackQueue: .mainCurrentOrAsync) { (result) in
			switch result {
			case .success(let value):
				// If the `cacheType is `.none`, `image` will be `nil`.
				if value.cacheType == .none {
					image = #imageLiteral(resourceName: "default_avatar")
				} else {
					image = value.image
				}
			case .failure(let error):
				print(error)
				image = #imageLiteral(resourceName: "default_avatar")
			}
		}

		return image
	}

	/// Returns the current Session ID saved in KDefaults
	static var currentSessionID: Int? {
		guard let sessionID = GlobalVariables().KDefaults["session_id"], !sessionID.isEmpty else { return nil }
		return Int(sessionID)
	}

	/// Returns the current device name
	static var currentDevice: String {
		return UIDevice.modelName
	}

	/// Returns a boolean indicating if the current user is logged in
	static var isLoggedIn: Bool {
		return User.username != nil
	}

	/// Returns a boolean indicating if the current user has purchased PRO
	static var isPro: Bool {
		return true
	}

	/// Returns a boolean indicating if the current user is an admin
	static var isAdmin: Bool {
		if let userType = GlobalVariables().KDefaults["user_role"], !userType.isEmpty {
			guard let userType = Int(userType) else { return false }
			guard let type: UserType = UserType(rawValue: userType) else { return false }

			switch type {
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
		if let userType = GlobalVariables().KDefaults["user_role"], !userType.isEmpty {
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
