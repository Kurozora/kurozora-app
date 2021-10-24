//
//  IconTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class IconTableViewCell: SelectableSettingsCell {
	// MARK: - Properties
	/// The object containing the `AlternativeIconsElement` information.
	var alternativeIconsElement: AlternativeIconsElement! {
		didSet {
			if self.alternativeIconsElement != nil {
				self.browser = nil
				self.configureCell()
			}
		}
	}

	/// The object containing the `KBrowser` type.
	var browser: KBrowser! {
		didSet {
			if self.browser != nil {
				self.alternativeIconsElement = nil
				self.configureCell()
			}
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		if self.alternativeIconsElement != nil {
			self.primaryLabel?.text = self.alternativeIconsElement.name
			self.iconImageView?.image = UIImage(named: self.alternativeIconsElement.name)
		} else {
			primaryLabel?.text = browser.stringValue
			iconImageView?.image = browser.image
		}
	}
}
