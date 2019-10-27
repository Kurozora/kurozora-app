//
//  ManageThemesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import SCLAlertView
import SwiftTheme

class ManageThemesCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	var themes: [ThemesElement]? {
		didSet {
			self.collectionView.reloadData()
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Fetch themes
		fetchThemes()

		// Setup empty collection view
		collectionView.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No Themes", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get themes list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_themes"))
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	// MARK: - Functions
	/// Fetches themes from the server.
	func fetchThemes() {
		KService.shared.getThemes( withSuccess: { (themes) in
			self.themes = themes
		})
	}
}

// MARK: - UICollectionViewDataSource
extension ManageThemesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let themesCount = themes?.count else { return 0 }
		return themesCount + 3
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let themesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemesCollectionViewCell", for: indexPath) as! ThemesCollectionViewCell
		return themesCollectionViewCell
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let themesCollectionViewCell = cell as? ThemesCollectionViewCell {
			themesCollectionViewCell.indexPathItem = indexPath.item
			if indexPath.row > 3 {
				themesCollectionViewCell.themesElement = themes?[indexPath.item - 3]
			} else {
				themesCollectionViewCell.themesElement = themes?.first
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension ManageThemesCollectionViewController {
}
