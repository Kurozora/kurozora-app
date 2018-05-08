//
//  BasicCollectionCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import FLAnimatedImage

public protocol BasicCollectionCellDelegate: class {
    func cellSelectedActionButton(cell: BasicCollectionCell)
}

public class BasicCollectionCell: UICollectionViewCell {
    
    public weak var delegate: BasicCollectionCellDelegate?
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var titleimageView: UIImageView!
    @IBOutlet public weak var actionButton: UIButton!
    @IBOutlet public weak var subtitleLabel: UILabel!
    
    @IBOutlet public weak var animatedImageView: FLAnimatedImageView!
    
    public var loadingURL: String?
    
    @IBAction public func actionButtonPressed(sender: AnyObject) {
        delegate?.cellSelectedActionButton(cell: self)
    }
}
