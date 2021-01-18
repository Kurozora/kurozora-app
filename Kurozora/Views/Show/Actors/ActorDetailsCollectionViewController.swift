//
//  ActorDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ActorDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var actorID: Int = 0
	var actor: Actor! {
		didSet {
			self.title = actor.attributes.fullName
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
			self.fetchActorDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchActorDetails()
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

	func fetchActorDetails() {
		KService.getDetails(forActorID: actorID, including: ["shows", "characters"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let actors):
				DispatchQueue.main.async {
					self.actor = actors.first
					self.characters = actors.first?.relationships?.characters?.data ?? []
					self.shows = actors.first?.relationships?.shows?.data ?? []
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.actorDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.actorID = self.actor.id
			}
		} else if segue.identifier == R.segue.actorDetailsCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let show = (sender as? BaseLockupCollectionViewCell)?.show {
					showDetailCollectionViewController.showID = show.id
				}
			}
		} else if segue.identifier == R.segue.actorDetailsCollectionViewController.charactersListSegue.identifier {
			if let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController {
				charactersListCollectionViewController.actorID = self.actor.id
			}
		} else if segue.identifier == R.segue.actorDetailsCollectionViewController.characterDetailsSegue.identifier {
			if let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController {
				if let character = (sender as? CharacterLockupCollectionViewCell)?.character {
					characterDetailsCollectionViewController.characterID = character.id
				}
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension ActorDetailsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.actor != nil ? ActorSection.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let characterSection = ActorSection(rawValue: section) ?? .main
		var itemsPerSection = self.actor != nil ? characterSection.rowCount : 0

		switch characterSection {
		case .about:
			if let aboutActor = self.actor.attributes.about, aboutActor.isEmpty {
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
		let actorSection = ActorSection(rawValue: indexPath.section) ?? .main
		let reuseIdentifier = actorSection.identifierString(for: indexPath.item)
		let actorCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

		switch actorSection {
		case .main:
			(actorCollectionViewCell as? ActorHeaderCollectionViewCell)?.actor = self.actor
		case .about:
			let textViewCollectionViewCell = actorCollectionViewCell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.textViewCollectionViewCellType = .about
			textViewCollectionViewCell?.textViewContent = self.actor.attributes.about
		case .information:
			if let informationCollectionViewCell = actorCollectionViewCell as? InformationCollectionViewCell {
				informationCollectionViewCell.actorDetailsInformationSection = ActorDetailsInformationSection(rawValue: indexPath.item) ?? .occupation
				informationCollectionViewCell.actor = self.actor
			}
		case .shows:
			if self.shows.count != 0 {
				(actorCollectionViewCell as? SmallLockupCollectionViewCell)?.show = self.shows[indexPath.item]
			}
		case .characters:
			if self.characters.count != 0 {
				(actorCollectionViewCell as? CharacterLockupCollectionViewCell)?.character = self.characters[indexPath.item]
			}
		}

		return actorCollectionViewCell
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

// MARK: - UICollectionViewController
extension ActorDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.actorDetailsCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
		} else if let characterLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? CharacterLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.actorDetailsCollectionViewController.characterDetailsSegue, sender: characterLockupCollectionViewCell)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension ActorDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func headerButtonPressed(_ reusableView: TitleHeaderCollectionReusableView) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}
