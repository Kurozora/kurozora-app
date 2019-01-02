//
//  User.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import TRON
import SwiftyJSON
import Kingfisher

class User: JSONDecodable {
    enum userType: Int {
        case normal = 0
        case mod
        case admin
    }
    
    let success: Bool?
	let message: String?
	let authToken: String?
    
    let id: Int?
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
    
    let rating: Double?
    
    let activeStart: String?
    let activeEnd: String?
    let active: Bool?
    
    required init(json: JSON) throws {
        success = json["success"].boolValue
		message = json["message"].stringValue
		authToken = json["kuro_auth_token"].stringValue
        
        id = json["user_id"].intValue
		sessionID = json["session_id"].intValue
        role = json["role"].intValue

        username = json["profile"]["username"].stringValue
        avatar = json["profile"]["avatar_url"].stringValue
        banner = json["profile"]["banner_url"].stringValue
        bio = json["profile"]["biography"].stringValue
        badges = json["profile"]["badges"].arrayValue
        proBadge = json["profile"]["pro_badge"].boolValue
        joinDate = json["profile"]["join_date"].stringValue
        
        followerCount = json["profile"]["follower_count"].intValue
        followingCount = json["profile"]["following_count"].intValue
        reputationCount = json["profile"]["reputation_count"].intValue
        postCount = json["profile"]["post_count"].intValue
        
        rating = json["rating"].doubleValue
        
        activeStart = json["profile"]["active_start"].stringValue
        activeEnd = json["profile"]["active_end"].stringValue
        active = json["profile"]["active"].boolValue
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
		return "authToken"
	}

	/// Returns the current user avatar from cache if available, otherwise returns default avatar
	static func currentUserAvatar() -> UIImage? {
		var image: UIImage?
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
            guard let type: userType = User.userType(rawValue: userType) else { return false }
            
            switch type {
            case .admin:
                return true
            default:
                return false
            }
        }
        return false
    }
    
//    func following() {
//        return self.relationForKey("following")
//    }
//
//    class func currentUserIsGuest() -> Bool {
//
//        return PFAnonymousUtils.isLinkedWithUser(User.currentUser())
//    }
    
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
    
//    func isAdmin() -> Bool {
//        return badges.contains("Admin") || isTopAdmin()
//    }
//
//    func isTopAdmin() -> Bool {
//        return badges.contains("Top Admin")
//    }
    
    // Don't ever name the function isCurrentUser it will conflict with Parse framework
//    func isTheCurrentUser() -> Bool {
//        guard let id1 = self.objectId, let currentUser = User.currentUser(), let id2 = currentUser.objectId else {
//            return false
//        }
//        return id1 == id2
//    }
    
    // Trial
//    func hasTrial() -> Bool {
//        return trialExpiration?.compare(Date()) == .orderedDescending
//    }
    
//    func followUser(user: User, follow: Bool) {
//
//        var incrementer = 0
//        if follow {
//            let followingRelation = following()
//            followingRelation.addObject(user)
//            incrementer = 1
//            PFCloud.callFunctionInBackground("sendFollowingPushNotificationV2", withParameters: ["toUser":user.objectId!])
//        } else {
//            let followingRelation = following()
//            followingRelation.removeObject(user)
//            incrementer = -1
//        }
//
//        user.followingThisUser = follow
//        user.details.incrementKey("followersCount", byAmount: incrementer)
//        user.saveInBackground()
//
//        details.incrementKey("followingCount", byAmount: incrementer)
//        saveInBackground()
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
}
