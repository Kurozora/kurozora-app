//
//  EpisodeDetailCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class EpisodeDetailCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var episodeID = 0
	var episode: Episode! {
		didSet {
			self.title = self.episode.attributes.title
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

		// Fetch cast
		DispatchQueue.global(qos: .background).async {
			self.fetchEpisodeDetails()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchEpisodeDetails()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.episodes()!)
		emptyBackgroundView.configureLabels(title: "No Details", detail: "This episode doesn't have details yet. Please check back again later.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetch details for the current episode.
	fileprivate func fetchEpisodeDetails() {
		KService.getDetails(forEpisodeID: self.episodeID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let episode):
				DispatchQueue.main.async {
					self.episode = episode.first
				}
			case .failure: break
			}
		}
	}
}

// MARK: - UICollectionViewDataSource
extension EpisodeDetailCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.episode != nil ? EpisodeDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var itemsPerSection = 0

		switch EpisodeDetail.Section(rawValue: section) {
		case .header:
			itemsPerSection = 1
		case .synopsis:
			if let overview = self.episode.attributes.overview, !overview.isEmpty {
				itemsPerSection = 1
			}
		case .rating:
			itemsPerSection = 1
		case .information:
			itemsPerSection = EpisodeDetail.Information.allCases.count
		default: break
		}

		return itemsPerSection
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let episodeDetailSection = EpisodeDetail.Section(rawValue: indexPath.section) else { fatalError("Can't determine cellForItemAt indexPath: \(indexPath)") }

		switch episodeDetailSection {
		case .header:
			let episodeLockupCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! EpisodeLockupCollectionViewCell
			return episodeLockupCollectionViewCell
		case .synopsis:
			let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! TextViewCollectionViewCell
			return textViewCollectionViewCell
		case .rating:
			let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! RatingCollectionViewCell
			return ratingCollectionViewCell
		case .information:
			let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! InformationCollectionViewCell
			return informationCollectionViewCell
		}
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		return supplementaryView
	}
}

// MARK: - UICollectionViewDelegate
extension EpisodeDetailCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		switch EpisodeDetail.Section(rawValue: indexPath.section) {
		case .header:
			let episodeLockupCollectionViewCell = cell as? EpisodeLockupCollectionViewCell
			episodeLockupCollectionViewCell?.simpleModeEnabled = true
			episodeLockupCollectionViewCell?.episode = self.episode
		case .synopsis:
			let textViewCollectionViewCell = cell as? TextViewCollectionViewCell
			textViewCollectionViewCell?.delegate = self
			textViewCollectionViewCell?.textViewCollectionViewCellType = .synopsis
			textViewCollectionViewCell?.textViewContent = self.episode.attributes.overview
//		case .rating:
//			let ratingCollectionViewCell = cell as? RatingCollectionViewCell
//			ratingCollectionViewCell?.showDetailsElement = showDetailsElement
		case .information:
			let informationCollectionViewCell = cell as? InformationCollectionViewCell
			informationCollectionViewCell?.episodeDetailInformation = EpisodeDetail.Information(rawValue: indexPath.item) ?? .number
			informationCollectionViewCell?.episode = episode
		default: break
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		guard let sectionHeaderReusableView = view as? TitleHeaderCollectionReusableView else { return }
		guard let episodeDetailSection = EpisodeDetail.Section(rawValue: indexPath.section) else { return }
		sectionHeaderReusableView.delegate = self
		sectionHeaderReusableView.title = episodeDetailSection.stringValue
		sectionHeaderReusableView.indexPath = indexPath
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension EpisodeDetailCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.episode.attributes.overview
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension EpisodeDetailCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}
