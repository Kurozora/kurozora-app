//
//  StudioDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var studioID: Int = 0
	var studio: Studio! {
		didSet {
			self.title = studio.attributes.name

			studio.relationships?.shows?.data.forEachInParallel { [weak self] show in
				guard let self = self else { return }
				self.fetchDetails(for: show.id)
			}
		}
	}
	var shows: [Show] = [] {
		didSet {
			if self.shows.count == self.studio.relationships?.shows?.data.count {
				_prefersActivityIndicatorHidden = true

				self.collectionView.reloadData()

				#if DEBUG
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.endRefreshing()
				#endif
				#endif
			}
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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Fetch studio details
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchStudioDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchStudioDetails()
	}

	/// Fetches the currently viewed studio's details.
	func fetchStudioDetails() {
		KService.getDetails(forStudioID: studioID, including: ["shows"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let studios):
				self.studio = studios.first
			case .failure: break
			}
		}
	}

	/// Fetches details for the given show id.
	///
	/// - Parameter showID: The id used to fetch the show's details.
	func fetchDetails(for showID: Int) {
		KService.getDetails(forShowID: showID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let shows):
				if let show = shows.first {
					self.shows.append(show)
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.studioDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.showID = show.id
		case R.segue.studioDetailsCollectionViewController.showsListSegue.identifier:
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.studioID = self.studio.id
			}
		default: break
		}
	}
}

// MARK: - UICollectionViewDataSource
extension StudioDetailsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.studio != nil ? StudioDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let studioDetailSection = StudioDetail.Section(rawValue: section) ?? .header
		var itemsPerSection = self.studio != nil ? studioDetailSection.rowCount : 0

		switch studioDetailSection {
		case .about:
			if self.studio.attributes.about?.isEmpty ?? true {
				itemsPerSection = 0
			}
		case .shows:
			if let studioShowsCount = self.studio.relationships?.shows?.data.count {
				itemsPerSection = studioShowsCount
			}
		default: break
		}

		return itemsPerSection
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let studioDetailSection = StudioDetail.Section(rawValue: indexPath.section) ?? .header
		let reuseIdentifier = studioDetailSection.identifierString(for: indexPath.item)
		let studioCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

		switch studioDetailSection {
		case .header:
			(studioCollectionViewCell as? StudioHeaderCollectionViewCell)?.studio = self.studio
		case .about:
			let textViewCollectionViewCell = studioCollectionViewCell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.delegate = self
			textViewCollectionViewCell?.textViewCollectionViewCellType = .about
			textViewCollectionViewCell?.textViewContent = self.studio.attributes.about
		case .information:
			if let informationCollectionViewCell = studioCollectionViewCell as? InformationCollectionViewCell {
				informationCollectionViewCell.studioDetailInformation = StudioDetail.Information(rawValue: indexPath.item) ?? .founded
				informationCollectionViewCell.studio = self.studio
			}
		case .shows:
			if self.shows.count != 0 {
				(studioCollectionViewCell as? SmallLockupCollectionViewCell)?.configure(using: self.shows[indexPath.item])
				(studioCollectionViewCell as? SmallLockupCollectionViewCell)?.delegate = self
			}
		}

		return studioCollectionViewCell
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let studioDetailSection = StudioDetail.Section(rawValue: indexPath.section) ?? .header
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: studioDetailSection.stringValue, indexPath: indexPath, segueID: studioDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - InformationButtonCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: InformationButtonCollectionViewCellDelegate {
	func informationButtonCollectionViewCell(_ cell: InformationButtonCollectionViewCell, didPressButton button: UIButton) {
		guard cell.studioDetailInformation == .website else { return }
		guard let websiteURL = self.studio.attributes.websiteUrl?.url else { return }
		UIApplication.shared.kOpen(websiteURL)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.studio.attributes.about
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension StudioDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
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
