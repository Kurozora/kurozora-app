//
//  IconTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class IconTableViewCell: SelectableSettingsCell {
	// MARK: - Functions
	func configureCell(using alternativeIconsElement: AlternativeIconsElement?) {
		guard let alternativeIconsElement = alternativeIconsElement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = alternativeIconsElement.name

		let image: UIImage?
		if alternativeIconsElement.name == "Kurozora" {
			image = UIImage(named: alternativeIconsElement.name)
		} else {
			image = UIImage(named: "\(alternativeIconsElement.name) Preview")
		}
		self.iconImageView?.image = image
	}

	func configureCell(using browser: KBrowser?) {
		guard let browser = browser else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = browser.stringValue
		self.iconImageView?.image = browser.image
	}

	func configureCell(using appChimeElement: AppChimeElement?) {
		guard let appChimeElement = appChimeElement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = appChimeElement.name
		self.iconImageView?.image = UIImage(systemName: "speaker.wave.3")
	}
}
