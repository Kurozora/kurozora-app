//
//  TFHppleElement+Convenience.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import Foundation
//
//extension TFHppleElement {
//
//    public func childrenContentByRemovingHtml() -> String {
//        var allContent: String = ""
//
//        for child in (children as! [TFHppleElement]) {
//            if child.isTextNode() {
//                allContent += child.content+"\n\n"
//            }
//        }
//        return allContent
//    }
//
//    public func nthChild(nth: Int) -> TFHppleElement? {
//        if children.count > nth {
//            return children[nth] as? TFHppleElement
//        } else {
//            print("Index out of bounds for nthChild, returning nil, object: \(self.raw)")
//            return nil;
//        }
//    }
//
//    public func hppleElementFor(path: [Int]) -> TFHppleElement? {
//        var path = path
//        var hppleElement = self
//
//        while path.count > 0 {
//            if let index = path.first, let hpple = hppleElement.nthChild(index) {
//                hppleElement = hpple
//            } else {
//                return nil
//            }
//            path.removeAtIndex(0)
//        }
//        return hppleElement
//    }
//
//}
