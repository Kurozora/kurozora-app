//
//  EpisodesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

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

		// Setup scroll view.
		collectionView.delaysContentTouches = false
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
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let visibleIndexPath = collectionView.indexPathsForVisibleItems

		if !visibleIndexPath.contains(IndexPath(item: 0, section: 0)) {
			// Go to first episode
			let goToFirstEpisode = UIAlertAction.init(title: "Go to first episode", style: .default, handler: { (_) in
				self.goToFirstEpisode()
			})
			alertController.addAction(goToFirstEpisode)
		} else {
			// Go to last episode
			let goToLastEpisode = UIAlertAction.init(title: "Go to last episode", style: .default, handler: { (_) in
				self.goToLastEpisode()
			})
			alertController.addAction(goToLastEpisode)
		}

		// Go to last watched episode
		let goToLastWatchedEpisode = UIAlertAction.init(title: "Go to last watched episode", style: .default, handler: { (_) in
			self.goToLastWatchedEpisode()
		})
		alertController.addAction(goToLastWatchedEpisode)

		alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = alertController.popoverPresentationController {
			popoverController.barButtonItem = goToButton
		}

		self.present(alertController, animated: true, completion: nil)
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
	override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.8,
					   initialSpringVelocity: 0.2,
					   options: [.beginFromCurrentState, .allowUserInteraction],
					   animations: {
						cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		}, completion: nil)
	}

	override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.4,
					   initialSpringVelocity: 0.2,
					   options: [.beginFromCurrentState, .allowUserInteraction],
					   animations: {
						cell?.transform = CGAffineTransform.identity
		}, completion: nil)
	}

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
		var columnCount = (width / 374).rounded().int
		if columnCount < 0 {
			columnCount = 1
		} else if columnCount > 5 {
			columnCount = 5
		}
		return columnCount
	}

	override func groupHeightFraction(forSection section: Int, with columnsCount: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> CGFloat {
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
			let heightFraction = self.groupHeightFraction(forSection: section, with: columns, layout: layoutEnvironment)
			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(heightFraction))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
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
