//
//  GenreTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class GenreTableViewCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var nameLabel: KLabel!
	@IBOutlet weak var nsfwButton: UIButton!
	@IBOutlet weak var iconImageView: UIImageView!

	// MARK: - Properties
	var genre: Genre! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		nameLabel.text = genre.attributes.name
		iconImageView.image = genre.attributes.symbolImage
		nsfwButton.isHidden = genre.attributes.isNSFW ? false : true
	}
}
