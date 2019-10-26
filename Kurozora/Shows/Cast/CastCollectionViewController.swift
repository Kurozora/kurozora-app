//
//  CastCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class CastCollectionViewController: UICollectionViewController {
    var actors: [ActorsElement]?
	var gap: CGFloat = UIDevice.isPad ? 40 : 20
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			if UIDevice.isLandscape {
				switch UIDevice.type {
				case .iPhone5SSE:								return (1, 1.7)
				case .iPhone66S78, .iPhoneXXs:					return (2, 2)
				case .iPhone66S78PLUS, .iPhoneXr, .iPhoneXsMax:	return (2, 2.3)
				case .iPad:										return (2, 4.4)
				case .iPadAir3, .iPadPro11:						return (3, 5)
				case .iPadPro12:								return (3, 6.2)
				}
			}

			switch UIDevice.type {
			case .iPhone5SSE:									return (1, 3.4)
			case .iPhone66S78:									return (1, 4)
			case .iPhone66S78PLUS:								return (1, 4.5)
			case .iPhoneXr:										return (1, 5.6)
			case .iPhoneXXs:									return (1, 5)
			case .iPhoneXsMax:									return (1, 5.5)
			case .iPad:											return (2, 6.2)
			case .iPadAir3:										return (2, 6.8)
			case .iPadPro11:									return (2, 7.4)
			case .iPadPro12:									return (2, 8.4)
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

    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		// Setup empty collection view
		setupEmptyDataView()

		#if DEBUG
		numberOfItemsTextField.placeholder = "# items for: width, height"
		numberOfItemsTextField.text = "\(numberOfItems.forWidth), \(numberOfItems.forHeight)"
		numberOfItemsTextField.textAlignment = .center
		numberOfItemsTextField.addTarget(self, action: #selector(updateLayout(_:)), for: .editingDidEnd)
		navigationItem.title = nil
		navigationItem.titleView = numberOfItemsTextField
		#endif
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
	}

	// MARK: - Functions
	/// Sets up the empty data view.
	func setupEmptyDataView() {
		collectionView.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No Actors", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get actors list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_actor"))
				.verticalOffset(-50)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	/// Reload the empty data view.
	@objc func reloadEmptyDataView() {
		setupEmptyDataView()
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension CastCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let actorsCount = actors?.count else { return 0 }
		return actorsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let castCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCastCollectionCell", for: indexPath) as! ShowCastCollectionCell
		castCell.actorElement = actors?[indexPath.row]
		castCell.delegate = self
		return castCell
	}
}

// MARK: - UICollectionViewDelegate
extension CastCollectionViewController {
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CastCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		#if DEBUG
		return CGSize(width: (collectionView.bounds.width - gap) / _numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / _numberOfItems.forHeight)
		#else
		return CGSize(width: (collectionView.bounds.width - gap) / numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / numberOfItems.forHeight)
		#endif
	}
}

// MARK: - ShowCastCellDelegate
extension CastCollectionViewController: ShowCastCellDelegate {
	func presentPhoto(withString string: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(string: string, from: imageView)
	}

	func presentPhoto(withImage image: UIImage, from imageView: UIImageView) {
		presentPhotoViewControllerWith(image: image, from: imageView)
	}

	func presentPhoto(withUrl url: String, from imageView: UIImageView) {
		presentPhotoViewControllerWith(url: url, from: imageView)
	}
}
