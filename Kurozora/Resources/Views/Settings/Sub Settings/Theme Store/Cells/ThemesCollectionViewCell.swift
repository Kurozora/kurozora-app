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
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressGetButton button: UIView)
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, downloadStateFor appTheme: AppTheme) -> KDownloadButtonState
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, menuFor appTheme: AppTheme) -> UIMenu?
}

class ScreenshotView: UIView {
	@IBOutlet weak var screenshotImageView: PosterImageView!
	@IBOutlet weak var screenshotBorderView: BorderView!
}

class ThemesCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var downloadCountLabel: KSecondaryLabel!
	@IBOutlet weak var getThemeButton: KDownloadButton! {
		didSet {
			self.getThemeButton.onTap = { [weak self] _ in
				guard let self = self else { return }
				self.delegate?.themesCollectionViewCell(self, didPressGetButton: self.getThemeButton)
			}
			NotificationCenter.default.addObserver(self, selector: #selector(self.refreshAffordance), name: .ThemeUpdateNotification, object: nil)
		}
	}
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
		self.titleLabel.text = self.kTheme.displayName
		self.downloadCountLabel.text = self.kTheme.descriptionValue

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
				screenshotView.screenshotImageView.setImage(with: screenshot.url, placeholder: .Empty.themes)

				screenshotView.screenshotImageView.applyCornerRadius(10.0)
				screenshotView.screenshotImageView.layer.borderWidth = 0
				screenshotView.screenshotBorderView.cornerRadius = 10.0

				// Stop after 3 screenshots
				if index == 2 { break }
			}
		default:
			for (index, image) in self.kTheme.imageValues.enumerated() {
				let screenshotView = self.screenshotViews[index]
				screenshotView.screenshotImageView.backgroundColor = self.kTheme.colorValue
				screenshotView.screenshotImageView.image = image
				screenshotView.isHidden = false

				screenshotView.screenshotImageView.applyCornerRadius(10.0)
				screenshotView.screenshotImageView.layer.borderWidth = 0
				screenshotView.screenshotBorderView.cornerRadius = 10.0

				// Stop after 3 screenshots
				if index == 2 { break }
			}
		}

		self.refreshAffordance()
	}

	@objc func refreshAffordance() {
		self.getThemeButton.menu = self.computedMenu()
		self.getThemeButton.setState(self.computedDownloadState(), animated: self.window != nil)
	}

	private func computedDownloadState() -> KDownloadButtonState {
		switch self.kTheme {
		case .other(let theme):
			if let delegate = self.delegate {
				return delegate.themesCollectionViewCell(self, downloadStateFor: theme)
			}
			return .start(title: L10n.themeButtonGet)
		default:
			let currentThemeID = UserSettings.currentTheme

			if self.kTheme.isEqual(currentThemeID) {
				return .downloaded(title: L10n.themeButtonUsing, opensMenuOnTap: false)
			}

			return .start(title: L10n.themeButtonUse)
		}
	}

	private func computedMenu() -> UIMenu? {
		switch self.kTheme {
		case .other(let theme):
			return self.delegate?.themesCollectionViewCell(self, menuFor: theme)
		default:
			return nil
		}
	}
}
