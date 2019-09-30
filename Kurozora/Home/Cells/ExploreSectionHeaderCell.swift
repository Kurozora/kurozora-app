//
//  ExploreSectionHeaderCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ExploreSectionHeaderCell: UICollectionReusableView {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var seeAllButton: UIButton! {
		didSet {
			seeAllButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}

	// MARK: - Properties
	var homeCollectionViewController: HomeCollectionViewController? = nil
	var category: ExploreCategory? = nil {
		didSet {
			configureCell()
		}
	}
	var title: String? = nil {
		didSet {
			category = nil
			configureCell()
		}
	}

	// MARK: - Functions
	private func configureCell() {
		if category != nil {
			titleLabel.text = category?.title
		} else {
			titleLabel.text = title
		}

		// See All button
		seeAllButton.isHidden = (titleLabel.text == "Top Genres") ? false : true
	}

	// MARK: - IBActions
	@IBAction func seeAllButtonPressed(_ sender: UIButton) {
		homeCollectionViewController?.performSegue(withIdentifier: "GenresSegue", sender: self)
	}
}
