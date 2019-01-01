//
//  SettingsNotificationCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SettingsNotificationCell: UICollectionViewCell {
	@IBOutlet weak var previewImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var selectButton: UIButton!

	override var isSelected: Bool {
		didSet {
			if isSelected {
				selectButton.backgroundColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
				selectButton.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
				selectButton.setTitle("✔︎", for: .normal)
			} else {
				selectButton.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
				selectButton.borderColor = #colorLiteral(red: 0.2174186409, green: 0.2404800057, blue: 0.332449615, alpha: 1)
				selectButton.setTitle("", for: .normal)
			}
		}
	}
}
