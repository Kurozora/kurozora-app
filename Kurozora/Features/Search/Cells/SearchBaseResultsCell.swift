//
//  SearchBaseResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class SearchBaseResultsCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	@IBOutlet weak var actionButton: UIButton? {
		didSet {
			actionButton?.theme_backgroundColor = KThemePicker.tintColor.rawValue
			actionButton?.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var searchImageView: UIImageView!
	@IBOutlet weak var separatorView: UIView?
	@IBOutlet weak var visualEffectView: UIVisualEffectView! {
		didSet {
			visualEffectView.theme_effect = ThemeVisualEffectPicker(keyPath: KThemePicker.visualEffect.stringValue, vibrancyEnabled: true)
			visualEffectView.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
	}
}
