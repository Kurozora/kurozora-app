//
//  CastCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CastCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var showID: Int = 0
	var cast: [Cast] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Cast>! = nil

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

		self.configureDataSource()

		// Fetch cast
		DispatchQueue.global(qos: .background).async {
			self.fetchCast()
		}
    }

	// MARK: - Functions
	override func handleRefreshControl() {
		DispatchQueue.global(qos: .background).async {
			self.fetchCast()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No Cast", detail: "This show doesn't have casts yet. Please check back again later.")

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

	/// Fetch cast for the current show.
	fileprivate func fetchCast() {
		KService.getCast(forShowID: self.showID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let cast):
				self.cast = cast
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.castCollectionViewController.characterDetailsSegue.identifier {
			if let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController {
				if let castCollectionViewCell = sender as? CastCollectionViewCell, let character = castCollectionViewCell.cast.relationships.characters.data.first {
					characterDetailsCollectionViewController.characterID = character.id
				}
			}
		} else if segue.identifier == R.segue.castCollectionViewController.actorDetailsSegue.identifier {
			if let actorDetailsCollectionViewController = segue.destination as? ActorDetailsCollectionViewController {
				if let castCollectionViewCell = sender as? CastCollectionViewCell, let actor = castCollectionViewCell.cast.relationships.actors.data.first {
					actorDetailsCollectionViewController.actorID = actor.id
				}
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension CastCollectionViewController {
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
}

// MARK: - KCollectionViewDataSource
extension CastCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [CastCollectionViewCell.self]
	}

	override func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Cast>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Cast) -> UICollectionViewCell? in
			guard let castCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.castCollectionViewCell, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(R.reuseIdentifier.castCollectionViewCell.identifier)")
			}
			castCollectionViewCell.delegate = self
			castCollectionViewCell.cast = item
			return castCollectionViewCell
		}
	}

	override func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Cast>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.cast)
		dataSource.apply(snapshot)
	}
}

// MARK: - CastCollectionViewCellDelegate
extension CastCollectionViewController: CastCollectionViewCellDelegate {
	func actorButtonPressed(_ cell: CastCollectionViewCell) {
		self.performSegue(withIdentifier: R.segue.castCollectionViewController.actorDetailsSegue.identifier, sender: cell)
	}

	func characterButtonPressed(_ cell: CastCollectionViewCell) {
		self.performSegue(withIdentifier: R.segue.castCollectionViewController.characterDetailsSegue.identifier, sender: cell)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension CastCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 374).rounded().int
		if columnCount > 5 {
			return 5
		}
		return columnCount > 0 ? columnCount : 1
	}

	override func contentInset(forSection section: Int, layout collectionViewLayout: NSCollectionLayoutEnvironment) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)
	}

	override func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150.0))
			let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
			layoutGroup.interItemSpacing = .fixed(10.0)

			let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
			layoutSection.interGroupSpacing = 10.0
			layoutSection.contentInsets = self.contentInset(forSection: section, layout: layoutEnvironment)
			return layoutSection
		}
		return layout
	}
}

// MARK: - SectionLayoutKind
extension CastCollectionViewController {
	/**
		List of cast section layout kind.

		```
		case main = 0
		```
	*/
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
