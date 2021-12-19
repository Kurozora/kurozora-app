//
//  ManageThemesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ManageThemesCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var themes: [Theme] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Fetch themes
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchThemes()
		}
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureDataSource()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.themes = []
		self.fetchThemes()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.themes()!)
		emptyBackgroundView.configureLabels(title: "No Themes", detail: "Themes are not available at this moment. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches themes from the server.
	func fetchThemes() {
		KService.getThemes { [weak self] result in
			switch result {
			case .success(let themes):
				DispatchQueue.main.async {
					self?.themes.append(contentsOf: themes)
				}
			case .failure: break
			}
		}
	}
}

// MARK: - ThemesCollectionViewCellDelegate
extension ManageThemesCollectionViewController: ThemesCollectionViewCellDelegate {
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressGetButton button: UIButton) {
		switch cell.kTheme {
		case .kurozora:
			KTheme.kurozora.switchToTheme()
		case .day:
			KTheme.day.switchToTheme()
		case .night:
			KTheme.night.switchToTheme()
		case .grass:
			KTheme.grass.switchToTheme()
		case .sky:
			KTheme.sky.switchToTheme()
		case .sakura:
			KTheme.sakura.switchToTheme()
		case .other(let theme):
			if KThemeStyle.themeExist(for: theme) && !User.isPro {
				KTheme.other(theme).switchToTheme()
			} else {
				Task {
					await WorkflowController.shared.isPro {
						if KThemeStyle.themeExist(for: theme) && !KThemeStyle.isUpToDate(theme.id, version: theme.attributes.version) {
							self.handleRedownloadTheme(cell)
						} else {
							self.shouldDownloadTheme(cell)
						}
					}
				}
			}
		}
	}

	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressMoreButton button: UIButton) {
		switch cell.kTheme {
		case .other(let theme):
			let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { actionSheetAlertController in
				if User.isPro {
					// Add redownload action
					let redownloadAction = UIAlertAction(title: "Redownload Theme", style: .default) { _ in
						self.handleRedownloadTheme(cell)
					}
					redownloadAction.setValue(UIImage(systemName: "arrow.uturn.down"), forKey: "image")
					redownloadAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
					actionSheetAlertController.addAction(redownloadAction)
				}

				// Add remove action
				let removeAction = UIAlertAction(title: "Remove Theme", style: .destructive) { _ in
					self.handleRemoveTheme(cell)
					if UserSettings.currentTheme.int == theme.id {
						KThemeStyle.switchTo(style: .default)
					}
				}
				removeAction.setValue(UIImage(systemName: "minus.circle"), forKey: "image")
				removeAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
				actionSheetAlertController.addAction(removeAction)
			}

			// Present the controller
			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = button
				popoverController.sourceRect = button.bounds
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(actionSheetAlertController, animated: true, completion: nil)
			}
		default: break
		}
	}

	/// Checks whether the selected theme should be downloaded or else applied.
	fileprivate func shouldDownloadTheme(_ cell: ThemesCollectionViewCell) {
		switch cell.kTheme {
		case .other(let theme):
			guard KThemeStyle.themeExist(for: theme) else {
				let alertController = self.presentAlertController(title: "Not Downloaded", message: "Download the theme right now?", defaultActionButtonTitle: "Cancel")
				alertController.addAction(UIAlertAction(title: "Download", style: .default) { [weak self] _ in
					self?.handleDownloadTheme(cell)
				})
				return
			}

			KThemeStyle.switchTo(theme: theme)
		default: break
		}
	}

	/// Handle the download process for the selected theme.
	fileprivate func handleDownloadTheme(_ cell: ThemesCollectionViewCell) {
		switch cell.kTheme {
		case .other(let theme):
			let themeName = theme.attributes.name
			let alertController = self.presentActivityAlertController(title: "Downloading \(themeName)...", message: nil)

			KThemeStyle.downloadThemeTask(for: theme) { isSuccess in
				alertController.title = isSuccess ? "Finished downloading!" : "Download failed :("
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					alertController.dismiss(animated: true, completion: nil)
				}

				if isSuccess {
					KThemeStyle.switchTo(theme: theme)
					cell.shouldHideMoreButton()
				}
			}
		default: break
		}
	}

	/// Handle the removing process for a downloaded theme.
	fileprivate func handleRemoveTheme(_ cell: ThemesCollectionViewCell, timeout: Double = 0.5, withSuccess successHandler: ((_ isSuccess: Bool) -> Void)? = nil) {
		switch cell.kTheme {
		case .other(let theme):
			let themeName = theme.attributes.name
			let alertController = self.presentActivityAlertController(title: "Removing \(themeName)...", message: nil)

			KThemeStyle.removeThemeTask(for: theme) { isSuccess in
				alertController.title = isSuccess ? "Finished removing!" : "Removing failed :("
				DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
					alertController.dismiss(animated: true, completion: nil)
				}

				if isSuccess {
					cell.shouldHideMoreButton()
				}

				successHandler?(isSuccess)
			}
		default: break
		}
	}

	/// Handle the redownload process for a downloaded theme.
	fileprivate func handleRedownloadTheme(_ cell: ThemesCollectionViewCell) {
		handleRemoveTheme(cell, timeout: 0) { success in
			if success {
				self.handleDownloadTheme(cell)
			}
		}
	}
}

// MARK: - SectionLayoutKind
extension ManageThemesCollectionViewController {
	/**
		List of theme section layout kind.

		```
		case def = 0
		case main = 1
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case def = 0
		case main = 1
	}
}
