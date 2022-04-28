//
//  ThemesCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ScreenshotView: UIView {
	@IBOutlet weak var screenshotImageView: UIImageView!
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

		switch self.kTheme {
		case .other(let theme):
			let screenshots = theme.attributes.screenshots
			for (index, screenshot) in screenshots.enumerated() {
				switch screenshots.count {
				case 1:
					self.screenshotViews.enumerated().forEachReversed { index, screenshotView in
						if index < 2 {
							screenshotView.isHidden = true
						}
					}
				case 2:
					self.screenshotViews.enumerated().forEachReversed { index, screenshotView in
						if index < 1 {
							screenshotView.isHidden = true
						}
					}
				default:
					self.screenshotViews.forEachReversed { screenshotView in
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

		shouldHideMoreButton()
		updateGetThemeButton()
	}

	/// Checks whether to hide or unhide the more button for the current cell.
	func shouldHideMoreButton() {
		switch self.kTheme {
		case .other(let theme):
			// More button hidden by the default case. If theme exists then unhide.
			moreButton.isHidden = !KThemeStyle.themeExist(for: theme)
		default:
			moreButton.isHidden = true
		}
	}

	/// Sets the correct title for `getThemeButton`.
	@objc func updateGetThemeButton() {
		let currentThemeID = UserSettings.currentTheme

		switch self.kTheme {
		case .other(let theme):
			if Int(currentThemeID) == theme.id {
				if User.isPro {
					if KThemeStyle.isUpToDate(theme.id, version: theme.attributes.version) {
						getThemeButton.setTitle("USING", for: .normal)
					} else {
						getThemeButton.setTitle("UPDATE", for: .normal)
					}
				} else {
					getThemeButton.setTitle("USING", for: .normal)
				}
			} else if KThemeStyle.themeExist(for: theme) {
				if User.isPro {
					if KThemeStyle.isUpToDate(theme.id, version: theme.attributes.version) {
						getThemeButton.setTitle("USE", for: .normal)
					} else {
						getThemeButton.setTitle("UPDATE", for: .normal)
					}
				} else {
					getThemeButton.setTitle("USE", for: .normal)
				}
			} else {
				getThemeButton.setTitle("GET", for: .normal)
			}
		default:
			if self.kTheme.isEqual(currentThemeID) {
				getThemeButton.setTitle("USING", for: .normal)
			} else {
				getThemeButton.setTitle("USE", for: .normal)
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
