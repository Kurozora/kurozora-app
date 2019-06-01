//
//  ExploreSectionHeaderCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ExploreSectionHeaderCell: UICollectionReusableView {
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
			titleLabel.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var seeAllButton: UIButton!
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	var homeCollectionViewController: HomeCollectionViewController? = nil
	var category: ExploreCategory? = nil {
		didSet {
			setup()
		}
	}
	var title: String? = nil {
		didSet {
			category = nil
			setup()
		}
	}

	private func setup() {
		if category != nil {
			titleLabel.text = category?.title
		} else {
			titleLabel.text = title
		}

		// See All button
		seeAllButton.isHidden = (titleLabel.text == "Top Genres") ? false : true
		seeAllButton.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}


	@IBAction func seeAllButtonPressed(_ sender: UIButton) {
		homeCollectionViewController?.performSegue(withIdentifier: "GenresSegue", sender: self)
	}
}
