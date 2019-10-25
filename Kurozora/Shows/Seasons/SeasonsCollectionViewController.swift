//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class SeasonsCollectionViewController: UICollectionViewController {
	// MARK: - Properties
	var showID: Int?
	var seasons: [SeasonsElement]? {
		didSet {
			self.collectionView?.reloadData()
		}
	}
	var gap: CGFloat = UIDevice.isPad ? 40 : 20
	var numberOfItems: (forWidth: CGFloat, forHeight: CGFloat) {
		get {
			if UIDevice.isLandscape {
				switch UIDevice.type {
				case .iPhone5SSE:								return (1, 1.8)
				case .iPhone66S78, .iPhoneXXs:					return (2, 2.2)
				case .iPhone66S78PLUS, .iPhoneXr, .iPhoneXsMax:	return (2, 2.4)
				case .iPad:										return (3, 4.2)
				case .iPadAir3, .iPadPro11:						return (3, 4.6)
				case .iPadPro12:								return (3, 5.8)
				}
			}

			switch UIDevice.type {
			case .iPhone5SSE:									return (1, 3.2)
			case .iPhone66S78:									return (1, 3.8)
			case .iPhone66S78PLUS:								return (1, 4.2)
			case .iPhoneXr, .iPhoneXsMax:						return (1, 5.2)
			case .iPhoneXXs:									return (1, 4.6)
			case .iPad:											return (2, 5.6)
			case .iPadAir3:										return (2, 6.2)
			case .iPadPro11:									return (2, 6.8)
			case .iPadPro12:									return (2, 7.8)
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
		NotificationCenter.default.addObserver(self, selector: #selector(reloadEmptyDataView), name: .ThemeUpdateNotification, object: nil)

		// Fetch seasons
		if seasons == nil {
			fetchSeasons()
		}

		// Setup empty data view
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
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "details", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "SeasonsCollectionViewController")
	}

	/// Sets up the empty data view.
	func setupEmptyDataView() {
		collectionView?.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No Seasons", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "This show doesn't have seasons yet. Please check back again later.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_seasons"))
				.imageTintColor(KThemePicker.textColor.colorValue)
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

	/// Fetch seasons for the current show.
    fileprivate func fetchSeasons() {
        KService.shared.getSeasonsFor(showID, withSuccess: { (seasons) in
			DispatchQueue.main.async {
				self.seasons = seasons
			}
        })
    }

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodesSegue", let cell = sender as? SeasonsCollectionViewCell {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController, let indexPath = collectionView.indexPath(for: cell) {
				episodesCollectionViewController.seasonID = seasons?[indexPath.item].id
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension SeasonsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let seasonsCount = seasons?.count else { return 0 }
		return seasonsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let seasonsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeasonsCollectionViewCell", for: indexPath) as! SeasonsCollectionViewCell

		seasonsCollectionViewCell.seasonsElement = seasons?[indexPath.row]

		return seasonsCollectionViewCell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SeasonsCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		#if DEBUG
		return CGSize(width: (collectionView.bounds.width - gap) / _numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / _numberOfItems.forHeight)
		#else
		return CGSize(width: (collectionView.bounds.width - gap) / numberOfItems.forWidth, height: (collectionView.bounds.height - gap) / numberOfItems.forHeight)
		#endif
	}
}
