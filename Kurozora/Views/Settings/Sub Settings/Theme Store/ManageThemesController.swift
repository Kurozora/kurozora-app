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
	var themes: [[Theme]] = [[], []] {
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

	// Default theme
	var defaultThemes = ThemeResponse(from:
	"""
	{
		"data": [
			{
			  "id": 1,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Default",
				"backgroundColor": "#353A50",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 2,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Day",
				"backgroundColor": "#E6E5E5",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 3,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Night",
				"backgroundColor": "#333333",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 4,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Grass",
				"backgroundColor": "#E5EFAC",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 5,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Sky",
				"backgroundColor": "#E5EFAC",
				"screenshot": "",
				"downloadLink": ""
			  }
			},
			{
			  "id": 6,
			  "type": "themes",
			  "href": "",
			  "attributes": {
				"name": "Sakura",
				"backgroundColor": "#E5EFAC",
				"screenshot": "",
				"downloadLink": ""
			  }
			}
		]
	}
	""".data(using: .utf8)!)

	// MARK: - Initializers
	required init?(coder: NSCoder) {
		super.init(coder: coder)

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Fetch themes
		DispatchQueue.global(qos: .background).async {
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

		// Setup default themes
		if let defaultThemes = self.defaultThemes?.data {
			self.themes[0].append(contentsOf: defaultThemes)
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
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
					self?.themes[1].append(contentsOf: themes)
				}
			case .failure: break
			}
		}
	}
}

extension ManageThemesCollectionViewController: ThemesCollectionViewCellDelegate {
	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressGetButton button: UIButton) {
		let indexPath = self.collectionView.indexPath(for: cell)
		switch indexPath {
		case [0, 0]:
			KThemeStyle.switchTo(.default)
		case [0, 1]:
			KThemeStyle.switchTo(.day)
		case [0, 2]:
			KThemeStyle.switchTo(.night)
		case [0, 3]:
			KThemeStyle.switchTo(.grass)
		case [0, 4]:
			KThemeStyle.switchTo(.sky)
		case [0, 5]:
			KThemeStyle.switchTo(.sakura)
		default:
			cell.shouldDownloadTheme()
		}
	}

	func themesCollectionViewCell(_ cell: ThemesCollectionViewCell, didPressMoreButton button: UIButton) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { actionSheetAlertController in
			let redownloadAction = UIAlertAction(title: "Redownload Theme", style: .default, handler: { (_) in
				cell.handleRedownloadTheme()
			})
			let removeAction = UIAlertAction(title: "Remove Theme", style: .destructive, handler: { (_) in
				cell.handleRemoveTheme()
				if UserSettings.currentTheme.int == cell.theme.id {
					KThemeStyle.switchTo(.default)
				}
			})

			// Add image
			redownloadAction.setValue(UIImage(systemName: "arrow.uturn.down"), forKey: "image")
			removeAction.setValue(UIImage(systemName: "minus.circle"), forKey: "image")

			// Left align title
			redownloadAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			removeAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

			// Add actions
			actionSheetAlertController.addAction(redownloadAction)
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
