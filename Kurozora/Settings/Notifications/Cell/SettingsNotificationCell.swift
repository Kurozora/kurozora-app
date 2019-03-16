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
	@IBOutlet weak var selectImageView: UIImageView!
	@IBOutlet weak var placeholder: UIView!

	override var isSelected: Bool {
		didSet {
			if isSelected {
				selectImageView.theme_tintColor = "Global.tintColor"
				selectImageView.image = #imageLiteral(resourceName: "check_circle")

				placeholder.borderColor = .none
				placeholder.borderWidth = 0
				placeholder.cornerRadius = 0
			} else {
				selectImageView.image = nil
				placeholder.borderColor = .lightGray
				placeholder.borderWidth = 2
				placeholder.cornerRadius = 15
			}
		}
	}
}
