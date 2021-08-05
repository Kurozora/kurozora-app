//
//  PersonDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class PersonDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var personID: Int = 0
	var person: Person! {
		didSet {
			self.title = person.attributes.fullName
		}
	}
	var characters: [Character] = []
	var shows: [Show] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.collectionView.reloadData {
				self.toggleEmptyDataView()
			}
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

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
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	/**
		Initialize a new instance of PersonDetailsCollectionViewController with the given person id.

		- Parameter personID: The person id to use when initializing the view.

		- Returns: an initialized instance of PersonDetailsCollectionViewController.
	*/
	static func `init`(with personID: Int) -> PersonDetailsCollectionViewController {
		if let personDetailsCollectionViewController = R.storyboard.people.personDetailsCollectionViewController() {
			personDetailsCollectionViewController.personID = personID
			return personDetailsCollectionViewController
		}

		fatalError("Failed to instantiate PersonDetailsCollectionViewController with the given perosn id.")
	}

	/**
		Initialize a new instance of PersonDetailsCollectionViewController with the given person object.

		- Parameter show: The `Show` object to use when initializing the view controller.

		- Returns: an initialized instance of PersonDetailsCollectionViewController.
	*/
	static func `init`(with person: Person) -> PersonDetailsCollectionViewController {
		if let personDetailsCollectionViewController = R.storyboard.people.personDetailsCollectionViewController() {
			personDetailsCollectionViewController.person = person
			return personDetailsCollectionViewController
		}

		fatalError("Failed to instantiate PersonDetailsCollectionViewController with the given Person object.")
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

		// Fetch person details
		DispatchQueue.global(qos: .background).async {
			self.fetchPersonDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchPersonDetails()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This character doesn't have details yet. Please check back again later.")

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

	func fetchPersonDetails() {
		KService.getDetails(forPersonID: personID, including: ["shows", "characters"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let people):
				DispatchQueue.main.async {
					self.person = people.first
					self.characters = people.first?.relationships?.characters?.data ?? []
					self.shows = people.first?.relationships?.shows?.data ?? []
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.personDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.personID = self.person.id
			}
		} else if segue.identifier == R.segue.personDetailsCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let show = (sender as? BaseLockupCollectionViewCell)?.show {
					showDetailCollectionViewController.showID = show.id
				}
			}
		} else if segue.identifier == R.segue.personDetailsCollectionViewController.charactersListSegue.identifier {
			if let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController {
				charactersListCollectionViewController.personID = self.person.id
			}
		} else if segue.identifier == R.segue.personDetailsCollectionViewController.characterDetailsSegue.identifier {
			if let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController {
				if let character = (sender as? CharacterLockupCollectionViewCell)?.character {
					characterDetailsCollectionViewController.characterID = character.id
				}
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension PersonDetailsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.person != nil ? PersonDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let characterSection = PersonDetail.Section(rawValue: section) ?? .header
		var itemsPerSection = self.person != nil ? characterSection.rowCount : 0

		switch characterSection {
		case .about:
			if self.person.attributes.about?.isEmpty ?? true {
				itemsPerSection = 0
			}
		case .shows:
			itemsPerSection = self.shows.count
		case .characters:
			itemsPerSection = self.characters.count
		default: break
		}

		return itemsPerSection
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let personDetailSection = PersonDetail.Section(rawValue: indexPath.section) ?? .header
		let reuseIdentifier = personDetailSection.identifierString(for: indexPath.item)
		let personCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

		switch personDetailSection {
		case .header:
			(personCollectionViewCell as? PersonHeaderCollectionViewCell)?.person = self.person
		case .about:
			let textViewCollectionViewCell = personCollectionViewCell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.delegate = self
			textViewCollectionViewCell?.textViewCollectionViewCellType = .about
			textViewCollectionViewCell?.textViewContent = self.person.attributes.about
		case .information:
			if let informationCollectionViewCell = personCollectionViewCell as? InformationCollectionViewCell {
				informationCollectionViewCell.personDetailInformation = PersonDetail.Information(rawValue: indexPath.item) ?? .aliases
				informationCollectionViewCell.person = self.person
			}
		case .shows:
			if self.shows.count != 0 {
				(personCollectionViewCell as? SmallLockupCollectionViewCell)?.show = self.shows[indexPath.item]
			}
		case .characters:
			if self.characters.count != 0 {
				(personCollectionViewCell as? CharacterLockupCollectionViewCell)?.character = self.characters[indexPath.item]
			}
		}

		return personCollectionViewCell
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let personDetailSection = PersonDetail.Section(rawValue: indexPath.section) ?? .header
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.segueID = personDetailSection.segueIdentifier
		titleHeaderCollectionReusableView.indexPath = indexPath
		titleHeaderCollectionReusableView.title = personDetailSection.stringValue
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension PersonDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.person.attributes.about
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension PersonDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}
