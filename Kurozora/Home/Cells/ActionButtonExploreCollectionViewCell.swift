//
//  ActionButtonExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ActionButtonExploreCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var actionButton: KButton! {
		didSet {
			actionButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			actionButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	var actionButtonItem: [String: String]? {
		didSet {
			configureCell()
		}
	}
	var homeCollectionViewController: HomeCollectionViewController?

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let actionButtonItem = actionButtonItem else { return }
		actionButton.setTitle(actionButtonItem["title"], for: .normal)
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
		guard let actionButtonItem = actionButtonItem else { return }
		if let segueID = actionButtonItem["segueId"] {
			homeCollectionViewController?.performSegue(withIdentifier: segueID, sender: nil)
		}
	}
}
