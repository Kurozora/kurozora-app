//
//  ManageThemesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift
import SCLAlertView
import SwiftTheme

class ManageThemesCollectionViewController: UICollectionViewController, EmptyDataSetSource, EmptyDataSetDelegate {
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		Service.shared.getThemes( withSuccess: { (themes) in
			self.themes = themes
		})

		#if DEBUG
		numberOfItemsTextField.placeholder = "# items for: width, height"
		numberOfItemsTextField.text = "\(numberOfItems.forWidth), \(numberOfItems.forHeight)"
		numberOfItemsTextField.textAlignment = .center
		numberOfItemsTextField.addTarget(self, action: #selector(updateLayout(_:)), for: .editingDidEnd)
		navigationItem.title = nil
		navigationItem.titleView = numberOfItemsTextField
		#endif

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
		let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
		let sclAlertView = SCLAlertView(appearance: appearance).showWait("Downloading \(themeName)...")

		KThemeStyle.downloadThemeTask(for: theme) { isSuccess in
			sclAlertView.setTitle(isSuccess ? "Finished downloading!" : "Download failed :(")

			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				sclAlertView.close()
			}

			if isSuccess {
				KThemeStyle.switchTo(theme: themeID)
			}
		}
	}
}

// MARK: - UIAlertViewDelegate
extension ManageThemesCollectionViewController: UIAlertViewDelegate {
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
extension ManageThemesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let themesCount = themes?.count else { return 0 }
		return themesCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let themeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCell", for: indexPath) as! ThemeCell //TestThemeCell

		themeCell.row = indexPath.row
		themeCell.themesElement = themes?[indexPath.row]

		return themeCell
	}
}

// MARK: - UICollectionViewDelegate
extension ManageThemesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		tapDownload(for: themes?[indexPath.row])
	}
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
