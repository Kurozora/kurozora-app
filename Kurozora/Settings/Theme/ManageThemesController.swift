//
//  ManageThemesController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import SwiftTheme

class ManageThemesController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    @IBOutlet var collectionView: UICollectionView!
    
    var themes: [ThemesElement]?
    
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		Service.shared.getThemes( withSuccess: { (themes) in
			self.themes = themes

			DispatchQueue.main.async() {
				self.collectionView.reloadData()
			}
		})

		collectionView.delegate = self
		collectionView.dataSource = self

		// Setup empty collection view
		collectionView.emptyDataSetSource = self
		collectionView.emptyDataSetDelegate = self
		collectionView.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No themes found!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
		}
    }

	// MARK: - Functions
	fileprivate func downloadStart(for theme: ThemesElement?) {
		guard let themeName = theme?.name else { return }
		guard let themeID = theme?.id else { return }
		let sclAlertView = SCLAlertView().showWait("Downloading \(themeName)...")

		KThemeStyle.downloadThemeTask(for: theme) { isSuccess in
			sclAlertView.setTitle(isSuccess ? "Finished downloading!" : "Download failed :(")

			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				sclAlertView.close()
			}

			if isSuccess {
				KThemeStyle.switchTo(theme: themeID)
			}
		}
	}
}

// MARK: - UIAlertViewDelegate
extension ManageThemesController: UIAlertViewDelegate {
	fileprivate func tapDownload(for theme: ThemesElement?) {
		guard let themeID = theme?.id else { return }
		guard KThemeStyle.themeExist(for: themeID) else {
			let alert = SCLAlertView()
			alert.addButton("Sure") {
				self.downloadStart(for: theme)
			}
			alert.showInfo("Not Downloaded", subTitle: "Download the theme right now?", closeButtonTitle: "Cancel")
			return
		}

		KThemeStyle.switchTo(theme: themeID)
	}
}

// MARK: - UICollectionViewDataSource
extension ManageThemesController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let themesCount = themes?.count else { return 0 }

		return themesCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let themeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCell", for: indexPath) as! TestThemeCell

		themeCell.row = indexPath.row
		themeCell.themeElement = themes?[indexPath.row]

		return themeCell
	}
}

// MARK: - UICollectionViewDelegate
extension ManageThemesController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		tapDownload(for: themes?[indexPath.row])
	}
}
