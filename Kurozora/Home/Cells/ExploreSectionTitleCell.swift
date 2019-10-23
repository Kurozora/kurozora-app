//
//  ExploreSectionTitleCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ExploreSectionTitleCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel! {
		didSet {
			primaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var actionButton: UIButton! {
		didSet {
			actionButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	// MARK: - Properties
	var exploreCategory: ExploreCategory? = nil {
		didSet {
			configureCell()
		}
	}
	var title: String? = nil {
		didSet {
			exploreCategory = nil
			configureCell()
		}
	}

	// MARK: - Functions
	private func configureCell() {
		// Configure title
		primaryLabel.text = exploreCategory?.title ?? title

		// Show or hide see all button
		actionButton.isHidden = exploreCategory?.genres?.isEmpty ?? true
	}

	// MARK: - IBActions
	@IBAction func seeAllButtonPressed(_ sender: UIButton) {
		self.parentViewController?.performSegue(withIdentifier: "GenresSegue", sender: self)
	}
}
