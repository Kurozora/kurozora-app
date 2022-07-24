//
//  TitleHeaderTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class TitleHeaderTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var subTitleLabel: KSecondaryLabel!
	@IBOutlet weak var headerButton: HeaderButton!

	// MARK: - Functions
	func configureCell(withTitle title: String?, subtitle: String?, buttonTitle: String?) {
		self.titleLabel.text = title
		self.subTitleLabel.text = subtitle
		self.headerButton.setTitle(buttonTitle, for: .normal)
	}
}
