//
//  Post.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse

public class Post {
    public class func parseClassName() -> String {
        return "Post"
    }
    
    // Postable
    
//    public var replies: [PFObject] = []
    public var isSpoilerHidden = true
    public var showAllReplies = false
    
//    public var imagesDataInternal: [ImageData]?
//    public var linkDataInternal: LinkData?
}
