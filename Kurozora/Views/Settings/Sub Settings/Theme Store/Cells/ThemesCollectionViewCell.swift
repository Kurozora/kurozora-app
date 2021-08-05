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
	@IBOutlet weak var moreButton: UIButton!
	@IBOutlet var screenshotViews: [ScreenshotView]!
	@IBOutlet weak var screenshotsStackView: UIStackView!

	// MARK: - Properties
	weak var delegate: ThemesCollectionViewCellDelegate?
	var defaultTheme: DefaultTheme? = nil {
		didSet {
			if defaultTheme != nil {
				self.theme = nil
				self.configureCell()
			}
		}
	}
	var theme: Theme! {
		didSet {
			if theme != nil {
				self.defaultTheme = nil
				self.configureCell()
			}
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		if let defaultTheme = self.defaultTheme {
			self.titleLabel.text = defaultTheme.stringValue
			self.downloadCountLabel.text = defaultTheme.descriptionValue

			for (index, image) in defaultTheme.imageValues.enumerated() {
				let screenshotView = self.screenshotViews[index]
				screenshotView.screenshotImageView.backgroundColor = defaultTheme.colorValue
				screenshotView.screenshotImageView.image = image
				screenshotView.isHidden = false

				// Stop after 3 screenshots
				if index == 2 { break }
			}
		} else {
			// Configure title
			self.titleLabel.text = theme.attributes.name

			// Configure download count
			let downloadCount = self.theme.attributes.downloadCount
			switch downloadCount {
			case 0:
				self.downloadCountLabel.text = "New"
			case 1:
				self.downloadCountLabel.text = "\(downloadCount) Download"
			default:
				self.downloadCountLabel.text = "\(downloadCount.kkFormatted) Downloads"
			}

			let screenshots = self.theme.attributes.screenshots
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

//			// Configure buy state
//			if let themeBought = theme.attributes.currentUser?.themeBought {
//			}
		}

		shouldHideMoreButton()
		updateGetThemeButton()
	}

	/// Checks whether to hide or unhide the more button for the current cell.
	fileprivate func shouldHideMoreButton() {
		if defaultTheme != nil {
			moreButton.isHidden = true
		} else {
			// More button hidden by default. If theme exists then unhide.
			moreButton.isHidden = !KThemeStyle.themeExist(for: theme.id)
		}
	}

	/// Sets the correct title for `getThemeButton`.
	@objc func updateGetThemeButton() {
		if !UserSettings.currentTheme.isEmpty {
			let currentThemeID = UserSettings.currentTheme

			if let defaultTheme = self.defaultTheme {
				if defaultTheme.isEqual(currentThemeID) {
					getThemeButton.setTitle("USING", for: .normal)
					return
				}
			} else {
				if Int(currentThemeID) == theme.id {
					getThemeButton.setTitle("USING", for: .normal)
					return
				} else if !KThemeStyle.themeExist(for: theme.id) {
					getThemeButton.setTitle("GET", for: .normal)
					return
				}
			}

			getThemeButton.setTitle("USE", for: .normal)
		}
	}

	/// Checks whether the selected theme should be downloaded or else applied.
	func shouldDownloadTheme() {
		let themeID = theme.id
		guard KThemeStyle.themeExist(for: themeID) else {
			WorkflowController.shared.isPro {
				let alertController = UIApplication.topViewController?.presentAlertController(title: "Not Downloaded", message: "Download the theme right now?", defaultActionButtonTitle: "Cancel")
				alertController?.addAction(UIAlertAction(title: "Download", style: .default) { [weak self] _ in
					self?.handleDownloadTheme()
				})
			}
			return
		}

		KThemeStyle.switchTo(theme: themeID)
	}

	/// Handle the download process for the selected theme.
	fileprivate func handleDownloadTheme() {
		let themeName = theme.attributes.name
		let themeID = theme.id
		let alertController = UIApplication.topViewController?.presentActivityAlertController(title: "Downloading \(themeName)...", message: nil)

		KThemeStyle.downloadThemeTask(for: theme) { isSuccess in
			alertController?.dismiss(animated: true, completion: nil)

			let alertController = UIApplication.topViewController?.presentAlertController(title: isSuccess ? "Finished downloading!" : "Download failed :(", message: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				alertController?.dismiss(animated: true, completion: nil)
			}

			if isSuccess {
				KThemeStyle.switchTo(theme: themeID)
				self.shouldHideMoreButton()
			}
		}
	}

	/// Handle the removing process for a downloaded theme.
	func handleRemoveTheme(timeout: Double = 0.5, withSuccess successHandler: ((_ isSuccess: Bool) -> Void)? = nil) {
		let themeName = theme.attributes.name
		let alertController = UIApplication.topViewController?.presentActivityAlertController(title: "Removing \(themeName)...", message: nil)

		KThemeStyle.removeThemeTask(for: theme) { isSuccess in
			alertController?.dismiss(animated: true, completion: nil)

			if !timeout.isZero {
				let alertController = UIApplication.topViewController?.presentAlertController(title: isSuccess ? "Finished removing!" : "Removing failed :(", message: nil)
				DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
					alertController?.dismiss(animated: true, completion: nil)
				}
			}

			if isSuccess {
				self.shouldHideMoreButton()
			}

			successHandler?(isSuccess)
		}
	}

	/// Handle the redownload process for a downloaded theme.
	func handleRedownloadTheme() {
		handleRemoveTheme(timeout: 0) { success in
			if success {
				self.handleDownloadTheme()
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
