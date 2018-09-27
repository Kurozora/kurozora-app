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

struct User: JSONDecodable {
    enum userType: Int {
        case normal = 0
        case mod
        case admin
    }
    
    let success: Bool?
    let message: String?
    let role: Int?
    
    let id: Int?
    let session: String?
//    let sessionArray: [JSON]?
    let username: String?
    let avatar: String?
    let banner: String?
    let bio: String?
    let badges: [String]?
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
    
    init(json: JSON) {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        
        id = json["user_id"].intValue
        session = json["session_secret"].stringValue
        role = json["role"].intValue

//        sessionArray = json["sessions"].arrayValue
        username = json["profile"]["username"].stringValue
        avatar = json["profile"]["avatar_url"].stringValue
        banner = json["profile"]["banner_url"].stringValue
        bio = json["profile"]["biography"].stringValue
        badges = json["profile"]["badges"].rawValue as? [String]
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
    
    static func username() -> String? {
        if let username = GlobalVariables().KDefaults["username"], username != "" {
            return username
        }
        return nil
    }
    
    static func isLoggedIn() -> Bool? {
        return User.username() != nil
    }
    
    static func isPro() -> Bool? {
        return true
    }
    
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
    
    static func currentId() -> Int? {
        if let userId = GlobalVariables().KDefaults["user_id"], userId != "" {
            return Int(userId)
        }
        return nil
    }
    
    static func currentSessionSecret() -> String? {
        if let sessionSecret = GlobalVariables().KDefaults["session_secret"], sessionSecret != "" {
            return sessionSecret
        }
        return nil
    }
    
    static func currentDevice() -> String? {
        return UIDevice.modelName
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
