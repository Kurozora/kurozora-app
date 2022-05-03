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
	var people: [Person] = []
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
	/// Initialize a new instance of CharacterDetailsCollectionViewController with the given character id.
	///
	/// - Parameter characterID: The character id to use when initializing the view.
	///
	/// - Returns: an initialized instance of CharacterDetailsCollectionViewController.
	static func `init`(with characterID: Int) -> CharacterDetailsCollectionViewController {
		if let characterDetailsCollectionViewController = R.storyboard.characters.characterDetailsCollectionViewController() {
			characterDetailsCollectionViewController.characterID = characterID
			return characterDetailsCollectionViewController
		}

		fatalError("Failed to instantiate CharacterDetailsCollectionViewController with the given character id.")
	}

	/// Initialize a new instance of CharacterDetailsCollectionViewController with the given character object.
	///
	/// - Parameter show: The `Show` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of CharacterDetailsCollectionViewController.
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

		DispatchQueue.global(qos: .userInteractive).async {
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
		KService.getDetails(forCharacterID: characterID, including: ["shows", "people"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let characters):
				DispatchQueue.main.async {
					self.character = characters.first
					self.people = characters.first?.relationships?.people?.data ?? []
					self.shows = characters.first?.relationships?.shows?.data ?? []
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.characterDetailsCollectionViewController.showsListSegue.identifier:
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.characterID = self.character.id
			}
		case R.segue.characterDetailsCollectionViewController.showDetailsSegue.identifier:
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				guard let show = sender as? Show else { return }
				showDetailCollectionViewController.showID = show.id
			}
		case R.segue.characterDetailsCollectionViewController.peopleListSegue.identifier:
			if let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController {
				peopleListCollectionViewController.characterID = self.character.id
			}
		case R.segue.characterDetailsCollectionViewController.personDetailsSegue.identifier:
			if let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController {
				guard let person = sender as? Person else { return }
				personDetailsCollectionViewController.personID = person.id
			}
		default: break
		}
	}
}

// MARK: - UICollectionViewDataSource
extension CharacterDetailsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.character != nil ? CharacterDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let characterDetailSection = CharacterDetail.Section(rawValue: section) ?? .header
		var itemsPerSection = self.character != nil ? characterDetailSection.rowCount : 0

		switch characterDetailSection {
		case .about:
			if self.character.attributes.about?.isEmpty ?? true {
				itemsPerSection = 0
			}
		case .shows:
			itemsPerSection = self.shows.count
		case .people:
			itemsPerSection = self.people.count
		default: break
		}

		return itemsPerSection
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let characterDetailSection = CharacterDetail.Section(rawValue: indexPath.section) ?? .header
		let reuseIdentifier = characterDetailSection.identifierString(for: indexPath.item)
		let characterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

		switch characterDetailSection {
		case .header:
			(characterCollectionViewCell as? CharacterHeaderCollectionViewCell)?.character = self.character
		case .about:
			let textViewCollectionViewCell = characterCollectionViewCell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.delegate = self
			textViewCollectionViewCell?.textViewCollectionViewCellType = .about
			textViewCollectionViewCell?.textViewContent = self.character.attributes.about
		case .information:
			if let informationCollectionViewCell = characterCollectionViewCell as? InformationCollectionViewCell {
				informationCollectionViewCell.characterDetailInformation = CharacterDetail.Information(rawValue: indexPath.item) ?? .debut
				informationCollectionViewCell.character = self.character
			}
		case .shows:
			if self.shows.count != 0 {
				(characterCollectionViewCell as? SmallLockupCollectionViewCell)?.configure(using: self.shows[indexPath.item])
				(characterCollectionViewCell as? SmallLockupCollectionViewCell)?.delegate = self
			}
		case .people:
			if self.people.count != 0 {
				(characterCollectionViewCell as? PersonLockupCollectionViewCell)?.configure(using: self.people[indexPath.item])
			}
		}

		return characterCollectionViewCell
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let characterDetailSection = CharacterDetail.Section(rawValue: indexPath.section) ?? .header
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: characterDetailSection.stringValue, indexPath: indexPath, segueID: characterDetailSection.segueIdentifier)
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

// MARK: - BaseLockupCollectionViewCellDelegate
extension CharacterDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func chooseStatusButtonPressed(_ sender: UIButton, on cell: BaseLockupCollectionViewCell) {
		WorkflowController.shared.isSignedIn {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let show = self.shows[indexPath.item]

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { title, value  in
				KService.addToLibrary(withLibraryStatus: value, showID: show.id) { result in
					switch result {
					case .success(let libraryUpdate):
						show.attributes.update(using: libraryUpdate)

							// Update entry in library
						cell.libraryStatus = value
						cell.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					case .failure:
						break
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: "Remove from library", style: .destructive) { _ in
					KService.removeFromLibrary(showID: show.id) { result in
						switch result {
						case .success(let libraryUpdate):
							show.attributes.update(using: libraryUpdate)

								// Update edntry in library
							cell.libraryStatus = .none
							cell.libraryStatusButton?.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						case .failure:
							break
						}
					}
				})
			}

				// Present the controller
			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(actionSheetAlertController, animated: true, completion: nil)
			}
		}
	}

	func reminderButtonPressed(on cell: BaseLockupCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		self.shows[indexPath.item].toggleReminder()
	}
}
