//
//  ThemesCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ThemesCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
    @IBOutlet weak var themeScreenshot: UIImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var downloadCountLabel: KSecondaryLabel!
	@IBOutlet weak var getThemeButton: KTintedButton! {
		didSet {
			NotificationCenter.default.addObserver(self, selector: #selector(updateGetThemeButton), name: .ThemeUpdateNotification, object: nil)
		}
	}
	@IBOutlet weak var moreButton: UIButton!

	// MARK: - Properties
	weak var delegate: ThemesCollectionViewCellDelegate?
	var indexPath: IndexPath!
	var theme: Theme! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		titleLabel.text = theme.attributes.name

		let themeBackgroundColorHex = theme.attributes.backgroundColor ?? "#333333"
		themeScreenshot.backgroundColor = UIColor(hexString: themeBackgroundColorHex)
		themeScreenshot.setImage(with: theme.attributes.screenshot, placeholder: #imageLiteral(resourceName: "Empty/Themes"))

		// Configure buy state
//		if let themeBought = theme.attributes.currentUser?.themeBought {
//		}

		// Configure download count
		let downloadCount = theme.attributes.downloadCount ?? 0
		switch downloadCount {
		case 0:
			downloadCountLabel.text = ""
		case 1:
			downloadCountLabel.text = "\(downloadCount) Download"
		default:
			downloadCountLabel.text = "\(downloadCount.kkFormatted) Downloads"
		}

		shouldHideMoreButton()
		updateGetThemeButton()
	}

	/// Checks whether to hide or unhide the more button for the current cell.
	fileprivate func shouldHideMoreButton() {
		switch (indexPath.section, indexPath.row) {
		case (0, 0...5):
			moreButton.isHidden = true
		default:
			// More button hidden by default. If theme exists then unhide.
			moreButton.isHidden = !KThemeStyle.themeExist(for: theme.id)
		}
	}

	/// Sets the correct title for `getThemeButton`.
	@objc func updateGetThemeButton() {
		if !UserSettings.currentTheme.isEmpty {
			let currentThemeID = UserSettings.currentTheme

			switch indexPath {
			case [0, 0]:
				if currentThemeID == "Default" {
					getThemeButton.setTitle("USING", for: .normal)
					return
				}
			case [0, 1]:
				if currentThemeID == "Day" {
					getThemeButton.setTitle("USING", for: .normal)
					return
				}
			case [0, 2]:
				if currentThemeID == "Night" || currentThemeID == "Black" {
					getThemeButton.setTitle("USING", for: .normal)
					return
				}
			case [0, 3]:
				if currentThemeID == "Grass" {
					getThemeButton.setTitle("USING", for: .normal)
					return
				}
			case [0, 4]:
				if currentThemeID == "Sky" {
					getThemeButton.setTitle("USING", for: .normal)
					return
				}
			case [0, 5]:
				if currentThemeID == "Sakkura" {
					getThemeButton.setTitle("USING", for: .normal)
					return
				}
			default:
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
			let alertController = UIApplication.topViewController?.presentAlertController(title: "Not Downloaded", message: "Download the theme right now?", defaultActionButtonTitle: "Cancel")
			alertController?.addAction(UIAlertAction(title: "Download", style: .default) { [weak self] _ in
				self?.handleDownloadTheme()
			})
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

			let alertController = UIApplication.topViewController?.presentAlertController(title: isSuccess ? "Finished removing!" : "Removing failed :(", message: nil)
			DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
				alertController?.dismiss(animated: true, completion: nil)
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
