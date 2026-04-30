//
//  FeedMessageReSharesViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

final class FeedMessageReSharesViewController: ListCollectionViewController {
	// MARK: - Section
	private enum Section: Int, CaseIterable {
		case main
	}

	private enum ItemKind: Hashable {
		case user(User)
	}

	// MARK: - Properties
	/// The feed message whose re-shares are being shown.
	private let feedMessage: FeedMessage

	/// The selected sort.
	private var sort: ReSharesSortType

	/// The resharers currently rendered.
	private var resharers: [User] = []

	private var dataSource: UICollectionViewDiffableDataSource<Section, ItemKind>!
	private var snapshot: NSDiffableDataSourceSnapshot<Section, ItemKind>!

	// MARK: - Empty state
	override var emptyStateImage: UIImage { .Empty.follow }
	override var emptyStateTitle: String { L10n.amplifyPostsHeadline }
	override var emptyStateDetail: String { L10n.amplifyPostsSubheadline }
	override var hasLoadedInitialData: Bool { !self.resharers.isEmpty }

	// MARK: - Initializers
	init(feedMessage: FeedMessage, sort: ReSharesSortType) {
		self.feedMessage = feedMessage
		self.sort = sort
		super.init()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.sortDidChange(_:)), name: .KFMActivitySortDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.feedMessageDidChange(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.feedMessageDidChange(_:)), name: .KFMDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - Empty state CTA
	override func configureEmptyDataView() {
		super.configureEmptyDataView()

		self.emptyBackgroundView.configureButton(title: L10n.reshare) { [weak self] in
			guard let self = self else { return }
			Task { @MainActor in
				if self.feedMessage.attributes.isReShared {
					await self.feedMessage.undoSimpleReShareMessage(via: self, userInfo: nil)
				} else {
					await self.feedMessage.simpleReShareMessage(via: self, userInfo: nil)
				}
				self.handleRefreshControl()
			}
		}
	}

	// MARK: - Notifications
	@objc private func sortDidChange(_ notification: Notification) {
		guard let newSort = notification.userInfo?["sort"] as? ReSharesSortType else { return }
		guard newSort != self.sort else { return }

		self.sort = newSort
		self.handleRefreshControl()
	}

	@objc private func feedMessageDidChange(_ notification: Notification) {
		self.handleRefreshControl()
	}

	// MARK: - Fetch
	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		do {
			let identity = FeedMessageIdentity(id: self.feedMessage.id)
			let response = try await KService.reShares(forFeedMessage: identity)
				.cursor(self.nextPageCursor)
				.limit(self.nextPageCursor != nil ? 100 : 25)
				.sort(self.sort)
				.response()

			if self.nextPageCursor == nil {
				self.resharers = []
			}

			self.nextPageCursor = response.nextCursor
			self.resharers.append(contentsOf: response.data.compactMap { $0.relationships.users.data.first })
		} catch {
			print(error.localizedDescription)
		}

		await MainActor.run {
			self.endFetch()
		}
	}
}

// MARK: - KCollectionViewDataSource
extension FeedMessageReSharesViewController {
	override func configureDataSource() {
		let userCellRegistration = UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind>(cellNib: UserLockupCollectionViewCell.nib) { cell, _, item in
			switch item {
			case .user(let user):
				cell.configure(using: user)
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<Section, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, item in
			return collectionView.dequeueConfiguredReusableCell(using: userCellRegistration, for: indexPath, item: item)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<Section, ItemKind>()
		self.snapshot.appendSections([.main])
		self.snapshot.appendItems(self.resharers.map { .user($0) }, toSection: .main)
		self.dataSource.apply(self.snapshot)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension FeedMessageReSharesViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414.0 ? (width / 384.0).rounded() : (width / 284.0).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.usersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension FeedMessageReSharesViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
		switch item {
		case .user(let user):
			let profileTableViewController = ProfileTableViewController()(with: user)
			self.show(profileTableViewController, sender: nil)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.resharers.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
		switch item {
		case .user(let user):
			let cell = collectionView.cellForItem(at: indexPath)
			return user.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: cell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - UserLockupCollectionViewCellDelegate
extension FeedMessageReSharesViewController: UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }

		switch item {
		case .user(let user):
			let userIdentity = UserIdentity(id: user.id)

			Task { [weak self] in
				do {
					let followUpdateResponse = try await KService.toggleFollow(userIdentity).response()
					user.attributes.update(using: followUpdateResponse.data)
					cell.updateFollowButton(using: followUpdateResponse.data.followStatus)
				} catch let error as APIError {
					self?.presentAlertController(title: nil, message: error.message)
					print("-----", error.localizedDescription)
				} catch {
					print("-----", error.localizedDescription)
				}
			}
		}
	}
}
