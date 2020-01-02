//
//  FavoriteShowsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class FavoriteShowsCollectionViewController: UICollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel! {
		didSet {
			primaryLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var secondaryLabel: UILabel! {
		didSet {
			secondaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	// MARK: - Properties
	var shows: [[ShowDetailsElement]]? {
		didSet {
			self.collectionView.reloadData()
		}
	}

	// MARK: - Views
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		fetchUserLibrary()
	}

	// MARK: - Functions
	func fetchUserLibrary() {
		self.secondaryLabel.text = "\(69) TV · \(31) Movie · \(5) OVA/ONA/Specials"
	}
}

// MARK: - UICollectionViewDataSource
extension FavoriteShowsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Library.Section.all.count
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let showsCount = shows?[section].count else { return 0 }
		return showsCount
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
		return cell
	}
}

// MARK: - UICollectionViewDelegate
extension FavoriteShowsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let sectionHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderReusableView", for: indexPath) as? SectionHeaderReusableView else { fatalError("Cannot dequeueReusableCell withIdentifier SectionHeaderReusableView") }
		return sectionHeaderReusableView
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		if let sectionHeaderReusableView = view as? SectionHeaderReusableView {
			sectionHeaderReusableView.title = Library.Section.all[indexPath.section].stringValue
		}
	}
}
