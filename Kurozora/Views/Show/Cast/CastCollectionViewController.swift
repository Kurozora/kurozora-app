//
//  CastCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CastCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showID: Int = 0
	var cast: [Cast] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var nextPageURL: String?
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Cast>! = nil

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

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
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch cast
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchCast()
		}
    }

	// MARK: - Functions
	override func handleRefreshControl() {
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchCast()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No Cast", detail: "This show doesn't have casts yet. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetch cast for the current show.
	func fetchCast() {
		KService.getCast(forShowID: self.showID, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let castResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.cast = []
				}

				// Append new data and save next page url
				self.cast.append(contentsOf: castResponse.data)
				self.nextPageURL = castResponse.next
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.castCollectionViewController.characterDetailsSegue.identifier {
			if let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController {
				if let castCollectionViewCell = sender as? CastCollectionViewCell, let character = castCollectionViewCell.cast.relationships.characters.data.first {
					characterDetailsCollectionViewController.characterID = character.id
				}
			}
		} else if segue.identifier == R.segue.castCollectionViewController.personDetailsSegue.identifier {
			if let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController {
				if let castCollectionViewCell = sender as? CastCollectionViewCell, let person = castCollectionViewCell.cast.relationships.people.data.first {
					personDetailsCollectionViewController.personID = person.id
				}
			}
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension CastCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.castCollectionViewController.personDetailsSegue.identifier, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.castCollectionViewController.characterDetailsSegue.identifier, sender: cell)
	}
}

// MARK: - SectionLayoutKind
extension CastCollectionViewController {
	/**
		List of cast section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
