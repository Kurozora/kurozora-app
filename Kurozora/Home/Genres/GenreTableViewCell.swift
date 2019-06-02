//
//  GenreTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class GenreTableViewCell: UITableViewCell {
	@IBOutlet weak var nameLabel: UILabel! {
		didSet {
			nameLabel.theme_textColor = KThemePicker.textColor.rawValue
			nameLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var nsfwView: UIView!
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	var genreElement: GenreElement? {
		didSet {
			setupCell()
		}
	}

	fileprivate func setupCell() {
		guard let genreElement = genreElement else { return }

		nameLabel.text = genreElement.name

		if let isNsfw = genreElement.nsfw {
			nsfwView.isHidden = isNsfw ? false : true
		}
	}
}
