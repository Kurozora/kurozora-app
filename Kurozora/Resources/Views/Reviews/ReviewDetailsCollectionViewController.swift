//
//  ReviewDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ReviewDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var review: Review?

	/// The superseded versions of the review.
	private var revisions: [ReviewRevision] = []

	/// Whether the superseded versions are shown.
	private var isShowingRevisions = false

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

		self.title = L10n.reviews

		self.configureNavigationItems()
		self.configureDataSource()
		self.updateDataSource()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReviewDeleted(_:)), name: .KReviewDidDelete, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateReviewTranslation(_:)), name: .KTranslationDidUpdate, object: nil)
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

	/// Fetches the superseded versions of the review.
	private func fetchRevisions() async {
		guard let review = self.review else { return }

		do {
			let response = try await KService.revisions(for: ReviewIdentity(id: review.id)).response()
			self.revisions = response.data
		} catch {
			print("-----", error.localizedDescription)
		}

		self.updateDataSource()
	}

	@objc private func handleReviewDeleted(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			guard notification.userInfo?["reviewID"] as? KurozoraItemID == self.review?.id else { return }

			self.dismiss(animated: true, completion: nil)
		}
	}
}

// MARK: - KCollectionViewDataSource
extension ReviewDetailsCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [
			ReviewCollectionViewCell.self,
			DisclosureToggleCollectionViewCell.self,
			ReviewRevisionCollectionViewCell.self
		]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, itemKind: ItemKind) -> UICollectionViewCell? in
			switch itemKind {
			case .review(let review):
				let reviewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.self, for: indexPath)
				reviewCollectionViewCell?.delegate = self
				reviewCollectionViewCell?.configureCell(using: review, showsFullReview: true, isElevated: review.attributes.isElevated)
				return reviewCollectionViewCell
			case .revisionsToggle(let isExpanded):
				let disclosureToggleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: DisclosureToggleCollectionViewCell.self, for: indexPath)
				disclosureToggleCollectionViewCell?.configure(title: isExpanded ? L10n.reviewsHideEarlier : L10n.reviewsShowEarlier("\(self.revisionCount)"))
				return disclosureToggleCollectionViewCell
			case .revision(let revision):
				let reviewRevisionCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewRevisionCollectionViewCell.self, for: indexPath)
				reviewRevisionCollectionViewCell?.configure(using: revision)
				return reviewRevisionCollectionViewCell
			}
		}
	}

	/// Re-renders the review when its translation state changes.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateReviewTranslation(_ notification: NSNotification) {
		Task { @MainActor [weak self] in
			guard let self = self else { return }

			// Re-applying the snapshot alone changes nothing: the item identifiers are
			// unchanged, so the diff is empty and no cell is ever reconfigured.
			self.snapshot.reconfigureItems(self.snapshot.itemIdentifiers)
			self.dataSource.apply(self.snapshot, animatingDifferences: false)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		if let review = self.review {
			self.snapshot.appendSections([.main])
			self.snapshot.appendItems([.review(review)], toSection: .main)

			if self.revisionCount > 0 {
				self.snapshot.appendSections([.revisions])
				self.snapshot.appendItems([.revisionsToggle(isExpanded: self.isShowingRevisions)], toSection: .revisions)

				if self.isShowingRevisions {
					self.snapshot.appendItems(self.revisions.map { .revision($0) }, toSection: .revisions)
				}
			}
		}

		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}

	/// The number of superseded versions the review keeps.
	private var revisionCount: Int {
		return self.review?.attributes.revisionCount ?? 0
	}
}

// MARK: - UICollectionViewDelegate
extension ReviewDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		guard case .revisionsToggle = self.dataSource.itemIdentifier(for: indexPath) else { return }

		self.isShowingRevisions.toggle()

		if self.isShowingRevisions, self.revisions.isEmpty {
			Task { [weak self] in
				await self?.fetchRevisions()
			}
		}

		self.updateDataSource()
	}
}

// MARK: - KCollectionViewDelegateLayout
extension ReviewDetailsCollectionViewController {
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
extension ReviewDetailsCollectionViewController: ReviewCollectionViewCellDelegate {
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

	func reviewCollectionViewCellDidTapTranslation(_ cell: ReviewCollectionViewCell) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard let review = self.review else { return }

		TranslationService.shared.toggleTranslation(for: review)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapTranslationSettings button: UIButton) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard let review = self.review else { return }

		TranslationSettingsViewController.present(for: review, from: button, in: self)
	}

	func reviewCollectionViewCell(_ cell: ReviewCollectionViewCell, didTapVote vote: ReviewVote) {
		guard let review = self.review else { return }

		Task {
			await review.castVote(vote)
		}
	}
}

// MARK: - SectionLayoutKind
extension ReviewDetailsCollectionViewController {
	/// List of review detail section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
		case revisions
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Review` object.
		case review(_: Review)

		/// Indicates the item kind contains the toggle for the review's superseded versions.
		case revisionsToggle(isExpanded: Bool)

		/// Indicates the item kind contains a `ReviewRevision` object.
		case revision(_: ReviewRevision)
	}
}
