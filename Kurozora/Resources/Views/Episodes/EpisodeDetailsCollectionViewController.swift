//
//  EpisodeDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class EpisodeDetailsCollectionViewController: KCollectionViewController {
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
	var indexPath = IndexPath()

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

	// MARK: - Initializers
	/// Initialize a new instance of EpisodeDetailsCollectionViewController with the given episode id.
	///
	/// - Parameter episodeID: The episode id to use when initializing the view.
	///
	/// - Returns: an initialized instance of EpisodeDetailsCollectionViewController.
	static func `init`(with episodeID: Int) -> EpisodeDetailsCollectionViewController {
		if let episodeDetailsCollectionViewController = R.storyboard.episodes.episodeDetailsCollectionViewController() {
			episodeDetailsCollectionViewController.episodeID = episodeID
			return episodeDetailsCollectionViewController
		}

		fatalError("Failed to instantiate EpisodeDetailsCollectionViewController with the given show id.")
	}

	/// Initialize a new instance of EpisodeDetailsCollectionViewController with the given episode object.
	///
	/// - Parameter episode: The `Episode` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of EpisodeDetailsCollectionViewController.
	static func `init`(with episode: Episode) -> EpisodeDetailsCollectionViewController {
		if let episodeDetailsCollectionViewController = R.storyboard.episodes.episodeDetailsCollectionViewController() {
			episodeDetailsCollectionViewController.episode = episode
			return episodeDetailsCollectionViewController
		}

		fatalError("Failed to instantiate EpisodeDetailsCollectionViewController with the given Show object.")
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
		if self.episode == nil {
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchEpisodeDetails()
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		NotificationCenter.default.addObserver(self, selector: #selector(updateEpisodes(_:)), name: .KEpisodeWatchStatusDidUpdate, object: nil)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		NotificationCenter.default.removeObserver(self, name: .KEpisodeWatchStatusDidUpdate, object: nil)
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
//		KService.getDetails(forEpisode: self.episodeID) { [weak self] result in
//			guard let self = self else { return }
//			switch result {
//			case .success(let episode):
//				DispatchQueue.main.async {
//					self.episode = episode.first
//				}
//			case .failure: break
//			}
//		}
	}

	/// Update the episodes list.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func updateEpisodes(_ notification: NSNotification) {
		guard let indexPath = notification.userInfo?["indexPath"] as? IndexPath else { return }
		collectionView.reloadItems(at: [indexPath])
	}

	/// Opens the share sheet of the episode.
	@objc func shareEpisode() {
		self.episode?.openShareSheet(on: self)
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		self.episode?.openShareSheet(on: self, barButtonItem: sender)
	}
}

// MARK: - UICollectionViewDataSource
extension EpisodeDetailsCollectionViewController {
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.episode != nil ? EpisodeDetail.Section.allCases.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var itemsPerSection = 0

		switch EpisodeDetail.Section(rawValue: section) {
		case .header:
			itemsPerSection = 1
		case .synopsis:
			if let synopsis = self.episode.attributes.synopsis, !synopsis.isEmpty {
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
			let episodeDetailHeaderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! EpisodeDetailHeaderCollectionViewCell
			episodeDetailHeaderCollectionViewCell.indexPath = self.indexPath
			episodeDetailHeaderCollectionViewCell.episode = self.episode
			return episodeDetailHeaderCollectionViewCell
		case .synopsis:
			let textViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! TextViewCollectionViewCell
			textViewCollectionViewCell.delegate = self
			textViewCollectionViewCell.textViewCollectionViewCellType = .synopsis
			textViewCollectionViewCell.textViewContent = self.episode.attributes.synopsis
			return textViewCollectionViewCell
		case .rating:
			let ratingCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! RatingCollectionViewCell
			ratingCollectionViewCell.delegate = self
			ratingCollectionViewCell.configure(using: self.episode)
			return ratingCollectionViewCell
		case .information:
			let informationCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: episodeDetailSection.identifierString, for: indexPath) as! InformationCollectionViewCell
			informationCollectionViewCell.configure(using: self.episode, for: EpisodeDetail.Information(rawValue: indexPath.item) ?? .number)
			return informationCollectionViewCell
		}
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		return supplementaryView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.episode.attributes.synopsis
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension EpisodeDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - RatingCollectionViewCellDelegate
extension EpisodeDetailsCollectionViewController: RatingCollectionViewCellDelegate {
	func rateShow(with rating: Double) { }

	func rateEpisode(with rating: Double) {
		Task {
			await self.episode.rate(using: rating)
		}
	}
}
