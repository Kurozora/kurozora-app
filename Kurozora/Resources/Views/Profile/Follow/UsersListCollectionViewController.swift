//
//  UsersListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A delegate that receives the user selected in a mention picker.
protocol UsersListMentionSelectionDelegate: AnyObject {
	/// Tells the delegate that the user picked a result from the mention search.
	///
	/// - Parameters:
	///    - controller: The controller hosting the mention search.
	///    - user: The user the mention should resolve to.
	func usersListCollectionViewController(_ controller: UsersListCollectionViewController, didSelectUserForMention user: User)
}

/// The data source the ``UsersListCollectionViewController`` should fetch from.
enum UsersListFetchType {
	/// A user's followers or following list.
	case follow

	/// Free-text user search.
	case search

	/// The global reputation leaderboard.
	case reputation

	/// The auth user's blocked users list.
	case blocked
}

class UsersListCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	/// The segues that this controller can perform.
	enum SegueIdentifiers: String, SegueIdentifier {
		case userDetailsSegue
	}

	/// The sections that the diffable data source can render.
	///
	/// In reputation mode the snapshot has both `.podium` and `.main`. In other modes only
	/// `.main` is appended, so a non-reputation snapshot continues to behave as before.
	enum SectionLayoutKind: Int, CaseIterable {
		case podium = 0
		case main = 1
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		/// A user identity rendered as a row in the main section.
		case userIdentity(_: UserIdentity)

		/// A user identity rendered as a podium tile in the leaderboard's podium section,
		/// carrying its 1-based display rank for label rendering.
		case podiumUserIdentity(_: UserIdentity, rank: Int)
	}

	// MARK: - Properties
	/// The user whose follow list is being displayed. Unused in `.search` and `.reputation` modes.
	var user: User?

	/// The user identities currently loaded into the list.
	var userIdentities: [UserIdentity] = []

	/// The current search query, or empty when not searching.
	var searchQuery: String = ""

	/// The data source the controller fetches from.
	var usersListFetchType: UsersListFetchType = .search

	/// The follow list variant when ``usersListFetchType`` is ``UsersListFetchType/follow``.
	var usersListType: UsersListType = .followers

	// MARK: Mention search
	/// The delegate notified when the user picks a result while running as a mention picker.
	weak var mentionSelectionDelegate: UsersListMentionSelectionDelegate?

	private var mentionSearchController: UISearchController?
	private var mentionSearchTask: Task<Void, Never>?

	/// `true` while the mention picker is animating away, used to suppress search-bar interactions.
	var isDismissingMentionSearch = false

	// MARK: SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: Empty state
	override var emptyStateImage: UIImage {
		switch self.usersListFetchType {
		case .blocked:
			let configuration = UIImage.SymbolConfiguration(pointSize: 96, weight: .regular)
			return UIImage(systemName: "xmark.shield", withConfiguration: configuration) ?? .Empty.follow
		case .follow, .search, .reputation:
			return .Empty.follow
		}
	}

	override var emptyStateTitle: String {
		switch self.usersListFetchType {
		case .follow:
			switch self.usersListType {
			case .followers: return L10n.usersListFollowersEmptyTitle
			case .following: return L10n.usersListFollowingEmptyTitle
			}
		case .search, .reputation:
			return L10n.usersListEmptyTitle
		case .blocked:
			return L10n.blockedUsers
		}
	}

	override var emptyStateDetail: String {
		let username = self.user?.attributes.username

		switch self.usersListFetchType {
		case .follow:
			switch self.usersListType {
			case .followers:
				if self.user?.id == User.current?.id {
					return L10n.followersEmptyDetailSelf
				} else {
					return L10n.followersEmptyDetailOther(username ?? L10n.thisUserLowercase)
				}
			case .following:
				if self.user?.id == User.current?.id {
					return L10n.followingEmptyDetailSelf
				} else {
					return L10n.followingEmptyDetailOther(username ?? L10n.thisUserCapitalized)
				}
			}
		case .search:
			return L10n.usersListSearchEmptyDetail
		case .reputation:
			return L10n.leaderboardEmptyDetail
		case .blocked:
			return L10n.blockedUsersIntro
		}
	}

	override var hasLoadedInitialData: Bool {
		!self.userIdentities.isEmpty
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		switch self.usersListFetchType {
		case .reputation:
			self.title = L10n.reputationLeaderboardTitle
		case .follow, .search:
			self.title = self.usersListType.localizedTitle
		case .blocked:
			self.title = L10n.blockedUsers
			NotificationCenter.default.addObserver(self, selector: #selector(self.handleBlockStatusDidChange(_:)), name: .KUserBlockStatusDidChange, object: nil)
		}

		if self.mentionSelectionDelegate != nil {
			self._prefersRefreshControlDisabled = true
			self.configureMentionSearchController()
		}

		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsersList(self.usersListType.localizedTitleLowercase))
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsers)
		case .reputation:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshLeaderboard)
		case .blocked:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsers)
		}
		#endif
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if self.mentionSelectionDelegate != nil, let searchBar = self.mentionSearchController?.searchBar {
			DispatchQueue.main.async {
				searchBar.becomeFirstResponder()
			}
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self, name: .KUserBlockStatusDidChange, object: nil)
	}

	// MARK: - Notifications
	/// Reconfigures the row whose user's block status has changed.
	@objc private func handleBlockStatusDidChange(_ notification: Notification) {
		guard self.usersListFetchType == .blocked,
			  let changedUserID = notification.object as? KurozoraItemID
		else { return }

		for (indexPath, item) in self.cache {
			guard let user = item as? User, user.id == changedUserID else { continue }

			let cell = self.collectionView.cellForItem(at: indexPath) as? UserLockupCollectionViewCell
			cell?.updateBlockButton(isBlocked: user.attributes.blockStatus == .blocked)
			break
		}
	}

	// MARK: - Fetching
	override func fetchItems() async {
		if self.mentionSelectionDelegate != nil, self.searchQuery.isEmpty {
			self._prefersActivityIndicatorHidden = true
			return
		}

		if self.usersListFetchType == .follow, self.user == nil {
			return
		}

		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer {
			self.endFetch()

			#if !targetEnvironment(macCatalyst)
			switch self.usersListFetchType {
			case .follow:
				self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsersList(self.usersListType.localizedTitleLowercase))
			case .search:
				self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsers)
			case .reputation:
				self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshLeaderboard)
			case .blocked:
				self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsers)
			}
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingUsersList(self.usersListType.localizedTitleLowercase))
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingUsers)
		case .reputation:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingLeaderboard)
		case .blocked:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingUsers)
		}
		#endif

		do {
			switch self.usersListFetchType {
			case .follow:
				guard let user = self.user else { return }
				let userIdentity = UserIdentity(id: user.id)
				let response = try await KService.followList(forUser: userIdentity, self.usersListType)
					.cursor(self.nextPageCursor)
					.limit(self.nextPageCursor != nil ? 100 : 25)
					.response()

				if self.nextPageCursor == nil {
					self.userIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.userIdentities.append(contentsOf: response.data)
				self.userIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, types: [.users], query: self.searchQuery)
					.cursor(self.nextPageCursor)
					.limit(self.nextPageCursor != nil ? 100 : 25)
					.filter(nil)
					.response()

				if self.nextPageCursor == nil {
					self.userIdentities = []
				}

				self.nextPageCursor = searchResponse.data.users?.nextCursor
				self.userIdentities.append(contentsOf: searchResponse.data.users?.data ?? [])
				self.userIdentities.removeDuplicates()
			case .reputation:
				let response = try await KService.userIndex()
					.sort("reputation", direction: "most")
					.cursor(self.nextPageCursor)
					.limit(self.nextPageCursor != nil ? 100 : 25)
					.response()

				if self.nextPageCursor == nil {
					self.userIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.userIdentities.append(contentsOf: response.data)
				self.userIdentities.removeDuplicates()
			case .blocked:
				let response = try await KService.myBlockList()
					.cursor(self.nextPageCursor)
					.limit(self.nextPageCursor != nil ? 100 : 25)
					.response()

				if self.nextPageCursor == nil {
					self.userIdentities = []
				}

				self.nextPageCursor = response.nextCursor
				self.userIdentities.append(contentsOf: response.data)
				self.userIdentities.removeDuplicates()
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	override func configureEmptyDataView() {
		super.configureEmptyDataView()

		guard self.usersListFetchType == .follow, self.usersListType == .followers,
			  let user = self.user, user.id != User.current?.id
		else { return }

		let username = user.attributes.username
		self.emptyBackgroundView.configureButton(title: L10n.followUserButton(username), handler: { [weak self] in
			Task { [weak self] in
				await self?.followUser()
			}
		})
	}

	/// Follows the user whose followers are displayed by this controller.
	func followUser() async {
		guard let userID = self.user?.id else { return }

		let userIdentity = UserIdentity(id: userID)
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }

		do {
			let followUpdateResponse = try await KService.toggleFollow(userIdentity).response()
			DispatchQueue.main.async {
				self.user?.attributes.update(using: followUpdateResponse.data)
				self.handleRefreshControl()
			}
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .userIdentity(let id): return id as? Element
		case .podiumUserIdentity(let id, _): return id as? Element
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .userDetailsSegue: return ProfileTableViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .userDetailsSegue:
			guard let destination = destination as? ProfileTableViewController else { return }
			guard let user = sender as? User else { return }
			destination.user = user
		}
	}
}

// MARK: - Mention Search
extension UsersListCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
	func configureMentionSearchController() {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.text = self.searchQuery
		searchController.searchBar.delegate = self

		self.navigationItem.searchController = searchController
		self.navigationItem.hidesSearchBarWhenScrolling = false
		self.definesPresentationContext = true

		self.mentionSearchController = searchController
	}

	func updateSearchResults(for searchController: UISearchController) {
		let query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		guard query != self.searchQuery else { return }

		self.searchQuery = query
		self.mentionSearchTask?.cancel()

		guard !query.isEmpty else {
			self.nextPageCursor = nil
			self.cache = [:]
			self.userIdentities = []

			var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
			snapshot.appendSections([.main])
			self.dataSource.apply(snapshot)
			self._prefersActivityIndicatorHidden = true
			return
		}

		self.mentionSearchTask = Task { [weak self] in
			do {
				try await Task.sleep(nanoseconds: 300_000_000)
			} catch { return }

			guard let self = self, !Task.isCancelled else { return }

			self.nextPageCursor = nil
			self.cache = [:]
			await self.fetchItems()
		}
	}

	func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
		return self.isDismissingMentionSearch
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		self.isDismissingMentionSearch = true
		self.navigationController?.dismiss(animated: true)
	}
}

