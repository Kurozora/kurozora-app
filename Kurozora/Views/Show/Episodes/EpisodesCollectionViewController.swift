//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwipeCellKit

class EpisodesCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var goToButton: UIBarButtonItem! {
		didSet {
			goToButton.theme_tintColor = KThemePicker.tintColor.rawValue
		}
	}

	// MARK: - Properties
	var seasonID: Int = 0
	var episodeElements: [EpisodeElement]? {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.configureDataSource()
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

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

		// Fetch episodes
		DispatchQueue.global(qos: .background).async {
			self.fetchEpisodes()
		}
	}

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		collectionView?.emptyDataSetView { view in
			view.titleLabelString(NSAttributedString(string: "No Episodes", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "This season doesn't have episodes yet. Please check back again later.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.episodes())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
		}
	}

	/// Fetches the episodes from the server.
	func fetchEpisodes() {
		KService.getEpisodes(forSeasonID: seasonID) { result in
			switch result {
			case .success(let episodes):
				DispatchQueue.main.async {
					self.episodeElements = episodes.episodes
				}
			case .failure: break
			}
		}
	}

	/// Goes to the first item in the presented collection view.
	fileprivate func goToFirstEpisode() {
		collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = R.image.symbols.chevron_down_circle()
	}

	/// Goes to the last item in the presented collection view.
	fileprivate func goToLastEpisode() {
		guard let episodes = episodeElements else { return }
		collectionView.scrollToItem(at: IndexPath(row: episodes.count - 1, section: 0), at: .centeredVertically, animated: true)
		goToButton.image = R.image.symbols.chevron_up_circle()
	}

	/// Goes to the last watched episode in the presented collection view.
	fileprivate func goToLastWatchedEpisode() {
		guard let lastWatchedEpisode = episodeElements?.closestMatch(index: 0, predicate: {
			if let episodeWatchStatus = $0.currentUser?.watchStatus {
				return episodeWatchStatus == .notWatched
			}
			return false
		}) else { return }
		collectionView.scrollToItem(at: IndexPath(row: lastWatchedEpisode.0, section: 0), at: .centeredVertically, animated: true)
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList() {
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let visibleIndexPath = collectionView.indexPathsForVisibleItems

		if !visibleIndexPath.contains(IndexPath(item: 0, section: 0)) {
			// Go to first episode
			let goToFirstEpisode = UIAlertAction.init(title: "Go to first episode", style: .default, handler: { (_) in
				self.goToFirstEpisode()
			})
			action.addAction(goToFirstEpisode)
		} else {
			// Go to last episode
			let goToLastEpisode = UIAlertAction.init(title: "Go to last episode", style: .default, handler: { (_) in
				self.goToLastEpisode()
			})
			action.addAction(goToLastEpisode)
		}

		// Go to last watched episode
		let goToLastWatchedEpisode = UIAlertAction.init(title: "Go to last watched episode", style: .default, handler: { (_) in
			self.goToLastWatchedEpisode()
		})
		action.addAction(goToLastWatchedEpisode)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.barButtonItem = goToButton
		}

		self.present(action, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func goToButtonPressed(_ sender: UIBarButtonItem) {
		showActionList()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.episodesCollectionViewController.episodeDetailSegue.identifier, let episodeCell = sender as? EpisodeLockupCollectionViewCell {
			if let episodeDetailViewController = segue.destination as? EpisodeDetailCollectionViewControlle, let indexPath = collectionView.indexPath(for: episodeCell) {
				episodeDetailViewController.episodeElement = episodeElements?[indexPath.row]
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension EpisodesCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		let segueIdentifier = R.segue.episodesCollectionViewController.episodeDetailSegue.identifier

		self.performSegue(withIdentifier: segueIdentifier, sender: collectionViewCell)
	}
}

// MARK: - KCollectionViewDataSource
extension EpisodesCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [EpisodeLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
			guard let episodesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.episodeLockupCollectionViewCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.episodeLockupCollectionViewCell.identifier)")
			}
			episodesCollectionViewCell.delegate = self
			episodesCollectionViewCell.episodeElement = self.episodeElements?[indexPath.row]
			return episodesCollectionViewCell
		}

		let itemsPerSection = episodeElements?.count ?? 0
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		SectionLayoutKind.allCases.forEach {
			snapshot.appendSections([$0])
			let itemOffset = $0.rawValue * itemsPerSection
			let itemUpperbound = itemOffset + itemsPerSection
			snapshot.appendItems(Array(itemOffset..<itemUpperbound))
		}
		dataSource.apply(snapshot)
		collectionView.reloadEmptyDataSet()
	}
}

// MARK: - KCollectionViewDelegateLayout
extension EpisodesCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 374).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int) -> CGFloat {
		return (0.60 / columnsCount.double).cgFloat
	}

	override func contentInset(forItemInSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func contentInset(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = self.contentInset(forItemInSection: section, layout: layoutEnvironment)

			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let heightFraction = self.groupHeightFraction(forSection: section, with: columns)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(heightFraction))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
	}
}

// MARK: - SwipeCollectionViewCellDelegate
extension EpisodesCollectionViewController: SwipeCollectionViewCellDelegate {
	func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard let episodeLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? EpisodeLockupCollectionViewCell else { return nil}

		switch orientation {
		case .right:
			let rateAction = SwipeAction(style: .default, title: "Rate") { _, _ in
			}
			rateAction.backgroundColor = .clear
			rateAction.image = R.image.rate_circle()
			rateAction.textColor = .kYellow
			rateAction.font = .systemFont(ofSize: 16, weight: .semibold)
			rateAction.transitionDelegate = ScaleTransition.default

			let moreAction = SwipeAction(style: .default, title: "More") { _, _ in
				episodeLockupCollectionViewCell.populateActionSheet()
			}
			moreAction.backgroundColor = .clear
			moreAction.image = R.image.more_circle()
			moreAction.textColor = #colorLiteral(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
			moreAction.font = .systemFont(ofSize: 16, weight: .semibold)
			moreAction.transitionDelegate = ScaleTransition.default

			return [rateAction, moreAction]
		case .left:
			let watchedAction = SwipeAction(style: .default, title: "") { _, _ in
				episodeLockupCollectionViewCell.watchedButtonPressed()
			}
			watchedAction.backgroundColor = .clear
			if let tag = episodeLockupCollectionViewCell.episodeWatchedButton?.tag {
				watchedAction.title = (tag == 0) ? "Mark as Watched" : "Mark as Unwatched"
				watchedAction.image = (tag == 0) ? R.image.watched_circle() : R.image.unwatched_circle()
				watchedAction.textColor = (tag == 0) ? .kurozora : #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
			}
			watchedAction.font = .systemFont(ofSize: 16, weight: .semibold)
			watchedAction.transitionDelegate = ScaleTransition.default

			return [watchedAction]
		}
	}

	func visibleRect(for collectionView: UICollectionView) -> CGRect? {
		return collectionView.safeAreaLayoutGuide.layoutFrame
	}

	func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .selection
		options.transitionStyle = .reveal
		options.expansionDelegate = ScaleAndAlphaExpansion.default
		options.buttonSpacing = 5
		options.backgroundColor = .clear
		return options
	}
}

// MARK: - SectionLayoutKind
extension EpisodesCollectionViewController {
	/**
		List of episode section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
