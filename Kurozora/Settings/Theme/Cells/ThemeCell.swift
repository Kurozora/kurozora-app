//
//  ThemeCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView

class ThemeCell: UICollectionViewCell {
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
	@IBOutlet weak var buyButton: UIButton! {
		didSet {
			buyButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			buyButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var moreButton: UIButton!

	var row: Int = 0
	var themesElement: ThemesElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	fileprivate func configureCell() {
		guard let themesElement = themesElement else { return }
		titleLabel.text = themesElement.name

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

//		if let themeBought = themesElement.currentUser?.themeBought {

//		}

		if row == 0 {
			themeScreenshot.backgroundColor = .kGrayishNavy
			buyButton.addTarget(self, action: #selector(defaultThemePressed(_:)), for: .touchUpInside)
		} else if row == 1 {
			themeScreenshot.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
			buyButton.addTarget(self, action: #selector(dayThemePressed(_:)), for: .touchUpInside)
		} else if row == 2 {
			themeScreenshot.backgroundColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
			buyButton.addTarget(self, action: #selector(nightThemePressed(_:)), for: .touchUpInside)
		} else {
			themeScreenshot.backgroundColor = UIColor.random
			buyButton.addTarget(self, action: #selector(downloadThemePressed(_:)), for: .touchUpInside)
		}

		shouldHideMoreButton()
		updateBuyButton()
	}

	/**
		Checks whether to hide or unhide the more button for the current cell.

		- Parameter row: The row number fot the cell for which the more button should be hidden or unhidden.
	*/
	fileprivate func shouldHideMoreButton() {
		switch row {
		case 0...2:
			moreButton.isHidden = true
		default:
			moreButton.isHidden = !KThemeStyle.themeExist(for: themesElement?.id) // If exists unhide, else hide.
		}
	}

	fileprivate func updateBuyButton() {
		switch row {
		case 0...2:
			buyButton.setTitle("USE", for: .normal)
		default:
			buyButton.setTitle((KThemeStyle.themeExist(for: themesElement?.id) ? "USE" : "GET"), for: .normal)
		}
	}

	/// Checks whether the selected theme should be downloaded or else applied.
	fileprivate func shouldDownloadTheme() {
		guard let themeID = themesElement?.id else { return }
		guard KThemeStyle.themeExist(for: themeID) else {
			let alert = SCLAlertView()
			alert.addButton("Sure") {
				self.downloadTheme()
			}
			alert.showInfo("Not Downloaded", subTitle: "Download the theme right now?", closeButtonTitle: "Cancel")
			return
		}

		KThemeStyle.switchTo(theme: themeID)
	}

	/// Start the download process for the selected theme.
	fileprivate func downloadTheme() {
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
				self.updateBuyButton()
				self.shouldHideMoreButton()
				KThemeStyle.switchTo(theme: themeID)
			}
		}
	}

	/// Removes a downloaded theme.
	fileprivate func removeTheme() {
		guard let themeName = themesElement?.name else { return }
		let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
		let sclAlertView = SCLAlertView(appearance: appearance).showWait("Removing \(themeName)...")

		KThemeStyle.removeThemeTask(for: themesElement) { isSuccess in
			sclAlertView.setTitle(isSuccess ? "Finished removing!" : "Removing failed :(")

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				sclAlertView.close()
			}

			if isSuccess {
				self.updateBuyButton()
				self.shouldHideMoreButton()
			}
		}
	}

	@objc func defaultThemePressed(_ sender: UIButton) {
		KThemeStyle.switchTo(.default)
	}

	@objc func dayThemePressed(_ sender: UIButton) {
		KThemeStyle.switchTo(.day)
	}

	@objc func nightThemePressed(_ sender: UIButton) {
		KThemeStyle.switchTo(.night)
	}

	@objc func downloadThemePressed(_ sender: UIButton) {
		shouldDownloadTheme()
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIButton) {
		let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		controller.addAction(UIAlertAction(title: "Remove theme", style: .destructive, handler: { (_) in
			self.removeTheme()
		}))
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

//		if (navigationController?.visibleViewController as? UIAlertController) == nil {
		self.parentViewController?.present(controller, animated: true, completion: nil)
//		}
	}
}