// MARK: - KCollectionViewDataSource
extension UsersListCollectionViewController {
	override func configureDataSource() {
		let userLockupCellRegistration = self.getConfiguredUserCell()
		let podiumLockupCellRegistration = self.getConfiguredPodiumCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			switch itemKind {
			case .userIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: userLockupCellRegistration, for: indexPath, item: itemKind)
			case .podiumUserIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: podiumLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()

		switch self.usersListFetchType {
		case .reputation:
			let topThree = Array(self.userIdentities.prefix(3))

			if !topThree.isEmpty {
				self.snapshot.appendSections([.podium])

				// Display order is `[rank 2 (left), rank 1 (center), rank 3 (right)]`
				// so the layout's item provider can map indices directly to columns.
				// Each item still carries its true rank for label rendering.
				var podiumItems: [ItemKind] = []

				if topThree.indices.contains(1) {
					podiumItems.append(.podiumUserIdentity(topThree[1], rank: 2))
				}

				if topThree.indices.contains(0) {
					podiumItems.append(.podiumUserIdentity(topThree[0], rank: 1))
				}

				if topThree.indices.contains(2) {
					podiumItems.append(.podiumUserIdentity(topThree[2], rank: 3))
				}

				self.snapshot.appendItems(podiumItems, toSection: .podium)
			}

			let remaining = self.userIdentities.count > 3 ? Array(self.userIdentities[3...]) : []

			if !remaining.isEmpty {
				self.snapshot.appendSections([.main])
				let items: [ItemKind] = remaining.map { .userIdentity($0) }
				self.snapshot.appendItems(items, toSection: .main)
			}
		case .follow, .search, .blocked:
			self.snapshot.appendSections([.main])
			let items: [ItemKind] = self.userIdentities.map { .userIdentity($0) }
			self.snapshot.appendItems(items, toSection: .main)
		}

		self.dataSource.apply(self.snapshot)
	}

