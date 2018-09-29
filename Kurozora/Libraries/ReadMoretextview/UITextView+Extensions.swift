////
//  UITextView+Extensions.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

//import UIKit

//extension UITextView {
//    func numberOfLines() -> Int {
//        let layoutManager = self.layoutManager
//        let numberOfGlyphs = layoutManager.numberOfGlyphs
//        var lineRange: NSRange = NSMakeRange(0, 1)
//        var index = 0
//        var numberOfLines = 0
//
//        while index < numberOfGlyphs {
//            layoutManager.lineFragmentRect(
//                forGlyphAt: index, effectiveRange: &lineRange
//            )
//            index = NSMaxRange(lineRange)
//            numberOfLines += 1
//        }
//        return numberOfLines
//    }
//}
