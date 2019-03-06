//
//  ManageThemesController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift

class ManageThemesController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    @IBOutlet var collectionView: UICollectionView!
    
    var themes: [ThemesElement]?
    
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"

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

	// MARK: - IBActions
	@objc func tapDefault(_ sender: AnyObject) {
		KurozoraThemes.switchTo(.default)
	}

	@objc func tapDay(_ sender: AnyObject) {
		KurozoraThemes.switchTo(.day)
	}

	@objc func tapNight(_ sender: AnyObject) {
		KurozoraThemes.switchTo(.night)
	}

	// MARK: - Functions
	fileprivate func downloadStart(for theme: ThemesElement?) {
		guard let themeName = theme?.name else { return }
		guard let themeID = theme?.id else { return }
		let HUD = navigationController!.showHUD("Downloading \(themeName)...")

		KurozoraThemes.downloadThemeTask(for: theme) { isSuccess in
			HUD.label.text = isSuccess ? "Done!" : "Download failed :("
			HUD.mode = .text
			HUD.hide(animated: true, afterDelay: 1)

			if isSuccess {
				KurozoraThemes.switchTo(theme: themeID)
			}
		}
	}
}

// MARK: - UIAlertViewDelegate
extension ManageThemesController: UIAlertViewDelegate {
	fileprivate func tapDownload(for theme: ThemesElement?) {
		guard let themeID = theme?.id else { return }
		guard KurozoraThemes.themeExist(for: themeID) else {
			let title   = "Not Downloaded"
			let message = "Download the theme right now?"

			if #available(iOS 8.0, *) {
				let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
				alert.addAction(UIAlertAction(title: "Sure", style: .default, handler: { [unowned self] _ in
					self.downloadStart(for: theme)
				})
				)

				present(alert, animated: true, completion: nil)
			} else {
				UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Sure").show()
			}
			return
		}

		KurozoraThemes.switchTo(theme: themeID)
	}
}

// MARK: - UICollectionViewDataSource
extension ManageThemesController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let themesCount = themes?.count else { return 0 }

		return themesCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let themeCell : TestThemeCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCell", for: indexPath) as! TestThemeCell

		if let themeName = themes?[indexPath.row].name {
			themeCell.button.setTitle(themeName, for: .normal)
		}

		if indexPath.row == 0 {
			themeCell.button.backgroundColor = #colorLiteral(red: 0.2174186409, green: 0.2404800057, blue: 0.332449615, alpha: 1)
			themeCell.button.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1),for: .normal)
			themeCell.button.addTarget(self, action: #selector(tapDefault(_:)), for: .touchUpInside)
		} else if indexPath.row == 1 {
			themeCell.button.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
			themeCell.button.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1),for: .normal)
			themeCell.button.addTarget(self, action: #selector(tapDay(_:)), for: .touchUpInside)
		} else if indexPath.row == 2 {
			themeCell.button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
			themeCell.button.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1),for: .normal)
			themeCell.button.addTarget(self, action: #selector(tapNight(_:)), for: .touchUpInside)
		}

		return themeCell
	}
}

// MARK: - UICollectionViewDelegate
extension ManageThemesController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		tapDownload(for: themes?[indexPath.row])
	}
}
