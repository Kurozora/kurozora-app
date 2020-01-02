//
//  SectionHeaderReusableView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SectionHeaderReusableView: UICollectionReusableView {
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
	var title: String? = nil {
		didSet {
			configureCell()
		}
	}
	var segueID: String?

	// MARK: - Functions
	private func configureCell() {
		// Configure title
		self.primaryLabel.text = title

		// Show or hide see all button
		if let segueID = segueID {
			self.actionButton.isHidden = segueID.isEmpty
		}
	}

	// MARK: - IBActions
	@IBAction func seeAllButtonPressed(_ sender: UIButton) {
		guard let segueID = segueID else { return }
		self.parentViewController?.performSegue(withIdentifier: segueID, sender: self)
	}
}
