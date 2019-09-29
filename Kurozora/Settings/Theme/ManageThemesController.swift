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
	var gap: CGFloat = UIDevice.isPad ? 40 : 20
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			if UIDevice.isLandscape {
				switch UIDevice.type {
				case .iPhone5SSE, .iPhone66S78, .iPhone66S78PLUS, .iPhoneXr, .iPhoneXsMax:		return (2.22, 0.8)
				case .iPhoneXXs:																return (3.22, 0.8)
				case .iPad, .iPadAir3, .iPadPro11, .iPadPro12:									return (2.00, 2.2)
				}
			}

			switch UIDevice.type {
			case .iPhone5SSE:																	return (2.08, 1.6)
			case .iPhone66S78:																	return (2.08, 1.8)
			case .iPhone66S78PLUS:																return (2.08, 2.0)
			case .iPhoneXr, .iPhoneXXs, .iPhoneXsMax:											return (2.08, 2.2)
			case .iPad, .iPadAir3, .iPadPro11, .iPadPro12:										return (2.00, 2.2)
			}
		}
	}

	#if DEBUG
	var newNumberOfItems: (forWidth: CGFloat, forHeight: CGFloat)?
	var _numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			guard let newNumberOfItems = newNumberOfItems else { return numberOfItems }
			return newNumberOfItems
		}
	}

	var numberOfItemsTextField: UITextField = UITextField(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 20)))

	@objc func updateLayout(_ textField: UITextField) {
		guard let textFieldText = numberOfItemsTextField.text, !textFieldText.isEmpty else { return }
		newNumberOfItems = getNumbers(textFieldText)
		collectionView.reloadData()
	}

	func getNumbers(_ text: String) -> (forWidth: CGFloat, forHeight: CGFloat) {
		let stringArray = text.withoutSpacesAndNewLines.components(separatedBy: ",")
		let width = (stringArray.count > 1) ? Double(stringArray[0])?.cgFloat : numberOfItems.forWidth
		let height = (stringArray.count > 1) ? Double(stringArray[1])?.cgFloat : numberOfItems.forHeight
		return (width ?? numberOfItems.forWidth, height ?? numberOfItems.forHeight)
	}
	#endif

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

		#if DEBUG
		numberOfItemsTextField.placeholder = "# items for: width, height"
		numberOfItemsTextField.text = "\(numberOfItems.forWidth), \(numberOfItems.forHeight)"
		numberOfItemsTextField.textAlignment = .center
		numberOfItemsTextField.addTarget(self, action: #selector(updateLayout(_:)), for: .editingDidEnd)
		navigationItem.title = nil
		navigationItem.titleView = numberOfItemsTextField
		#endif
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
		let themeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemesCollectionViewCell", for: indexPath) as! ThemesCollectionViewCell

		themeCell.indexPathItem = indexPath.item
		if indexPath.row > 3 {
			themeCell.themesElement = themes?[indexPath.item - 3]
		} else {
			themeCell.themesElement = themes?.first
		}

		return themeCell
	}
}

// MARK: - UICollectionViewDelegate
extension ManageThemesCollectionViewController {
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ManageThemesCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		#if DEBUG
		return CGSize(width: (collectionView.bounds.width - gap) / _numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / _numberOfItems.forHeight)
		#else
		return CGSize(width: (collectionView.bounds.width - gap) / numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / numberOfItems.forHeight)
		#endif
	}
}
