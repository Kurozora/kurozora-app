////
////  LibraryController.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import Foundation
////import Bolts
//import KCommonKit
////import MMWormhole
//
//public protocol LibraryControllerDelegate: class {
//    func libraryControllerFinishedFetchingLibrary(library: [Anime])
//}
//
//public class LibraryController {
//
//    public static let LastSyncDateDefaultsKey = "LibrarySync.LastSyncDate"
//
//    public static let sharedInstance = LibraryController()
//
//    public var library: [Anime]?
//    public var progress: [AnimeProgress]?
//    public var currentlySyncing = false
//    public weak var delegate: LibraryControllerDelegate?
//    
////    let wormhole = MMWormhole.aozoraWormhole()
//
//    public func fetchAnimeList(isRefreshing: Bool) /*-> BFTask */{
//
////        currentlySyncing = true
////
////        let shouldSyncData = UserDefaults.shouldPerformAction(actionID: LibraryController.LastSyncDateDefaultsKey, expirationDays: 1)
//
////        var fetchTask: BFTask!
//
////        if isRefreshing || shouldSyncData {
////            fetchTask = LibrarySyncController.refreshKurozoraLibrary()
////        } else {
////            fetchTask = LibrarySyncController.fetchKurozoraLibrary()
////        }
//
////        fetchTask.continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask) -> BFTask in
////
////            if let result = task.result as? [Anime] {
////                self.library = result
////
////                let libraryWithProgress = result
////                    .filter({ $0.progress != nil })
////
////                self.progress = libraryWithProgress
////                    .map({ $0.progress! })
////
////                self.updateWatchingWormhole()
////
////                self.delegate?.libraryControllerFinishedFetchingLibrary(result)
////                NSUserDefaults.completedAction(LibraryController.LastSyncDateDefaultsKey)
////            }
////            self.currentlySyncing = false
////
////            return task
////        })
////
////        return fetchTask
//    }
//
//    public func updateWatchingWormhole() {
//
////        guard let library = library else {
////            return
////        }
////
////        let watchingAnime = library
////            .filter({ $0.progress != nil })
////            .filter({
////                $0.progress!.list == KurozoraList.Watching.rawValue
////            }).map { (anime) -> AnimeData in
////                let firstAired = anime.startDateTime ?? anime.startDate
////
////                return AnimeData(
////                    title: anime.title ?? "",
////                    firstAired: firstAired ?? Date(),
////                    currentEpisode: anime.progress!.watchedEpisodes,
////                    episodes: anime.episodes,
////                    status: AnimeStatus(rawValue: anime.status) ?? .NotYetAired
////                )
////        }
////
////        wormhole.passWatchingList(watchingAnime)
//    }
//}
