//
//  PostCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 03/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import TTTAttributedLabel_moolban

public protocol PostCellDelegate: class {
    func postCellSelectedImage(postCell: PostCell)
    func postCellSelectedUserProfile(postCell: PostCell)
    func postCellSelectedToUserProfile(postCell: PostCell)
    func postCellSelectedComment(postCell: PostCell)
    func postCellSelectedHeart(postCell: PostCell)
}

public class PostCell: UITableViewCell {
    
    @IBOutlet weak public var avatar: UIImageView!
    @IBOutlet weak public var username: UILabel?
    @IBOutlet weak public var date: UILabel!
    
    @IBOutlet weak public var toIcon: UILabel?
    @IBOutlet weak public var toUsername: UILabel?
    
    @IBOutlet weak public var imageContent: UIImageView?
    @IBOutlet weak public var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak public var textContent: TTTAttributedLabel!
    
    @IBOutlet weak public var replyButton: UIButton!
    @IBOutlet weak public var heartButton: UIButton!
    @IBOutlet weak public var playButton: UIButton?
    
    public weak var delegate: PostCellDelegate?
    
    public enum PostType {
        case Text
        case Image
        case Image2
        case Image3
        case Image4
        case Image5
        case Video
    }
    
    public class func registerNibFor(tableView: UITableView) {
        
        let listNib = UINib(nibName: "PostTextCell", bundle: KCommonKit.bundle())
        tableView.register(listNib, forCellReuseIdentifier: "PostTextCell")
        let listNib2 = UINib(nibName: "PostImageCell", bundle: KCommonKit.bundle())
        tableView.register(listNib2, forCellReuseIdentifier: "PostImageCell")
        
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        do {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedUserProfile))
            gestureRecognizer.numberOfTouchesRequired = 1
            gestureRecognizer.numberOfTapsRequired = 1
            avatar.addGestureRecognizer(gestureRecognizer)
        }
        
        if let imageContent = imageContent {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedOnImage))
            gestureRecognizer.numberOfTouchesRequired = 1
            gestureRecognizer.numberOfTapsRequired = 1
            imageContent.addGestureRecognizer(gestureRecognizer)
        }
        
        if let username = username {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedUserProfile))
            gestureRecognizer.numberOfTouchesRequired = 1
            gestureRecognizer.numberOfTapsRequired = 1
            username.addGestureRecognizer(gestureRecognizer)
        }
        
        if let toUsername = toUsername {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedToUserProfile))
            gestureRecognizer.numberOfTouchesRequired = 1
            gestureRecognizer.numberOfTapsRequired = 1
            toUsername.addGestureRecognizer(gestureRecognizer)
        }
        
    }
    
    // MARK: - IBActions
    
    @objc func pressedUserProfile(sender: AnyObject) {
        delegate?.postCellSelectedUserProfile(postCell: self)
    }
    
    @objc func pressedToUserProfile(sender: AnyObject) {
        delegate?.postCellSelectedToUserProfile(postCell: self)
    }
    
    @objc func pressedOnImage(sender: AnyObject) {
        delegate?.postCellSelectedImage(postCell: self)
    }
    
    @IBAction func replyPressed(sender: AnyObject) {
        delegate?.postCellSelectedComment(postCell: self)
        replyButton.animateBounce()
    }
    
    @IBAction func heartPressed(sender: AnyObject) {
        delegate?.postCellSelectedHeart(postCell: self)
        heartButton.animateBounce()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        textContent.preferredMaxLayoutWidth = textContent.frame.size.width
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        textContent.preferredMaxLayoutWidth = textContent.frame.size.width
    }
}
