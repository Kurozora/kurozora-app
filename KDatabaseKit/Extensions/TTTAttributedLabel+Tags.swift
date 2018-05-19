//
//  TTTAttributedLabel+Tags.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import TTTAttributedLabel_moolban
//import Parse

extension TTTAttributedLabel {
//    public func updateTags(tags: [PFObject], delegate: TTTAttributedLabelDelegate, addLinks: Bool = true) {
//        linkAttributes = [kCTForegroundColorAttributeName: UIColor.peterRiver()]
//        textColor = UIColor.peterRiver()
//        self.delegate = delegate
//
//        var tagsString = ""
//
//        for tag in tags {
//            if let tag = tag as? ThreadTag {
//                tagsString += "#\(tag.name)  "
//            } else if let anime = tag as? Anime {
//                tagsString += "#\(anime.title!)  "
//            }
//        }
//        
//        setText(tagsString, afterInheritingLabelAttributesAndConfiguringWith: { (attributedString) -> NSMutableAttributedString? in
//            return attributedString
//        })
//
//        if addLinks {
//            var idx = 0
//            for tag in tags {
//                var tagName: String?
//                if let tag = tag as? ThreadTag {
//                    tagName = "#\(tag.name)  "
//                } else if let anime = tag as? Anime {
//                    tagName = "#\(anime.title!)  "
//                }
//
//                if let tag = tagName {
//                    let url = URL(string: "kurozoraapp://tag/\(idx)")
//                    let range = (tagsString as String).rangeOfString(tag)
//                    addLinkToURL(url, withRange: range)
//                    idx += 1
//                }
//            }
//        }
//    }
}
