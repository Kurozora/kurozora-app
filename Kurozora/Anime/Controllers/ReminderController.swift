//
//  ReminderController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import UserNotifications
//import Bolts

public class ReminderController {
//    public class func scheduleReminderForAnime(anime: Anime) -> Bool {
//
//        if let nextEpisode = anime.nextEpisode {
//
//            let notificationDate = anime.nextEpisodeDate
//
//            var message: String = ""
//            if nextEpisode == 1 {
//                message = "\(anime.title!) first episode airing today!"
//            } else {
//                message = "\(anime.title!) ep \(nextEpisode) airing today"
//            }
//
//            let infoDictionary = ["objectID": anime.myAnimeListID]
//
//            let localNotification = UILocalNotification()
//            localNotification.fireDate = notificationDate
//            localNotification.timeZone = NSTimeZone.default
//            localNotification.alertBody = message
//            localNotification.soundName = UILocalNotificationDefaultSoundName
//            localNotification.userInfo = infoDictionary as [Object : AnyObject]
//
//            // This is to prevent it to expire
//            localNotification.repeatInterval = .year
//
//            print("Scheduled notification: '" + message + "' for date \(notificationDate)")
//
//            UIApplication.shared.scheduleLocalNotification(localNotification)
//
//            return true
//        } else {
//            return false
//        }
//    }
//
//    public class func disableReminderForAnime(anime: Anime) {
//
//        if let notificationToDelete = ReminderController.scheduledReminderFor(anime: anime) {
//            UIApplication.shared.cancelLocalNotification(notificationToDelete)
//        }
//    }
//
//    public class func scheduledReminderFor(anime: Anime) -> UILocalNotification? {
//        if let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications {
//            let matchingNotifications = scheduledNotifications.filter({ (notification: UILocalNotification) -> Bool in
//                let objectID = notification.userInfo as! [String: AnyObject]
//                return objectID["objectID"] as! Int == anime.myAnimeListID
//            })
//            return matchingNotifications.last
//
//        } else {
//            return nil
//
//        }
//    }
//
//    public class func updateScheduledLocalNotifications() {
//        // Update titles, fire dates and disable notifications
//        if let scheduledNotifications = UIApplication.shared.scheduledLocalNotifications {
//            UIApplication.shared.cancelAllLocalNotifications()
//
//            var idList: [Int] = []
//
//            for notification in scheduledNotifications {
//                let objectID = notification.userInfo as! [String: AnyObject]
//                let myAnimelistID = objectID["objectID"] as! Int
//
//                idList.append(myAnimelistID)
//            }
//
//            let query = Anime.query()!
//            query.whereKey("myAnimeListID", containedIn: idList)
//            query.findAllObjectsInBackground()
//                .continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject? in
//
//                    guard let animeList = task.result as? [Anime] else {
//                        return nil
//                    }
//
//                    LibrarySyncController.matchAnimeWithProgress(animeList)
//
//                    for anime in animeList {
//                        if let progress = anime.progress, progress.myAnimeListList() != .Dropped {
//                            self.scheduleReminderForAnime(anime)
//                        }
//                    }
//                    return nil
//                })
//        }
//    }
//
}
