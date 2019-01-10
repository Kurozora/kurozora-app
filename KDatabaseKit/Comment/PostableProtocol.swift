////
////  PostableProtocol.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import Foundation
////import Parse
//
//public protocol Postable {
//    var createdDate: Date? { get }
//    var youtubeID: String? { get set }
//    var edited: Bool { get set }
//    var hasSpoilers: Bool { get set }
//    var content: String? { get set }
//    
//    var imagesData: [ImageData]? { mutating get set }
//    var linkData: LinkData? { mutating get set }
//
//    var imagesDataInternal: [ImageData]? { get set }
//    var linkDataInternal: LinkData? { get set }
//    
//    var likeCount: Int { get set }
//    var replyCount: Int { get set }
//    var shareCount: Int { get set }
//    
//    func incrementLikeCount(byAmount amount: Int)
//    func incrementReplyCount(byAmount amount: Int)
//}
//
//public protocol Commentable: Postable {
//    
////    // Implemented on protocol extension
////    var postedBy: User? { get set }
////
////    var spoilerContent: String? { get set }
////    var replyLevel: Int { get set }
////
////    var subscribers: [User] { get set }
////    var likedBy: [User]? { get set }
////    var parentPost: PFObject? { get }
//    
//    // Implement on subclasses
////    var replies: [PFObject] { get set }
////    var isSpoilerHidden: Bool { get set }
////    var showAllReplies: Bool { get set }
////}
////
////public protocol TimelinePostable: Commentable {
////    var userTimeline: User { get set }
////}
////
////public protocol ThreadPostable: Commentable {
////    var thread: Thread { get set }
////}
////
////extension Postable where Self: PFObject {
////
////    public var createdDate: Date? {
////        get {
////            return createdAt
////        }
////    }
////
////    public var youtubeID: String? {
////        get {
////            return self["youtubeID"] as? String
////        }
////        set(value) {
////            self["youtubeID"] = value ?? NSNull()
////        }
////    }
////
////    public var postedBy: User? {
////        get {
////            return self["postedBy"] as? User
////        }
////        set(value) {
////            self["postedBy"] = value
////        }
////    }
////
////    public var subscribers: [User] {
////        get {
////            return self["subscribers"] as! [User]
////        }
////        set(value) {
////            self["subscribers"] = value
////        }
////    }
////
////    public var likedBy: [User]? {
////        get {
////            return self["likedBy"] as? [User]
////        }
////        set(value) {
////            self["likedBy"] = value
////        }
////    }
////
////    public var edited: Bool {
////        get {
////            return self["edited"] as? Bool ?? false
////        }
////        set(value) {
////            self["edited"] = value
////        }
////    }
////
////    public var content: String? {
////        get {
////            return self["content"] as? String
////        }
////        set(value) {
////            self["content"] = value
////        }
////    }
////
////    public var spoilerContent: String? {
////        get {
////            return self["spoilerContent"] as? String
////        }
////        set(value) {
////            self["spoilerContent"] = value ?? NSNull()
////        }
////    }
////
////    public var replyLevel: Int {
////        get {
////            return self["replyLevel"] as? Int ?? 0
////        }
////        set(value) {
////            self["replyLevel"] = value
////        }
////    }
////
////    public var parentPost: PFObject? {
////        get {
////            return self["parentPost"] as? PFObject
////        }
////        set(value) {
////            self["parentPost"] = value
////        }
////    }
////
////    public var hasSpoilers: Bool {
////
////        get {
////            return self["hasSpoilers"] as? Bool ?? false
////        }
////        set(value) {
////            self["hasSpoilers"] = value
////        }
////    }
////
////    public var likeCount: Int {
////        get {
////            return self["likeCount"] as? Int ?? 0
////        }
////        set(value) {
////            self["likeCount"] = value
////        }
////    }
////    public var replyCount: Int {
////        get {
////            return self["replyCount"] as? Int ?? 0
////        }
////        set(value) {
////            self["replyCount"] = value
////        }
////    }
////    public var shareCount: Int {
////        get {
////            return self["shareCount"] as? Int ?? 0
////        }
////        set(value) {
////            self["shareCount"] = value
////        }
////    }
////
////    public var linkData: LinkData? {
////        mutating get {
////            if linkDataInternal == nil {
////                if let link = self["link"] as? [String: AnyObject] {
////                    linkDataInternal = LinkData.mapDataWithDictionary(link)
////                }
////            }
////            return linkDataInternal
////        }
////        set(value) {
////            linkDataInternal = value
////            if let value = value {
////                self["link"] = value.toDictionary()
////            }
////        }
////    }
////
////    public var imagesData: [ImageData]? {
////        mutating get {
////            if imagesDataInternal == nil {
////                imagesDataInternal = []
////                if let images = self["images"] as? [[String: AnyObject]] {
////                    for image in images {
////                        imagesDataInternal!.append(ImageData.imageDataWithDictionary(image))
////                    }
////                }
////            }
////            return imagesDataInternal
////        }
////        set(value) {
////            imagesDataInternal = value
////
////            guard let value = value else {
////                return
////            }
////
////            var imagesRaw: [[String: AnyObject]] = []
////            for image in value {
////                imagesRaw.append(image.toDictionary())
////            }
////            self["images"] = imagesRaw
////        }
////    }
////
////
////    public func incrementLikeCount(byAmount amount: Int = 1) {
////        incrementKey("likeCount", byAmount: amount)
////    }
////
////    public func incrementReplyCount(byAmount amount: Int = 1) {
////        incrementKey("replyCount", byAmount: amount)
////    }
//}
//
////extension TimelinePostable where Self: PFObject {
////
////    public var userTimeline: User {
////        get {
////            return self["userTimeline"] as! User
////        }
////        set(value) {
////            self["userTimeline"] = value
////        }
////    }
////}
////
////extension ThreadPostable where Self: PFObject {
////    public var thread: Thread {
////        get {
////            return self["thread"] as! Thread
////        }
////        set(value) {
////            self["thread"] = value
////        }
////    }
////}
