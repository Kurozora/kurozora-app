//
//  DiscardableImageCacheItem+Cache.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

open class DiscardableImageCacheItem: NSObject, NSDiscardableContent {
    
    private(set) public var image: UIImage?
    var accessCount: UInt = 0
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public func beginContentAccess() -> Bool {
        if image == nil {
            return false
        }
        
        accessCount += 1
        return true
    }
    
    public func endContentAccess() {
        if accessCount > 0 {
            accessCount -= 1
        }
    }
    
    public func discardContentIfPossible() {
        if accessCount == 0 {
            image = nil
        }
    }
    
    public func isContentDiscarded() -> Bool {
        return image == nil
    }
    
}
