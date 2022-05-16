//
//  CastCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class CastCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showIdentity: ShowIdentity? = nil
	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = [] {
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
	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, CastIdentity>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, CastIdentity>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The next page url of the pagination.
	var nextPageURL: String?

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

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the cast.")
		#endif

		self.configureDataSource()

		// Fetch cast
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchCast()
		}
    }

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

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
		guard let showIdentity = self.showIdentity else {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.endRefreshing()
				#endif
			}
			return
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing cast...")
			#endif
		}

		KService.getCast(forShow: showIdentity, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let castIdentityResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.castIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = castIdentityResponse.next
				self.castIdentities.append(contentsOf: castIdentityResponse.data)

				DispatchQueue.main.async {
					// Reset refresh controller title
					#if !targetEnvironment(macCatalyst)
					self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the cast.")
					#endif
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.castCollectionViewController.characterDetailsSegue.identifier:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case R.segue.castCollectionViewController.personDetailsSegue.identifier:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		default: break
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension CastCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard self.cast[indexPath] != nil else { return }

		let person = self.cast[indexPath]?.relationships.people.data.first
		self.performSegue(withIdentifier: R.segue.castCollectionViewController.personDetailsSegue.identifier, sender: person)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard self.cast[indexPath] != nil else { return }

		let character = self.cast[indexPath]?.relationships.characters.data.first
		self.performSegue(withIdentifier: R.segue.castCollectionViewController.characterDetailsSegue.identifier, sender: character)
	}
}

// MARK: - SectionLayoutKind
extension CastCollectionViewController {
	/// List of cast section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
