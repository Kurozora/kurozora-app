//
//  GenreTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class GenreTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var nameLabel: KLabel!
	@IBOutlet weak var nsfwButton: UIButton!
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	var genre: Genre! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		nameLabel.text = genre.attributes.name

		nsfwButton.isHidden = genre.attributes.isNSFW ? false : true
	}
}
