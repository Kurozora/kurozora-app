//
//  IconTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class IconTableViewCell: SelectableSettingsCell {
	// MARK: Properties
	fileprivate lazy var rainbowColors: [UIColor?] = [
		UIColor(hexString: "#FFFFFF"), // white
		UIColor(hexString: "#D87F33"), // orange
		UIColor(hexString: "#B24CD8"), // magenta
		UIColor(hexString: "#6699D8"), // light blue
		UIColor(hexString: "#E5E533"), // yellow
		UIColor(hexString: "#7FCC19"), // lime
		UIColor(hexString: "#F27FA5"), // pink
		UIColor(hexString: "#4C4C4C"), // gray
		UIColor(hexString: "#999999"), // light gray
		UIColor(hexString: "#4C7F99"), // cyan
		UIColor(hexString: "#334CB2"), // blue
		UIColor(hexString: "#7F3FB2"), // purple
		UIColor(hexString: "#667F33"), // green
		UIColor(hexString: "#664C33"), // brown
		UIColor(hexString: "#993333"), // red
		UIColor(hexString: "#000000")  // black
	]
	fileprivate var colorCycleTimer: Timer?

	// MARK: View
	override func prepareForReuse() {
		super.prepareForReuse()
		stopColorCycling()
	}

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
		self.iconImageView?.preferredSymbolConfiguration = nil
		self.iconImageView?.contentMode = .scaleAspectFit
		self.iconImageView?.layerCornerRadius = 10.0
	}

	func configureCell(using browser: KBrowser?) {
		guard let browser = browser else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = browser.stringValue
		self.iconImageView?.image = browser.image
		self.iconImageView?.preferredSymbolConfiguration = nil
		self.iconImageView?.contentMode = .scaleAspectFit
		self.iconImageView?.layerCornerRadius = 10.0
	}

	func configureCell(using appChimeElement: AppChimeElement?) {
		guard let appChimeElement = appChimeElement else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel?.text = appChimeElement.name
		self.iconImageView?.image = UIImage(systemName: "speaker.wave.3")
		self.iconImageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular, scale: .default)
		self.iconImageView?.contentMode = .center
		self.iconImageView?.layerCornerRadius = 0.0

		if !self.selectedImageView.isHidden && appChimeElement.name == "jeb_" {
			self.startColorCycling()
		} else {
			self.primaryLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	fileprivate func startColorCycling() {
		self.colorCycleTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
			guard let self = self else { return }
			self.applyRainbowColors()
		}
		guard let colorCycleTimer = self.colorCycleTimer else { return }
		RunLoop.main.add(colorCycleTimer, forMode: .common)
	}

	fileprivate func stopColorCycling() {
		self.colorCycleTimer?.invalidate()
		self.colorCycleTimer = nil
	}

	fileprivate func applyRainbowColors() {
		let colorCycle = self.rainbowColors.rotate(by: -1)
		guard let textColor = colorCycle.first else { return }
		guard let primaryLabel = self.primaryLabel else { return }

		UIView.transition(with: primaryLabel, duration: 0.5, options: .transitionCrossDissolve) {
			self.primaryLabel?.textColor = textColor
		}
	}
}
