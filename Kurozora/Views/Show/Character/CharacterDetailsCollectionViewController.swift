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
		titleHeaderCollectionReusableView.segueID = characterSection.segueIdentifier
		titleHeaderCollectionReusableView.indexPath = indexPath
		titleHeaderCollectionReusableView.title = characterSection.stringValue
		return titleHeaderCollectionReusableView
	}
}

// MARK: - UICollectionViewDelegate
extension CharacterDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
		} else if let actorLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ActorLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.characterDetailsCollectionViewController.actorDetailsSegue, sender: actorLockupCollectionViewCell)
		}
	}
}

// MARK: - KCollectionViewDataSource
extension CharacterDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ActorLockupCollectionViewCell.self,
			TextViewCollectionViewCell.self,
			InformationCollectionViewCell.self,
			InformationButtonCollectionViewCell.self,
			SmallLockupCollectionViewCell.self
		]
	}

	override func registerNibs(for collectionView: UICollectionView) -> [UICollectionReusableView.Type] {
		return [TitleHeaderCollectionReusableView.self]
	}
}
