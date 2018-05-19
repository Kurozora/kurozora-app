//
//  User.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse

public class User {

    @NSManaged public var avatarThumb: UIImage
    @NSManaged public var banner: UIImage
    @NSManaged public var badges: [String]
    @NSManaged public var unlockedContent: [String]
    @NSManaged public var joinDate: Date
    @NSManaged public var kurozoraUsername: String
    @NSManaged public var myAnimeListUsername: String?
    @NSManaged public var anilistUsername: String
    @NSManaged public var details: String
    
    @NSManaged public var activeStart: Date
    @NSManaged public var activeEnd: Date
    @NSManaged public var active: Bool
    
    @NSManaged public var trialExpiration: Date?
    
    public var followingThisUser: Bool?
    
    static let MyAnimeListPasswordKey = "MyAnimeList.Password"
    
//    public func following() {
//        return self.relationForKey("following")
//    }
    
//    public override class func currentUser() -> User? {
//        return !currentUserIsGuest() ? User.currentUser() : nil
//    }
    
//    public class func currentUserLoggedIn() -> Bool {
//
//        return User.currentUser() != nil && !currentUserIsGuest()
//    }
//
//    public class func currentUserIsGuest() -> Bool {
//
//        return PFAnonymousUtils.isLinkedWithUser(User.currentUser())
//    }
    
//    public var myAnimeListPassword: String? {
//        get {
//            return UserDefaults.standard.object(forKey: User.MyAnimeListPasswordKey) as! String?
//        }
//        set(object) {
//            UserDefaults.standard.set(object, forKey: User.MyAnimeListPasswordKey)
//            UserDefaults.standard.synchronize()
//        }
//    }
//    
//    public class func logoutMyAnimeList() {
//        UserDefaults.standard.removeObject(forKey: User.MyAnimeListPasswordKey)
//        UserDefaults.standard.synchronize()
//    }
    
//    public class func syncingWithMyAnimeList() -> Bool {
//        guard let user = User.currentUser() else {
//            return false
//        }
//        return user.myAnimeListPassword != nil
//    }
//
//    public func incrementPostCount(byAmount: Int) {
//        details.incrementKey("posts", byAmount: byAmount)
//        details.saveInBackground()
//    }
    
//    public func isAdmin() -> Bool {
//        return badges.contains("Admin") || isTopAdmin()
//    }
//
//    public func isTopAdmin() -> Bool {
//        return badges.contains("Top Admin")
//    }
    
    // Don't ever name the function isCurrentUser it will conflict with Parse framework
//    public func isTheCurrentUser() -> Bool {
//        guard let id1 = self.objectId, let currentUser = User.currentUser(), let id2 = currentUser.objectId else {
//            return false
//        }
//        return id1 == id2
//    }
    
    // Trial
//    public func hasTrial() -> Bool {
//        return trialExpiration?.compare(Date()) == .orderedDescending
//    }
    
//    public func followUser(user: User, follow: Bool) {
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
//    public class func muted(viewController: UIViewController) -> Bool {
    
        
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
