//
//  UserCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//


import UIKit

public protocol UserCellDelegate: class {
    func userCellPressedFollow(userCell: UserCell)
}

public class UserCell: UITableViewCell {
    
    public weak var delegate: UserCellDelegate?
    
    @IBOutlet weak public var username: UILabel!
    @IBOutlet weak public var avatar: UIImageView!
    @IBOutlet weak public var date: UILabel!
    @IBOutlet weak public var lastOnline: UILabel!
    @IBOutlet weak public var followButton: UIButton!
    
    public func configureFollowButtonWithState(following: Bool) {
        if following {
            followButton.setTitle("  Following", for: .normal)
        } else {
            followButton.setTitle("  Follow", for: .normal)
        }
        self.followButton.layoutIfNeeded()
    }
    
    @IBAction func followPressed(sender: AnyObject) {
        delegate?.userCellPressedFollow(userCell: self)
    }
}
