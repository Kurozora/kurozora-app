//
//  NotificationController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KDatabaseKit
//import CRToast
import KCommonKit

class NotificationsController {
//
//    class func handleNotification(notificationId: String, objectClass: String, objectId: String, returnAnimator: Bool = false) -> BFTask {
//
//        let notification = Notification(name: Notification.Name(rawValue: notificationId))
//        notification.addUniqueObject(User.currentUser()!, forKey: "readBy")
//        notification.saveInBackground()
//
//        switch objectClass {
//        case "_User":
//            let targetUser = User.objectWithoutDataWithObjectId(objectId)
//            return targetUser.fetchInBackground()
//                .continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject? in
//                    if let user = task.result as? User {
//                        showUserProfile(user, returnAnimator: returnAnimator)
//                    }
//                    return BFTask(result: nil)
//                })
//
//
//        case "TimelinePost":
//            let query = TimelinePost.query()!
//            query.whereKey("objectId", equalTo: objectId)
//            query.includeKey("userTimeline")
//            query.limit = 1
//            return query.findObjectsInBackground()
//                .continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject? in
//                    if let result = task.result as? [PFObject],
//                        let targetTimelinePost = result.last as? TimelinePost {
//
//                        self.showNotificationThread(targetTimelinePost, returnAnimator: returnAnimator)
//                    }
//                    return BFTask(result: nil)
//
//                })
//
//        case "Post":
//            let query = Post.query()!
//            query.whereKey("objectId", equalTo: objectId)
//            query.includeKey("thread")
//            query.includeKey("thread.tags")
//            query.includeKey("thread.anime")
//            query.includeKey("thread.episode")
//            query.includeKey("thread.startedBy")
//            query.limit = 1
//            return query.findObjectsInBackground()
//                .continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject? in
//                    if let result = task.result as? [PFObject],
//                        let targetPost = result.last as? Post {
//                        self.showNotificationThread(targetPost, returnAnimator: returnAnimator)
//                    }
//                    return BFTask(result: nil)
//                })
//
//        default:
//            return BFTask(result: nil)
//        }
//    }
//
//    class func showUserProfile(user: User, returnAnimator: Bool) {
//
//        let profileController = KAnimeKit.profileViewController()
//        profileController.initWithUser(user: user)
//        pushViewController(controller: profileController)
//    }
//
//    class func showNotificationThread(post: Postable, returnAnimator: Bool) {
//
//        let (_, profileController) = KAnimeKit.notificationThreadViewController()
//        profileController.initWithPost(post: post)
//        pushViewController(controller: profileController)
//    }
//
//    class func pushViewController(controller: UIViewController) {
//        guard let topVC = UIApplication.topViewController() else {
//            return
//        }
//        topVC.navigationController?.pushViewController(controller, animated: true)
//    }
//    class func showToast(notificationId: String, objectClass: String, objectId: String, message: String) {
//        var tapped = false
//
//        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.TapOnce, automaticallyDismiss: true) { (interaction: CRToastInteractionType) -> Void in
//            handleNotification(notificationId, objectClass: objectClass, objectId: objectId)
//            tapped = true
//        }
//
//        // Create toast
//        let options = [
//            kCRToastInteractionRespondersKey: [responder],
//            //kCRToastNotificationTypeKey: CRToastType.NavigationBar.rawValue,
//            kCRToastTimeIntervalKey: 2.0,
//            kCRToastTextKey : message,
//            kCRToastBackgroundColorKey : UIColor.peterRiver(),
//            kCRToastAnimationInTypeKey : CRToastAnimationType.Spring.rawValue,
//            kCRToastAnimationOutTypeKey : CRToastAnimationType.Spring.rawValue,
//            kCRToastAnimationInDirectionKey : CRToastAnimationDirection.Top.rawValue,
//            kCRToastAnimationOutDirectionKey : CRToastAnimationDirection.Top.rawValue
//            ] as [String: AnyObject]
//
//        CRToastManager.showNotificationWithOptions(options) { () -> Void in
//            if !tapped {
//                NSNotificationCenter.defaultCenter().postNotificationName("newNotification", object: nil)
//            }
//        }
//    }
}
