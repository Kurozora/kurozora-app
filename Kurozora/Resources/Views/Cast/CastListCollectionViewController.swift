//
//  CastListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum CastKind: String {
	case show
	case literature
	case game
}

class CastListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var literatureIdentity: LiteratureIdentity?
	var showIdentity: ShowIdentity?
	var gameIdentity: GameIdentity?
	var castKind: CastKind = .show
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

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

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

		if !self.castIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchCast()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.showIdentity != nil || self.literatureIdentity != nil || self.gameIdentity != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchCast()
			}
		}
	}

	override func configureEmptyDataView() {
        self.emptyBackgroundView.configureImageView(image: .Empty.cast)
		self.emptyBackgroundView.configureLabels(title: "No Cast", detail: "This \(self.castKind.rawValue) doesn't have casts yet. Please check back again later.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the cast.")
		#endif
		#endif
	}

	/// Fetch cast for the current show.
	func fetchCast() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing cast...")
		#endif

		switch self.castKind {
		case .show:
			do {
				guard let showIdentity = self.showIdentity else { return }
				let castIdentityResponse = try await KService.getCast(forShow: showIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.castIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = castIdentityResponse.next
				self.castIdentities.append(contentsOf: castIdentityResponse.data)
				self.castIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .literature:
			do {
				guard let literatureIdentity = self.literatureIdentity else { return }
				let castIdentityResponse = try await KService.getCast(forLiterature: literatureIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.castIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = castIdentityResponse.next
				self.castIdentities.append(contentsOf: castIdentityResponse.data)
				self.castIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .game:
			do {
				guard let gameIdentity = self.gameIdentity else { return }
				let castIdentityResponse = try await KService.getCast(forGame: gameIdentity, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.castIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = castIdentityResponse.next
				self.castIdentities.append(contentsOf: castIdentityResponse.data)
				self.castIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		}

		self.endFetch()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.castListCollectionViewController.characterDetailsSegue.identifier:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case R.segue.castListCollectionViewController.personDetailsSegue.identifier:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		default: break
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension CastListCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard let cast = self.cast[indexPath] else { return }
		guard let person = cast.relationships.people?.data.first else { return }

		self.performSegue(withIdentifier: R.segue.castListCollectionViewController.personDetailsSegue.identifier, sender: person)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard let cast = self.cast[indexPath] else { return }
		guard let character = cast.relationships.characters.data.first else { return }

		self.performSegue(withIdentifier: R.segue.castListCollectionViewController.characterDetailsSegue.identifier, sender: character)
	}
}

// MARK: - SectionLayoutKind
extension CastListCollectionViewController {
	/// List of cast section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
