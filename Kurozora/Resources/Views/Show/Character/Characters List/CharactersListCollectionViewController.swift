//
//  CharactersListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class CharactersListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var personIdentity: PersonIdentity? = nil
	var characters: [IndexPath: Character] = [:]
	var characterIdentities: [CharacterIdentity] = []
	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, CharacterIdentity>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, CharacterIdentity>! = nil
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
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the characters.")
		#endif

		self.configureDataSource()

		if !self.characterIdentities.isEmpty {
			self.endFetch()
		} else if self.personIdentity != nil {
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchCharacters()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.personIdentity != nil {
			self.nextPageURL = nil
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchCharacters()
			}
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No Characters", detail: "Can't get characters list. Please reload the page or restart the app and check your WiFi connection.")

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

	func endFetch() {
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
		#endif
	}

	func fetchCharacters() {
		guard let personIdentity = self.personIdentity else {
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
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing characters...")
			#endif
		}

		KService.getCharacters(forPerson: personIdentity, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let characterIdentityResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.characterIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = characterIdentityResponse.next
				self.characterIdentities.append(contentsOf: characterIdentityResponse.data)

				DispatchQueue.main.async {
					self.endFetch()

					// Reset refresh controller title
					#if !targetEnvironment(macCatalyst)
					self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the characters.")
					#endif
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.charactersListCollectionViewController.characterDetailsSegue.identifier:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		default: break
		}
	}
}

// MARK: - SectionLayoutKind
extension CharactersListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
