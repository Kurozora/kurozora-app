//
//  StudiosCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudiosCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var studioID: Int = 0
	var studioElement: StudioElement? = nil {
		didSet {
			_prefersActivityIndicatorHidden = true
			collectionView.reloadData()
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<StudioSection, Int>! = nil

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
		KService.getDetails(forStudioID: 1) { result in
			switch result {
			case .success(let studioElement):
				DispatchQueue.main.async {
					self.studioElement = studioElement
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	}
}

// MARK: - UICollectionViewDataSource
extension StudiosCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return StudioSection.allCases.count + 1
	}
}

// MARK: - KCollectionViewDataSource
extension StudiosCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [SynopsisCollectionViewCell.self]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderReusableView.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<StudioSection, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
			let studioSection = StudioSection(rawValue: indexPath.section) ?? .main
			let reuseIdentifier = studioSection.identifierString(for: indexPath.item)
			let studioCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

			switch studioSection {
			case .main:
				(studioCollectionViewCell as? StudioHeaderCollectionViewCell)?.studioElement = self.studioElement
			case .about:
				(studioCollectionViewCell as? SynopsisCollectionViewCell)?.synopsisText = self.studioElement?.about
			case .information:
				(studioCollectionViewCell as? InformationButtonCollectionViewCell)?.studioInformationSection = StudioInformationSection(rawValue: indexPath.item)
				(studioCollectionViewCell as? InformationButtonCollectionViewCell)?.studioElement = self.studioElement
			}

			return studioCollectionViewCell
		}
		dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
			let studioSection = StudioSection(rawValue: indexPath.section) ?? .main
			let titleHeaderReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderReusableView.self, for: indexPath)
			titleHeaderReusableView.title = studioSection.stringValue
			titleHeaderReusableView.indexPath = indexPath
			return titleHeaderReusableView
		}

		var snapshot = NSDiffableDataSourceSnapshot<StudioSection, Int>()
		StudioSection.allCases.forEach {
			snapshot.appendSections([$0])
			let itemOffset = $0.rawValue * $0.rowCount
			let itemUpperbound = itemOffset + $0.rowCount
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
	}
}
