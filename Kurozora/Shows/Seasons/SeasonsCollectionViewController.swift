//
//  SeasonsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift

class SeasonsCollectionViewController: UICollectionViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	var showID: Int?
	var heroID: String?
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
				case .iPhone_5_5S_5C_SE:	return (1, 1.7)
				case .iPhone_6_6S_7_8:		return (2, 2)
				case .iPhone_6_6S_7_8_PLUS:	return (2, 2.3)
				case .iPhone_Xr:			return (2, 2.3)
				case .iPhone_X_Xs:			return (2, 2)
				case .iPhone_Xs_Max:		return (2, 2.3)

				case .iPad:					return (2, 4.4)
				case .iPadAir3:				return (3, 5)
				case .iPadPro11:			return (3, 5)
				case .iPadPro12:			return (3, 6.2)
				}
			}

			switch UIDevice.type {
			case .iPhone_5_5S_5C_SE:	return (1, 3.4)
			case .iPhone_6_6S_7_8:		return (1, 4)
			case .iPhone_6_6S_7_8_PLUS:	return (1, 4.5)
			case .iPhone_Xr:			return (1, 5.6)
			case .iPhone_X_Xs:			return (1, 5)
			case .iPhone_Xs_Max:		return (1, 5.5)

			case .iPad:					return (2, 6.2)
			case .iPadAir3:				return (2, 6.8)
			case .iPadPro11:			return (2, 7.4)
			case .iPadPro12:			return (2, 8.4)
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
		let width = Double(stringArray[0])
		let height = Double(stringArray[1])
		return (width?.cgFloat ?? numberOfItems.forWidth, height?.cgFloat ?? numberOfItems.forHeight)
	}
	#endif

	override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        collectionView?.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No seasons found!"))
                .image(UIImage(named: ""))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(false)
        }

		showID = KCommonKit.shared.showID
        fetchSeasons()

		#if DEBUG
		numberOfItemsTextField.placeholder = "# items for: width, height"
		numberOfItemsTextField.textAlignment = .center
		numberOfItemsTextField.addTarget(self, action: #selector(updateLayout(_:)), for: .editingDidEnd)
		navigationItem.title = nil
		navigationItem.titleView = numberOfItemsTextField
		numberOfItemsTextField.becomeFirstResponder()
		#endif
    }

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
			return
		}
		flowLayout.invalidateLayout()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodesSegue", let cell = sender as? SeasonsCollectionViewCell {
			if let episodesCollectionViewController = segue.destination as? EpisodesCollectionViewController, let indexPath = collectionView.indexPath(for: cell) {
				episodesCollectionViewController.seasonID = seasons?[indexPath.item].id
			}
		}
	}

	// MARK: - Functions
    fileprivate func fetchSeasons() {
        Service.shared.getSeasonsFor(showID, withSuccess: { (seasons) in
			DispatchQueue.main.async {
				self.seasons = seasons
			}
        })
    }

    // MARK: - IBActions
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		view.hero.id = heroID
		dismiss(animated: true, completion: nil)
    }

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		collectionView.collectionViewLayout.invalidateLayout()
	}
}

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension SeasonsCollectionViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		#if DEBUG
		return CGSize(width: (collectionView.width - gap) / _numberOfItems.forWidth, height: (collectionView.height - gap) / _numberOfItems.forHeight)
		#else
		return CGSize(width: (collectionView.width - gap) / numberOfItems.forWidth, height: (collectionView.height - gap) / numberOfItems.forHeight)
		#endif
	}
}
