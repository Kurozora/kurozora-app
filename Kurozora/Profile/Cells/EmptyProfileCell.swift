//
//  EmptyProfileCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class EmptyProfileCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			self.separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	var title: String? {
		didSet {
			titleLabel.text = title
			titleLabel.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}
}
