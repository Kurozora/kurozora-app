////
////  AnimeDetail.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import Foundation
////import Parse
//
//public class AnimeDetail {
//    public class func parseClassName() -> String {
//        return "AnimeDetail"
//    }
//    
//    @NSManaged public var tvdbStart: Int
//    @NSManaged public var tvdbEnd: Int
//    @NSManaged public var inTvdbSpecials: Int
//    @NSManaged public var synopsis: String?
//    @NSManaged public var classification: String
//    @NSManaged public var englishTitles: [String]
//    @NSManaged public var japaneseTitles: [String]
//    @NSManaged public var synonyms: [String]
//    @NSManaged public var youtubeID: String?
//    
//    public func attributedSynopsis() -> NSAttributedString? {
//        if let synopsis = synopsis, let data = synopsis.data(using: String.Encoding.unicode) {
//            let font = UIFont.systemFont(ofSize: 15)
//            if let attributedString = try? NSMutableAttributedString(
//                data: data,
//                options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html],
////                options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType],
//                documentAttributes: nil) {
//                attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedString.length))
//                return attributedString
//            }
//        }
//        return nil
//    }
//}
