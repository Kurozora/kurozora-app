//
//  PeopleListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class PeopleListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var characterIdentity: CharacterIdentity? = nil
	var people: [IndexPath: Person] = [:]
	var personIdentities: [PersonIdentity] = []
	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, PersonIdentity>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, PersonIdentity>! = nil
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
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the people.")
		#endif

		self.configureDataSource()

		if !self.personIdentities.isEmpty {
			self.endFetch()
		} else if self.characterIdentity != nil {
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchPeople()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.characterIdentity != nil {
			self.nextPageURL = nil
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchPeople()
			}
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No People", detail: "Can't get people list. Please reload the page or restart the app and check your WiFi connection.")

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

	func fetchPeople() {
		guard let characterIdentity = self.characterIdentity else {
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
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing people...")
			#endif
		}

		KService.getPeople(forCharacter: characterIdentity, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let personIdentityResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.personIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = personIdentityResponse.next
				self.personIdentities.append(contentsOf: personIdentityResponse.data)

				DispatchQueue.main.async {
					self.endFetch()

					// Reset refresh controller title
					#if !targetEnvironment(macCatalyst)
					self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the people.")
					#endif
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.peopleListCollectionViewController.personDetailsSegue.identifier:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		default: break
		}
	}
}

// MARK: - SectionLayoutKind
extension PeopleListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
