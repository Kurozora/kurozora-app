//
//  ThemesCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView

class ThemesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var themeScreenshot: UIImageView!
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var downloadCountLabel: UILabel! {
		didSet {
			downloadCountLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}
	@IBOutlet weak var getThemeButton: UIButton! {
		didSet {
			getThemeButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			getThemeButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var moreButton: UIButton!

	var indexPathItem: Int = 0
	var themesElement: ThemesElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let themesElement = themesElement else { return }

		switch indexPathItem {
		case 0:
			titleLabel.text = "Default"
			themeScreenshot.backgroundColor = .kGrayishNavy
		case 1:
			titleLabel.text = "Day"
			themeScreenshot.backgroundColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
		case 2:
			titleLabel.text = "Night"
			themeScreenshot.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
		default:
			titleLabel.text = themesElement.name
			themeScreenshot.backgroundColor = UIColor.random
		}

		// Configure get theme button
		getThemeButton.tag = indexPathItem
		getThemeButton.addTarget(self, action: #selector(getThemeButtonPressed(_:)), for: .touchUpInside)

		// Configure buy state
//		if let themeBought = themesElement.currentUser?.themeBought {
//
//		}

		// Configure download count
		if let downloadCount = themesElement.downloadCount {
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
	}

	/// Checks whether to hide or unhide the more button for the current cell.
	fileprivate func shouldHideMoreButton() {
		switch indexPathItem {
		case 0...2:
			moreButton.isHidden = true
		default:
			moreButton.isHidden = !KThemeStyle.themeExist(for: themesElement?.id) // If exists unhide, else hide.
		}
	}

	/// Sets the correct title for `getThemeButton`.
	fileprivate func updateGetThemeButton() {
		switch indexPathItem {
		case 0...2:
			getThemeButton.setTitle("USE", for: .normal)
		default:
			getThemeButton.setTitle((KThemeStyle.themeExist(for: themesElement?.id) ? "USE" : "GET"), for: .normal)
		}
	}

	/// Checks whether the selected theme should be downloaded or else applied.
	fileprivate func shouldDownloadTheme() {
		guard let themeID = themesElement?.id else { return }
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
		guard let themeName = themesElement?.name else { return }
		guard let themeID = themesElement?.id else { return }
		let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
		let sclAlertView = SCLAlertView(appearance: appearance).showWait("Downloading \(themeName)...")

		KThemeStyle.downloadThemeTask(for: themesElement) { isSuccess in
			sclAlertView.setTitle(isSuccess ? "Finished downloading!" : "Download failed :(")

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				sclAlertView.close()
			}

			if isSuccess {
				self.updateGetThemeButton()
				self.shouldHideMoreButton()
				KThemeStyle.switchTo(theme: themeID)
			}
		}
	}

	/// Handle the removing process for a downloaded theme.
	fileprivate func handleRemoveTheme() {
		guard let themeName = themesElement?.name else { return }
		let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
		let sclAlertView = SCLAlertView(appearance: appearance).showWait("Removing \(themeName)...")

		KThemeStyle.removeThemeTask(for: themesElement) { isSuccess in
			sclAlertView.setTitle(isSuccess ? "Finished removing!" : "Removing failed :(")

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				sclAlertView.close()
			}

			if isSuccess {
				self.updateGetThemeButton()
				self.shouldHideMoreButton()
			}
		}
	}

	/**
		Switches the theme used throught the app to the selected theme.

		- Parameter sender: The button sending the request for switching the theme.
	*/
	@objc func getThemeButtonPressed(_ sender: UIButton) {
		switch sender.tag {
		case 0:
			KThemeStyle.switchTo(.default)
		case 1:
			KThemeStyle.switchTo(.day)
		case 2:
			KThemeStyle.switchTo(.night)
		default:
			shouldDownloadTheme()
		}
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIButton) {
		let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		controller.addAction(UIAlertAction(title: "Remove theme", style: .destructive, handler: { (_) in
			self.handleRemoveTheme()
		}))
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.parentViewController?.present(controller, animated: true, completion: nil)
		}
	}
}
