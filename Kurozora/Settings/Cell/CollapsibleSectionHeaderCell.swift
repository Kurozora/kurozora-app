//
//  CollapsibleSectionHeaderCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class CollapsibleSectionHeaderCell: UITableViewCell {
	@IBOutlet weak var sectionTitleLabel: UILabel! {
		didSet {
			self.sectionTitleLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
	@IBOutlet weak var sectionButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
