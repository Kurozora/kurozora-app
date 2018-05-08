//
//  BasicTableCell.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import TTTAttributedLabel_moolban

public protocol BasicTableCellDelegate: class {
    func cellSelectedActionButton(cell: BasicTableCell)
}

public class BasicTableCell: UITableViewCell {
    
    public weak var delegate: BasicTableCellDelegate?
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    @IBOutlet public weak var titleimageView: UIImageView!
    @IBOutlet public weak var attributedLabel: TTTAttributedLabel!
    
    @IBOutlet public weak var detailLabel: UILabel!
    @IBOutlet public weak var detailSubtitleLabel: UILabel!
    
    @IBOutlet public weak var actionContentView: UIView!
    
    @IBOutlet public weak var actionButton: UIButton!
    
    @IBAction public func actionButtonPressed(sender: AnyObject) {
        delegate?.cellSelectedActionButton(cell: self)
    }
}
