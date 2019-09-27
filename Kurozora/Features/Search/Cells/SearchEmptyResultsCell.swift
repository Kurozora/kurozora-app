//
//  SearchEmptyResultsCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SearchEmptyResultsCell: SearchBaseResultsCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!

	// MARK: - Properties
	var suggestionElement: [ShowDetailsElement]? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.reloadData()
	}
}

// MARK: - UICollectionViewDataSource
extension SearchEmptyResultsCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let suggestionCount = suggestionElement?.count else { return 0 }
		return suggestionCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let suggestionResultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionResultCell", for: indexPath) as! SuggestionResultCell
		suggestionResultCell.showDetailsElement = suggestionElement?[indexPath.item]
		return suggestionResultCell
	}
}

// MARK: - UICollectionViewDelegate
extension SearchEmptyResultsCell: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchEmptyResultsCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 88, height: 124)
	}
}
