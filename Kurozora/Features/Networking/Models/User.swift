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

class User: JSONDecodable {
    let success: Bool?
	let message: String?

	let rating: Double?
	let currentlyFollowing: Bool?
	let user: UserProfile?
    
    required init(json: JSON) throws {
        self.success = json["success"].boolValue
		self.message = json["message"].stringValue

		self.rating = json["rating"].doubleValue
		self.currentlyFollowing = json["currently_following"].boolValue
		self.user = try? UserProfile(json: json["user"])
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
	let badges: [JSON]?
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
	let libraryStatus: String?

	required init(json: JSON) throws {
		self.id = json["id"].intValue
		self.authToken = json["kuro_auth_token"].stringValue
		self.sessionID = json["session_id"].intValue
		self.role = json["role"].intValue

		self.username = json["username"].stringValue
		self.avatar = json["avatar_url"].stringValue
		self.banner = json["banner_url"].stringValue
		self.bio = json["biography"].stringValue
		self.badges = json["badges"].arrayValue
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

extension User {
	enum UserType: Int {
		case normal = 0
		case mod
		case admin
	}

	/// Returns the username saved in KDefaults
	static func username() -> String? {
		if let username = GlobalVariables().KDefaults["username"], username != "" {
			return username
		}
		return nil
	}

	/// Returns the current User ID saved in KDefaults
	static func currentID() -> Int? {
		if let userID = GlobalVariables().KDefaults["user_id"], userID != "" {
			return Int(userID)
		}
		return nil
	}

	/// Returns the Auth Token saved in KDefaults
	static func authToken() -> String {
		if let authToken = GlobalVariables().KDefaults["auth_token"], authToken != "" {
			return authToken
		}
		return ""
	}

	/// Returns the current user avatar from cache if available, otherwise returns default avatar
	static func currentUserAvatar() -> UIImage? {
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
	static func currentSessionID() -> Int? {
		if let sessionID = GlobalVariables().KDefaults["session_id"], sessionID != "" {
			return Int(sessionID)
		}
		return nil
	}

	/// Returns the current device name
	static func currentDevice() -> String? {
		return UIDevice.modelName
	}

	/// Returns true if current user is logged in
	static func isLoggedIn() -> Bool? {
		return User.username() != nil
	}

	/// Returns true is the current user is PRO
	static func isPro() -> Bool? {
		return true
	}

	/// Returns true if the current user is an admin
	static func isAdmin() -> Bool? {
		if let userType = GlobalVariables().KDefaults["user_role"], userType != "" {
			guard let userType = Int(userType) else { return false }
			guard let type: UserType = User.UserType(rawValue: userType) else { return false }

			switch type {
			case .admin:
				return true
			default:
				return false
			}
		}
		return false
	}

	/// Returns true if the current user is a mod
	static func isMod() -> Bool? {
		if let userType = GlobalVariables().KDefaults["user_role"], userType != "" {
			guard let userType = Int(userType) else { return false }
			guard let type: UserType = User.UserType(rawValue: userType) else { return false }

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
