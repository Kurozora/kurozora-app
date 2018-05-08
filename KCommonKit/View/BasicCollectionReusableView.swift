//
//  BasicCollectionReusableView.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

public protocol BasicCollectionReusableViewDelegate: class {
    func headerSelectedActionButton(cell: BasicCollectionReusableView)
    func headerSelectedActionButton2(cell: BasicCollectionReusableView)
}

public class BasicCollectionReusableView: UICollectionReusableView {
    
    public weak var delegate: BasicCollectionReusableViewDelegate?
    public var section: Int?
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    @IBOutlet public weak var titleImageView: UIImageView!
    @IBOutlet public weak var actionButton: UIButton!
    
    @IBAction public func actionButtonPressed(sender: AnyObject) {
        delegate?.headerSelectedActionButton(cell: self)
    }
    
    @IBAction func actionButton2Pressed(sender: AnyObject) {
        delegate?.headerSelectedActionButton2(cell: self)
    }
}