	/// Returns the cell registration that renders standard user rows for the main section.
	private func getConfiguredUserCell() -> UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind>(cellNib: UserLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .userIdentity:
				let user: User? = self.fetchModel(at: indexPath)

				if user == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<User>.self, UserIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				if self.usersListFetchType == .reputation {
					// The main section starts at the 4th user, so the visual rank is `indexPath.item + 4`.
					cell.configureForLeaderboard(using: user, rank: indexPath.item + 4)
				} else if self.mentionSelectionDelegate != nil {
					cell.configureForMention(using: user)
				} else if self.usersListFetchType == .blocked {
					cell.delegate = self
					cell.configureForBlocked(using: user)
				} else {
					cell.delegate = self
					cell.configure(using: user)
				}
			case .podiumUserIdentity:
				break
			}
		}
	}

	/// Returns the cell registration that renders the podium tiles for the leaderboard.
	private func getConfiguredPodiumCell() -> UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .podiumUserIdentity(_, let rank):
				let user: User? = self.fetchModel(at: indexPath)

				if user == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<User>.self, UserIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.configure(using: user, rank: rank, showsReputation: true)
			case .userIdentity:
				break
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension UsersListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414.0 ? (width / 384.0).rounded() : (width / 284.0).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }

			if self.usersListFetchType == .reputation,
			   let kind = self.snapshot?.sectionIdentifiers[safe: section],
			   kind == .podium {
				return Layouts.podiumSection(section, layoutEnvironment: layoutEnvironment)
			}

			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.usersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension UsersListCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let user = self.cache[indexPath] as? User else { return }

		if let mentionDelegate = self.mentionSelectionDelegate {
			guard !self.isDismissingMentionSearch else { return }

			self.isDismissingMentionSearch = true
			mentionDelegate.usersListCollectionViewController(self, didSelectUserForMention: user)
			self.navigationController?.dismiss(animated: true)
		} else {
			self.show(.userDetailsSegue, sender: user)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		// In reputation mode the first three users live in the podium section, so the
		// main section's local `indexPath.item` is offset by 3 from `userIdentities`.
		if self.usersListFetchType == .reputation,
		   let kind = self.snapshot?.sectionIdentifiers[safe: indexPath.section],
		   kind == .main {
			self.paginateIfNeeded(at: indexPath, totalItems: max(self.userIdentities.count - 3, 0))
		} else {
			self.paginateIfNeeded(at: indexPath, totalItems: self.userIdentities.count)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let user = self.cache[indexPath] as? User else { return nil }

		if self.usersListFetchType == .blocked {
			return user.blockedRowContextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath])
		}

		let collectionViewCell = collectionView.cellForItem(at: indexPath)
		return user.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
	}
}

// MARK: - UserLockupCollectionViewCellDelegate
extension UsersListCollectionViewController: UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let user = self.cache[indexPath] as? User
		else { return }

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

	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressBlockToggle button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let user = self.cache[indexPath] as? User
		else { return }

		Task { [weak self] in
			await user.block(on: self)
			cell.updateBlockButton(isBlocked: user.attributes.blockStatus == .blocked)
		}
	}
}
