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
    let success: Bool?
    let message: String?
    
    let id: Int?
    let session: String?
    let sessionArray: [JSON]?
    let username: String?
    let avatar: String?
    let banner: String?
    let bio: String?
    let badges: [String]?
    let joinDate: String?
    
    let rating: Double?
    
    let activeStart: String?
    let activeEnd: String?
    let active: Bool?
    
    static func username() -> String? {
        return GlobalVariables().KDefaults["username"]
    }
    
    static func isLoggedIn() -> Bool {
        return User.username() != nil
    }
    
    static func currentId() -> Int? {
        return Int(GlobalVariables().KDefaults["user_id"]!)
    }
    
    static func currentSessionSecret() -> String? {
        return GlobalVariables().KDefaults["session_secret"]
    }
    
    static func currentDevice() -> String? {
        return UIDevice.modelName
    }
    
    init(json: JSON) {
        success = json["success"].boolValue
        message = json["error_message"].stringValue
        
        id = json["user_id"].intValue
        session = json["session_secret"].stringValue
        sessionArray = json["sessions"].arrayValue
        username = json["username"].stringValue
        avatar = json["avatar"].stringValue
        banner = json["banner"].stringValue
        bio = json["bio"].stringValue
        badges = json["badges"].rawValue as? [String]
        joinDate = json["join_date"].stringValue
        
        rating = json["rating"].doubleValue
        
        activeStart = json["active_start"].stringValue
        activeEnd = json["active_end"].stringValue
        active = json["active"].boolValue
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
