//
//  ThemesCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView

class ThemesCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
    @IBOutlet weak var themeScreenshot: UIImageView!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var downloadCountLabel: UILabel! {
		didSet {
			downloadCountLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var getThemeButton: KTintedButton! {
		didSet {
			NotificationCenter.default.addObserver(self, selector: #selector(updateGetThemeButton), name: .ThemeUpdateNotification, object: nil)
		}
	}
	@IBOutlet weak var moreButton: UIButton!

	// MARK: - Properties
	var themeElement: ThemeElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let themeElement = themeElement else { return }

		titleLabel.text = themeElement.name
		if let themeBackgroundColor = themeElement.backgroundColor {
			let themeBackgroundColorHex = themeBackgroundColor.isEmpty ? "#333333" : themeBackgroundColor
			themeScreenshot.backgroundColor = UIColor(hexString: themeBackgroundColorHex)
		}

		// Configure buy state
//		if let themeBought = themeElement.currentUser?.themeBought {
//
//		}

		// Configure download count
		if let downloadCount = themeElement.downloadCount {
			switch downloadCount {
			case 0:
				downloadCountLabel.text = ""
			case 1:
				downloadCountLabel.text = "\(downloadCount) Download"
			default:
				downloadCountLabel.text = "\(downloadCount.kFormatted) Downloads"
			}
		}

		shouldHideMoreButton()
		updateGetThemeButton()
		shadowView.applyShadow()
	}

	/// Checks whether to hide or unhide the more button for the current cell.
	fileprivate func shouldHideMoreButton() {
		guard let indexPathItem = indexPath?.item else { return }

		switch indexPathItem {
		case 0...2:
			moreButton.isHidden = true
		default:
			// More button hidden by default. If theme exists then unhide.
			moreButton.isHidden = !KThemeStyle.themeExist(for: themeElement?.id)
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
			default:
				if Int(currentThemeID) == themeElement?.id {
					getThemeButton.setTitle("USING", for: .normal)
					return
				} else if !KThemeStyle.themeExist(for: themeElement?.id) {
					getThemeButton.setTitle("GET", for: .normal)
					return
				}
			}

			getThemeButton.setTitle("USE", for: .normal)
		}
	}

	/// Checks whether the selected theme should be downloaded or else applied.
	fileprivate func shouldDownloadTheme() {
		guard let themeID = themeElement?.id else { return }
		guard KThemeStyle.themeExist(for: themeID) else {
			let alert = SCLAlertView()
			alert.addButton("Sure") {
				self.handleDownloadTheme()
			}
			alert.showInfo("Not Downloaded", subTitle: "Download the theme right now?", closeButtonTitle: "Cancel")
			return
		}

		KThemeStyle.switchTo(theme: themeID)
	}

	/// Handle the download process for the selected theme.
	fileprivate func handleDownloadTheme() {
		guard let themeName = themeElement?.name else { return }
		guard let themeID = themeElement?.id else { return }
		let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
		let sclAlertView = SCLAlertView(appearance: appearance).showWait("Downloading \(themeName)...")

		KThemeStyle.downloadThemeTask(for: themeElement) { isSuccess in
			sclAlertView.setTitle(isSuccess ? "Finished downloading!" : "Download failed :(")

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				sclAlertView.close()
			}

			if isSuccess {
				KThemeStyle.switchTo(theme: themeID)
				self.shouldHideMoreButton()
			}
		}
	}

	/// Handle the removing process for a downloaded theme.
	fileprivate func handleRemoveTheme(timeout: Double = 0.5, withSuccess successHandler: ((_ isSuccess: Bool) -> Void)? = nil) {
		guard let themeName = themeElement?.name else { return }
		let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
		let sclAlertView = SCLAlertView(appearance: appearance).showWait("Removing \(themeName)...")

		KThemeStyle.removeThemeTask(for: themeElement) { isSuccess in
			sclAlertView.setTitle(isSuccess ? "Finished removing!" : "Removing failed :(")

			DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
				sclAlertView.close()
			}

			if isSuccess {
				self.shouldHideMoreButton()
			}

			successHandler?(isSuccess)
		}
	}

	/// Handle the redownload process for a downloaded theme.
	fileprivate func handleRedownloadTheme() {
		handleRemoveTheme(timeout: 0) { success in
			if success {
				self.handleDownloadTheme()
			}
		}
	}

	// MARK: - IBActions
	@IBAction func getThemeButtonPressed(_ sender: UIButton) {
		switch indexPath {
		case [0, 0]:
			KThemeStyle.switchTo(.default)
		case [0, 1]:
			KThemeStyle.switchTo(.day)
		case [0, 2]:
			KThemeStyle.switchTo(.night)
		default:
			shouldDownloadTheme()
		}
	}

	@IBAction func moreButtonPressed(_ sender: UIButton) {
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let redownloadAction = UIAlertAction(title: "Redownload theme", style: .default, handler: { (_) in
			self.handleRedownloadTheme()
		})
		let removeAction = UIAlertAction(title: "Remove theme", style: .destructive, handler: { (_) in
			self.handleRemoveTheme()
			if UserSettings.currentTheme.int == self.themeElement?.id {
				KThemeStyle.switchTo(.default)
			}
		})

		// Add image
		redownloadAction.setValue(R.image.symbols.arrow_uturn_down()!, forKey: "image")
		removeAction.setValue(R.image.symbols.trash_fill()!, forKey: "image")

		// Left align title
		redownloadAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		removeAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

		action.addAction(redownloadAction)
		action.addAction(removeAction)

		// Add cancel action
		action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}

		if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.parentViewController?.present(action, animated: true, completion: nil)
		}
	}
}
