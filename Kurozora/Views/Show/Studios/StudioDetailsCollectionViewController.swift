//
//  StudioDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var studioID: Int = 0
	var studio: Studio! {
		didSet {
			_prefersActivityIndicatorHidden = true
		}
	}
	var shows: [Show] = []
	var dataSource: UICollectionViewDiffableDataSource<StudioDetailsSection, Int>! = nil

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		DispatchQueue.global(qos: .background).async {
			self.fetchStudios()
		}
	}

	// MARK: - Functions
	func fetchStudios() {
		KService.getDetails(forStudioID: studioID, including: ["shows"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let studios):
				self.studio = studios.first
				self.shows = studios.first?.relationships?.shows?.data ?? []
				self.configureDataSource()
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.studioDetailsCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let show = (sender as? BaseLockupCollectionViewCell)?.show {
					showDetailCollectionViewController.showID = show.id
				}
			}
		} else if segue.identifier == R.segue.studioDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.studioID = self.studio.id
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension StudioDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
		}
	}
}

// MARK: - KCollectionViewDataSource
extension StudioDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			TextViewCollectionViewCell.self,
			InformationCollectionViewCell.self,
			InformationButtonCollectionViewCell.self,
			SmallLockupCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<StudioDetailsSection, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			let studioDetailsSection = StudioDetailsSection(rawValue: indexPath.section) ?? .main
			let reuseIdentifier = studioDetailsSection.identifierString(for: indexPath.item)
			let studioCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

			switch studioDetailsSection {
			case .main:
				(studioCollectionViewCell as? StudioHeaderCollectionViewCell)?.studio = self.studio
			case .about:
				let textViewCollectionViewCell = studioCollectionViewCell as? TextViewCollectionViewCell
				textViewCollectionViewCell?.textViewCollectionViewCellType = .about
				textViewCollectionViewCell?.textViewContent = self.studio.attributes.about
			case .information:
				if let informationCollectionViewCell = studioCollectionViewCell as? InformationCollectionViewCell {
					informationCollectionViewCell.studioDetailsInformationSection = StudioDetailsInformationSection(rawValue: indexPath.item) ?? .founded
					informationCollectionViewCell.studio = self.studio
				} else if let informationButtonCollectionViewCell = studioCollectionViewCell as? InformationButtonCollectionViewCell {
					informationButtonCollectionViewCell.studioDetailsInformationSection = StudioDetailsInformationSection(rawValue: indexPath.item) ?? .website
					informationButtonCollectionViewCell.studio = self.studio
				}
			case .shows:
				(studioCollectionViewCell as? SmallLockupCollectionViewCell)?.show = self.shows[indexPath.item]
			}

			return studioCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let studioDetailsSection = StudioDetailsSection(rawValue: indexPath.section) ?? .main
			let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
			titleHeaderCollectionReusableView.segueID = studioDetailsSection.segueIdentifier
			titleHeaderCollectionReusableView.indexPath = indexPath
			titleHeaderCollectionReusableView.title = studioDetailsSection.stringValue
			return titleHeaderCollectionReusableView
		}

		var snapshot = NSDiffableDataSourceSnapshot<StudioDetailsSection, Int>()
		StudioDetailsSection.allCases.forEach {
			snapshot.appendSections([$0])
			let rowCount = $0 == .shows ? self.shows.count : $0.rowCount
			let itemOffset = $0.rawValue * rowCount
			let itemUpperbound = itemOffset + rowCount
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
	}
}
