//
//  PostLinkCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 04/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

public protocol LinkCellDelegate: PostCellDelegate {
    func postCellSelectedLink(linkCell: LinkCell)
}

public class LinkCell: PostCell {
    
    @IBOutlet public weak var linkTitleLabel: UILabel!
    @IBOutlet public weak var linkContentLabel: UILabel!
    @IBOutlet public weak var linkUrlLabel: UILabel!
    
    @IBOutlet weak var linkContentView: UIView!
    
    public weak var linkDelegate: LinkCellDelegate?
    
    public override class func registerNibFor(tableView: UITableView) {
        
        super.registerNibFor(tableView: tableView)
        
        let listNib = UINib(nibName: "LinkCell", bundle: nil)
        tableView.register(listNib, forCellReuseIdentifier: "LinkCell")
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        do {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedOnLink))
            gestureRecognizer.numberOfTouchesRequired = 1
            gestureRecognizer.numberOfTapsRequired = 1
            linkContentView.addGestureRecognizer(gestureRecognizer)
        }
        
        do {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressedOnLink))
            gestureRecognizer.numberOfTouchesRequired = 1
            gestureRecognizer.numberOfTapsRequired = 1
            imageContent?.addGestureRecognizer(gestureRecognizer)
        }
        
        let borderWidth: CGFloat = 1
        linkContentView.layer.borderColor = UIColor.backgroundDarker().cgColor
        linkContentView.layer.borderWidth = borderWidth
    }
    
    // MARK: - UITapGestureRecognizer
    
    @objc func pressedOnLink(sender: AnyObject) {
        linkDelegate?.postCellSelectedLink(linkCell: self)
    }
    
}
