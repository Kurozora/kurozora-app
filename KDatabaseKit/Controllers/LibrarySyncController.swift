////
////  LibrarySyncController.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import Foundation
////import Parse
////import Bolts
//import Alamofire
//import KCommonKit
//
//public let LibraryUpdatedNotification = "LibraryUpdatedNotification"
//public let LibraryCreatedNotification = "LibraryCreatedNotification"
//
//public class LibrarySyncController {
//    
//    public static let sharedInstance = LibrarySyncController()
//    
//    public enum Source {
//        case MyAnimeList
//        case Anilist
//        case Hummingbird
//    }
//    
//    // MARK: - Library management
//    
//    /// Fetches what's on Parse
//    public class func fetchAozoraLibrary(useCache: Bool = true) /*-> BFTask */{
////        guard let user = User.currentUser() else {
////            return BFTask(result: nil)
////        }
////
////        let progressQuery = AnimeProgress.query()!
////        progressQuery.whereKey("user", equalTo: user)
////        progressQuery.includeKey("anime")
////
////        return progressQuery.findAllObjectsInBackground().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject? in
////
////            let list = task.result as! [AnimeProgress]
////
////            // Referece progress in anime objects..
////            for progress in list {
////                progress.anime.progress = progress
////            }
////
////            let animeList = list.map({ return $0.anime })
////            print("Found a list of \(animeList.count)")
////
////            return BFTask(result: animeList)
////        })
//    }
//    
//    /// Syncs with linked services
//    public class func refreshAozoraLibrary() /*-> BFTask */{
//        
////        print("Fetching all anime library from network..")
////        guard let _ = User.currentUser() else {
////            return BFTask(result: nil)
////        }
////
////        var allAnime: [Anime] = []
////        var myAnimeListLibrary: [MALProgress] = []
////
////        let task = BFTask(result: nil).continueWithBlock({ (task: BFTask!) -> AnyObject? in
////
////            var syncWithAServiceTask = BFTask(result: nil)
////
////            // 1. For each source fetch all library
////            if User.syncingWithMyAnimeList() {
////                print("Syncing with mal, continuing..")
////
////                syncWithAServiceTask = self.fetchMyAnimeListLibrary().continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
////                    // 2. Save library in array
////                    if let result = task.result?["anime"] as? [[String: AnyObject]] {
////                        print("MAL Library count \(result.count)")
////                        for data in result {
////                            let myAnimeListID = data["id"] as! Int
////                            let status = data["watched_status"] as! String
////                            let episodes = data["watched_episodes"] as! Int
////                            let score = data["score"] as! Int
////                            let malProgress = MALProgress(myAnimeListID: myAnimeListID, status: MALList(rawValue: status)!, episodes: episodes, score: score)
////                            myAnimeListLibrary.append(malProgress)
////                        }
////                    }
////                    return nil
////                })
////            } else {
////                print("Not syncing with mal, continuing..")
////            }
////
////            let fetchAozoraLibrary = self.fetchAozoraLibrary(false)
////
////            return BFTask(forCompletionOfAllTasksWithResults: [syncWithAServiceTask, fetchAozoraLibrary])
////
////        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject? in
////
////            // 3. Merge all existing libraries
////            let parseLibrary = (task.result as! [AnyObject])[1] as! [Anime]
////            print("current anime library count \(parseLibrary.count)")
////            allAnime += parseLibrary
////
////            self.mergeLibraries(myAnimeListLibrary, parseLibrary: parseLibrary)
////
////            // Create on PARSE
////            var malProgressToCreate: [MALProgress] = []
////
////            let parseLibraryIDs = parseLibrary.map({$0.myAnimeListID})
////            for malProgress in myAnimeListLibrary where parseLibraryIDs.filter({$0 == malProgress.myAnimeListID}).last == nil {
////                malProgressToCreate.append(malProgress)
////            }
////
////            let malProgressToCreateIDs = malProgressToCreate.map({ (malProgress: MALProgress) -> Int in
////                return malProgress.myAnimeListID
////            })
////
////            guard malProgressToCreateIDs.count > 0 else {
////                return BFTask(result: allAnime)
////            }
////
////            print("Need to create \(malProgressToCreateIDs.count) AnimeProgress on Parse")
////            let query = Anime.query()!
////            query.whereKey("myAnimeListID", containedIn: malProgressToCreateIDs)
////            return query.findAllObjectsInBackground()
////                .continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
////                    let animeToCreate = task.result as! [Anime]
////                    print("Creating \(animeToCreate.count) AnimeProgress on Parse")
////                    var newProgress: [AnimeProgress] = []
////                    for anime in animeToCreate {
////                        // This prevents all anime object to be iterated thousands of times..
////                        let myAnimeListID = anime.myAnimeListID
////
////                        if let malProgress = malProgressToCreate.filter({ $0.myAnimeListID == myAnimeListID }).last {
////                            // Creating on PARSE
////                            let malList = MALList(rawValue: malProgress.status)!
////                            let progress = AnimeProgress()
////                            progress.anime = anime
////                            progress.user = User.currentUser()!
////                            progress.startDate = NSDate()
////                            progress.updateList(malList)
////                            progress.watchedEpisodes = malProgress.episodes
////                            progress.collectedEpisodes = 0
////                            progress.score = malProgress.score
////                            newProgress.append(progress)
////
////                            anime.progress = progress
////                        }
////                    }
////
////                    allAnime += animeToCreate
////
////                    PFObject.saveAllInBackground(newProgress)
////                    return BFTask(result: allAnime)
////                })
////
////        }).continueWithBlock({ (task: BFTask!) -> AnyObject? in
////            if let error = task.error {
////                print(error)
////            } else if let exception = task.exception {
////                print(exception)
////            }
////
////            return task
////        })
////
////        return task
//    }
//    
//    class func mergeLibraries(myAnimeListLibrary: [MALProgress], parseLibrary: [Anime]) {
////
////        var updatedMyAnimeListLibrary = Set<MALProgress>()
////
////        for anime in parseLibrary where anime.progress != nil {
////            let progress = anime.progress!
////            // This prevents all anime object to be iterated thousands of times..
////            let myAnimeListID = anime.myAnimeListID
////            // Check if user is syncing with MyAnimeList
////            if User.syncingWithMyAnimeList() {
////                if var malProgress = myAnimeListLibrary.filter({$0.myAnimeListID == myAnimeListID}).last {
////                    var shouldSave = false
////                    // Update episodes
////                    if malProgress.episodes > progress.watchedEpisodes {
////                        // On Parse
////                        print("updated episodes on parse \(progress.anime.title!)")
////                        progress.watchedEpisodes = malProgress.episodes
////                        shouldSave = true
////                    } else if malProgress.episodes < progress.watchedEpisodes {
////                        print("updated episodes on mal \(progress.anime.title!)")
////                        // On MAL
////                        malProgress.syncState = .Updated
////                        malProgress.episodes = progress.watchedEpisodes
////                        updatedMyAnimeListLibrary.insert(malProgress)
////                    }
////
////                    // Update Score
////                    if malProgress.score != progress.score {
////                        if malProgress.score != 0 {
////                            print("updated score on parse \(progress.anime.title!)")
////                            progress.score = malProgress.score
////                            shouldSave = true
////                        } else if progress.score != 0 {
////                            print("updated score on mal \(progress.anime.title!)")
////                            malProgress.score = progress.score
////                            malProgress.syncState = .Updated
////                            updatedMyAnimeListLibrary.insert(malProgress)
////                        }
////                    }
////
////                    // Update list
////                    let malListMAL = MALList(rawValue: malProgress.status)!
////                    let malListParse = progress.myAnimeListList()
////                    if malListMAL != malListParse {
////                        print("List is different for: \(progress.anime.title!)")
////                        var malList: MALList?
////                        var aozoraList: AozoraList?
////                        if malListMAL == .Completed || malListParse == .Completed {
////                            if malListMAL != .Completed {
////                                malList = .Completed
////                            } else {
////                                aozoraList = .Completed
////                            }
////                        } else if malListMAL == .Dropped || malListParse == .Dropped {
////                            if malListMAL != .Dropped {
////                                malList = .Dropped
////                            } else {
////                                aozoraList = .Dropped
////                            }
////                        } else if malListMAL == .OnHold || malListParse == .OnHold {
////                            if malListMAL != .OnHold {
////                                malList = .OnHold
////                            } else {
////                                aozoraList = .OnHold
////                            }
////                        } else if malListMAL == .Watching || malListParse == .Watching {
////                            if malListMAL != .Watching {
////                                malList = .Watching
////                            } else {
////                                aozoraList = .Watching
////                            }
////                        } else {
////                            if malListMAL != .Planning {
////                                malList = .Planning
////                            } else {
////                                aozoraList = .Planning
////                            }
////                        }
////
////                        if let status = malList {
////                            print("updated list on mal \(progress.anime.title!)")
////                            malProgress.status = status.rawValue
////                            malProgress.syncState = .Updated
////                            updatedMyAnimeListLibrary.insert(malProgress)
////                        }
////
////                        if let aozoraList = aozoraList {
////                            print("updated list on parse \(progress.anime.title!)")
////                            progress.list = aozoraList.rawValue
////                            shouldSave = true
////                        }
////                    }
////
////                    if shouldSave {
////                        progress.saveInBackground()
////                    }
////
////                } else {
////                    print("Created \(progress.anime.title!) progress on mal")
////                    // Create on MAL
////                    var malProgress = MALProgress(myAnimeListID:
////                        anime.myAnimeListID,
////                        status: progress.myAnimeListList(),
////                        episodes: progress.watchedEpisodes,
////                        score: progress.score)
////                    malProgress.syncState = .Created
////                    updatedMyAnimeListLibrary.insert(malProgress)
////                }
////            }
////
//            // TODO: Check if user is syncing with Anilist
////        }
//        
//        // Push updated objects to all sources
////        for malProgress in updatedMyAnimeListLibrary {
////            switch malProgress.syncState {
////            case .Created:
////                print("Creating on MAL \(malProgress.myAnimeListID)")
////                self.addAnime(malProgress: malProgress)
////            case .Updated:
////                print("Updating on MAL \(malProgress.myAnimeListID)")
////                self.updateAnime(malProgress: malProgress)
////            default:
////                break
////            }
////        }
////
//    }
//    
//    // MARK: - Class Methods
//    
//    public class func matchAnimeWithProgress(animeList: [Anime]) {
//        
//        // Match all anime with it's progress..
////        if let animeLibrary = LibraryController.sharedInstance.progress {
////            for anime in animeList where anime.progress == nil {
////                for progress in animeLibrary {
////                    if progress.anime.objectId == anime.objectId {
////                        anime.progress = progress
////                        break
////                    }
////                }
////            }
////        }
//    }
//    
//    // MARK: - General External Library Methods
//    
//    public class func libraryHasBeenUpdated() {
//        // Update wormhole
//        LibraryController.sharedInstance.updateWatchingWormhole()
//    }
//    
//    public class func addAnime(progress: AnimeProgress? = nil, malProgress: MALProgress? = nil) /*-> BFTask */{
////        libraryHasBeenUpdated()
//        //        let source = Source.MyAnimeList
//        //        switch source {
//        //        case .MyAnimeList:
////        let malProgress = malProgress ?? animeProgressToAtarashiiObject(progress: progress!)
////        return myAnimeListRequestWithRouter(Atarashii.Router.animeAdd(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject? in
////            return nil
////        })
//        //        case .Anilist:
//        //            fallthrough
//        //        case .Hummingbird:
//        //            fallthrough
//        //        default:
//        //            return BFTask(result: nil)
//        //        }
//    }
//    
//    public class func updateAnime(progress: AnimeProgress? = nil, malProgress: MALProgress? = nil) /*-> BFTask */{
////        libraryHasBeenUpdated()
//        //        let source = Source.MyAnimeList
//        //        switch source {
//        //        case .MyAnimeList:
////        let malProgress = malProgress ?? animeProgressToAtarashiiObject(progress: progress!)
////        return myAnimeListRequestWithRouter(Atarashii.Router.animeUpdate(progress: malProgress)).continueWithBlock({ (task: BFTask!) -> AnyObject? in
////            return nil
////        })
////        //        case .Anilist:
//        //            fallthrough
//        //        case .Hummingbird:
//        //            fallthrough
//        //        default:
//        //            return BFTask(result: nil)
//        //        }
//    }
//    
//    public class func deleteAnime(progress: AnimeProgress? = nil, malProgress: MALProgress? = nil) /*-> BFTask */{
////        libraryHasBeenUpdated()
//        //        let source = Source.MyAnimeList
//        //        switch source {
//        //        case .MyAnimeList:
////        let malID = malProgress?.myAnimeListID ?? progress!.anime.myAnimeListID
////        return myAnimeListRequestWithRouter(Atarashii.Router.animeDelete(id: malID)).continueWithBlock({ (task: BFTask!) -> AnyObject? in
////            return nil
////        })
//        //        case .Anilist:
//        //            fallthrough
//        //        case .Hummingbird:
//        //            fallthrough
//        //        default:
//        //            return BFTask(result: nil)
//        //        }
//    }
//    
//    // MARK: - MyAnimeList Library Methods
//    
//    class func fetchMyAnimeListLibrary() /*-> BFTask!*/{
////        let completionSource = BFTaskCompletionSource()
////        if let username = User.currentUser()!.myAnimeListUsername {
////
////            Alamofire.request(Atarashii.Router.animeList(username: username.lowercaseString)).validate().responseJSON { (req, res, result) -> Void in
////                if result.isSuccess {
////                    completionSource.setResult(result.value)
////                } else {
////                    completionSource.setError(NSError(domain: "kurozora.fetchMALLibrary", code: 1, userInfo: nil))
////                }
////            }
////        }
////        return completionSource.task
//    }
//
////    class func myAnimeListRequestWithRouter(router: Atarashii.Router) /*-> BFTask */{
////
////        if !User.currentUserLoggedIn() {
////            return BFTask(result: nil)
////        }
//    
////        let completionSource = BFTaskCompletionSource()
//        
////        let malUsername = User.currentUser()!.myAnimeListUsername ?? ""
////        let malPassword = User.currentUser()!.myAnimeListPassword ?? ""
////
////        Alamofire.request(router)
////            .authenticate(user: malUsername, password: malPassword)
////            .validate()
////            .responseJSON { (req, res, result) -> Void in
////                if result.isSuccess {
////                    completionSource.setResult(result.value)
////                } else {
////                    completionSource.setError(NSError(domain: "kurozora.AuthenticateMAL", code: 1, userInfo: nil))
////                }
////        }
////        return completionSource.task
////
////    }
//
//    class func animeProgressToAtarashiiObject(progress: AnimeProgress) -> MALProgress {
//        return MALProgress(
//            myAnimeListID: progress.anime!.myAnimeListID,
//            status: progress.myAnimeListList(),
//            episodes: progress.watchedEpisodes,
//            score: progress.score)
//        
//    }
//}
