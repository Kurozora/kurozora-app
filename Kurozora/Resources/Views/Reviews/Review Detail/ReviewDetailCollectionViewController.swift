//
//  ReviewDetailCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ReviewDetailCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var review: Review?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// Refresh control
	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	// Activity indicator
	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	// MARK: - Views
	private var closeBarButtonItem: UIBarButtonItem!
	private var moreBarButtonItem: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = Trans.reviews

		self.configureNavigationItems()
		self.configureDataSource()
		self.updateDataSource()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewDeleted(_:)), name: .KReviewDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KReviewDidDelete, object: nil)
	}

	// MARK: - Functions
	private func configureNavigationItems() {
		self.configureCloseBarButtonItem()
		self.configureMoreBarButtonItem()
	}

	private func configureCloseBarButtonItem() {
		self.closeBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismiss(animated: true, completion: nil)
		})
		self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
	}

	private func configureMoreBarButtonItem() {
		guard let review = self.review else { return }
		let contextMenu = review.makeContextMenu(in: self, userInfo: nil, sourceView: nil, barButtonItem: nil)
		self.moreBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: contextMenu)
		self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
	}

	@objc private func handleReviewDeleted(_ notification: NSNotification) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - KCollectionViewDataSource
extension ReviewDetailCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ReviewCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			switch itemKind {
			case .review(let review, _):
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.self, for: indexPath)
				reviewCollectionViewCell?.delegate = self
				reviewCollectionViewCell?.configureCell(using: review, showsFullReview: true)
				return reviewCollectionViewCell
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		if let review = self.review {
			self.snapshot.appendItems([.review(review)], toSection: .main)
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ReviewDetailCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		return 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.fullSection(section, columns: columns, layoutEnvironment: layoutEnvironment)
		}
	}
}

// MARK: - ReviewCollectionViewCellDelegate
extension ReviewDetailCollectionViewController: ReviewCollectionViewCellDelegate {
	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressUserName sender: AnyObject) {
		self.review?.visitOriginalPosterProfile(from: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didPressMoreButton button: UIButton) {}
}

// MARK: - SectionLayoutKind
extension ReviewDetailCollectionViewController {
	/// List of review detail section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Review` object.
		case review(_: Review, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .review(let review, let id):
				hasher.combine(review)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.review(let review1, let id1), .review(let review2, let id2)):
				return review1 == review2 && id1 == id2
			}
		}
	}
}
