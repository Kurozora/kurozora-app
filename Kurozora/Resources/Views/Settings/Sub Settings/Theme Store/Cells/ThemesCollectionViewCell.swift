//
//  ThemesCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol ThemesCollectionViewCellDelegate: AnyObject {
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressGetButton button: UIButton)
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressMoreButton button: UIButton)
}

class ScreenshotView: UIView {
	@IBOutlet weak var screenshotImageView: PosterImageView!
}

class ThemesCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var downloadCountLabel: KSecondaryLabel!
	@IBOutlet weak var getThemeButton: KTintedButton! {
		didSet {
			NotificationCenter.default.addObserver(self, selector: #selector(updateGetThemeButton), name: .ThemeUpdateNotification, object: nil)
		}
	}
	@IBOutlet weak var moreButton: KButton!
	@IBOutlet var screenshotViews: [ScreenshotView]!
	@IBOutlet weak var screenshotsStackView: UIStackView!

	// MARK: - Properties
	weak var delegate: ThemesCollectionViewCellDelegate?
	var kTheme: KTheme = .kurozora {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		self.titleLabel.text = self.kTheme.stringValue
		self.downloadCountLabel.text = self.kTheme.descriptionValue

		// Configure more button
		self.moreButton.layerCornerRadius = self.moreButton.frame.size.height / 2
		self.moreButton.addBlurEffect()
		self.moreButton.theme_tintColor = KThemePicker.textColor.rawValue

		switch self.kTheme {
		case .other(let theme):
			let screenshots = theme.attributes.screenshots
			for (index, screenshot) in screenshots.enumerated() {
				switch screenshots.count {
				case 1:
					self.screenshotViews.enumerated().reversed().forEach { index, screenshotView in
						if index < 2 {
							screenshotView.isHidden = true
						}
					}
				case 2:
					self.screenshotViews.enumerated().reversed().forEach { index, screenshotView in
						if index < 1 {
							screenshotView.isHidden = true
						}
					}
				default:
					self.screenshotViews.reversed().forEach { screenshotView in
						screenshotView.isHidden = false
					}
				}
				let screenshotView = self.screenshotViews[index]
				screenshotView.screenshotImageView.backgroundColor = UIColor(hexString: screenshot.backgroundColor ?? "#333333")
				screenshotView.screenshotImageView.setImage(with: screenshot.url, placeholder: #imageLiteral(resourceName: "Empty/Themes"))

					// Stop after 3 screenshots
				if index == 2 { break }
			}
		default:
			for (index, image) in self.kTheme.imageValues.enumerated() {
				let screenshotView = self.screenshotViews[index]
				screenshotView.screenshotImageView.backgroundColor = self.kTheme.colorValue
				screenshotView.screenshotImageView.image = image
				screenshotView.isHidden = false

					// Stop after 3 screenshots
				if index == 2 { break }
			}
		}

		self.shouldHideMoreButton()
		self.updateGetThemeButton()
	}

	/// Checks whether to hide or unhide the more button for the current cell.
	func shouldHideMoreButton() {
		switch self.kTheme {
		case .other(let theme):
			// More button hidden by the default case. If theme exists then unhide.
			self.moreButton.isHidden = !KThemeStyle.themeExist(for: theme)
		default:
			self.moreButton.isHidden = true
		}
	}

	/// Sets the correct title for `getThemeButton`.
	@objc func updateGetThemeButton() {
		let currentThemeID = UserSettings.currentTheme

		switch self.kTheme {
		case .other(let theme):
            if currentThemeID == theme.id.rawValue {
				if User.isPro || User.isSubscribed {
					if KThemeStyle.isUpToDate(theme.id, version: theme.attributes.version) {
						self.getThemeButton.setTitle("USING", for: .normal)
					} else {
						self.getThemeButton.setTitle("UPDATE", for: .normal)
					}
				} else {
					self.getThemeButton.setTitle("USING", for: .normal)
				}
			} else if KThemeStyle.themeExist(for: theme) {
				if User.isPro || User.isSubscribed {
					if KThemeStyle.isUpToDate(theme.id, version: theme.attributes.version) {
						self.getThemeButton.setTitle("USE", for: .normal)
					} else {
						self.getThemeButton.setTitle("UPDATE", for: .normal)
					}
				} else {
					self.getThemeButton.setTitle("USE", for: .normal)
				}
			} else {
				self.getThemeButton.setTitle("GET", for: .normal)
			}
		default:
			if self.kTheme.isEqual(currentThemeID) {
				self.getThemeButton.setTitle("USING", for: .normal)
			} else {
				self.getThemeButton.setTitle("USE", for: .normal)
			}
		}
	}

	// MARK: - IBActions
	@IBAction func getThemeButtonPressed(_ sender: UIButton) {
		self.delegate?.themesCollectionViewCell(self, didPressGetButton: sender)
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		self.delegate?.themesCollectionViewCell(self, didPressMoreButton: sender)
	}
}
