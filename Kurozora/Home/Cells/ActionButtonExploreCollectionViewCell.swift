//
//  ActionButtonExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ActionButtonExploreCollectionViewCell: ActionBaseExploreCollectionViewCell {
	// MARK: - IBOutlets
	override var actionButton: KButton? {
		didSet {
			actionButton?.theme_backgroundColor = KThemePicker.tintColor.rawValue
			actionButton?.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		guard let actionItem = actionItem else { return }
		if let segueID = actionItem["segueId"] {
			self.parentViewController?.performSegue(withIdentifier: segueID, sender: nil)
		}
	}
}
