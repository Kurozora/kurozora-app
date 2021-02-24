//
//  CharacterDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CharacterDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var characterID: Int = 0
	var character: Character! {
		didSet {
			self.title = character.attributes.name
		}
	}
	var actors: [Actor] = []
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
		Initialize a new instance of CharacterDetailsCollectionViewController with the given character id.

		- Parameter characterID: The character id to use when initializing the view.

		- Returns: an initialized instance of CharacterDetailsCollectionViewController.
	*/
	static func `init`(with characterID: Int) -> CharacterDetailsCollectionViewController {
		if let characterDetailsCollectionViewController = R.storyboard.characters.characterDetailsCollectionViewController() {
			characterDetailsCollectionViewController.characterID = characterID
			return characterDetailsCollectionViewController
		}

		fatalError("Failed to instantiate CharacterDetailsCollectionViewController with the given character id.")
	}

	/**
		Initialize a new instance of CharacterDetailsCollectionViewController with the given character object.

		- Parameter show: The `Show` object to use when initializing the view controller.

		- Returns: an initialized instance of CharacterDetailsCollectionViewController.
	*/
	static func `init`(with character: Character) -> CharacterDetailsCollectionViewController {
		if let characterDetailsCollectionViewController = R.storyboard.characters.characterDetailsCollectionViewController() {
			characterDetailsCollectionViewController.character = character
			return characterDetailsCollectionViewController
		}

		fatalError("Failed to instantiate CharacterDetailsCollectionViewController with the given Character object.")
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

		DispatchQueue.global(qos: .background).async {
			self.fetchCharacterDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchCharacterDetails()
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

	func fetchCharacterDetails() {
		KService.getDetails(forCharacterID: characterID, including: ["shows", "actors"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let characters):
				DispatchQueue.main.async {
					self.character = characters.first
					self.actors = characters.first?.relationships?.actors?.data ?? []
					self.shows = characters.first?.relationships?.shows?.data ?? []
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.characterDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.characterID = self.character.id
			}
		} else if segue.identifier == R.segue.characterDetailsCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let show = (sender as? BaseLockupCollectionViewCell)?.show {
					showDetailCollectionViewController.showID = show.id
				}
			}
		} else if segue.identifier == R.segue.characterDetailsCollectionViewController.actorsListSegue.identifier {
			if let actorsListCollectionViewController = segue.destination as? ActorsListCollectionViewController {
				actorsListCollectionViewController.characterID = self.character.id
			}
		} else if segue.identifier == R.segue.characterDetailsCollectionViewController.actorDetailsSegue.identifier {
			if let actorDetailsCollectionViewController = segue.destination as? ActorDetailsCollectionViewController {
				if let actor = (sender as? ActorLockupCollectionViewCell)?.actor {
					actorDetailsCollectionViewController.actorID = actor.id
				}
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension CharacterDetailsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.character != nil ? CharacterSection.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let characterSection = CharacterSection(rawValue: section) ?? .main
		var itemsPerSection = self.character != nil ? characterSection.rowCount : 0

		switch characterSection {
		case .about:
			if let aboutCharacter = self.character.attributes.about, aboutCharacter.isEmpty {
				itemsPerSection = 0
			}
		case .shows:
			itemsPerSection = self.shows.count
		case .actors:
			itemsPerSection = self.actors.count
		default: break
		}

		return itemsPerSection
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let characterSection = CharacterSection(rawValue: indexPath.section) ?? .main
		let reuseIdentifier = characterSection.identifierString(for: indexPath.item)
		let characterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

		switch characterSection {
		case .main:
			(characterCollectionViewCell as? CharacterHeaderCollectionViewCell)?.character = self.character
		case .about:
			let textViewCollectionViewCell = characterCollectionViewCell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.delegate = self
			textViewCollectionViewCell?.textViewCollectionViewCellType = .about
			textViewCollectionViewCell?.textViewContent = self.character.attributes.about
		case .information:
			if let informationCollectionViewCell = characterCollectionViewCell as? InformationCollectionViewCell {
				informationCollectionViewCell.characterInformationSection = CharacterInformationSection(rawValue: indexPath.item) ?? .debut
				informationCollectionViewCell.character = self.character
			}
		case .shows:
			if self.shows.count != 0 {
				(characterCollectionViewCell as? SmallLockupCollectionViewCell)?.show = self.shows[indexPath.item]
			}
		case .actors:
			if self.actors.count != 0 {
				(characterCollectionViewCell as? ActorLockupCollectionViewCell)?.actor = self.actors[indexPath.item]
			}
		}

		return characterCollectionViewCell
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let characterSection = CharacterSection(rawValue: indexPath.section) ?? .main
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.segueID = characterSection.segueIdentifier
		titleHeaderCollectionReusableView.indexPath = indexPath
		titleHeaderCollectionReusableView.title = characterSection.stringValue
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension CharacterDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.character.attributes.about
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension CharacterDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}
