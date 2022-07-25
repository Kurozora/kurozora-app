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
	var alternativeIconsElement: AlternativeIconsElement?

	/// The object containing the `KBrowser` type.
	var browser: KBrowser?

	// MARK: - Functions
	func configureCell(using alternativeIconsElement: AlternativeIconsElement?) {
		self.alternativeIconsElement = alternativeIconsElement
		guard let alternativeIconsElement = alternativeIconsElement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = alternativeIconsElement.name
		self.iconImageView?.image = UIImage(named: alternativeIconsElement.name)
	}

	func configureCell(using browser: KBrowser?) {
		self.browser = browser
		guard let browser = browser else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = browser.stringValue
		self.iconImageView?.image = browser.image
	}
}
