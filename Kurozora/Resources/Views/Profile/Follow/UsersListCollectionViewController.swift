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
	func usersListCollectionViewController(_ controller: UsersListCollectionViewController, didSelectUserForMention user: User)
}

/// A source of users for ``UsersListCollectionViewController``.
enum UsersListFetchType {
	case follow
	case search
}

/// A paginated list of users.
class UsersListCollectionViewController: ListCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case userDetailsSegue
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// An item displayed in the list.
	enum ItemKind: Hashable {
		case userIdentity(_: UserIdentity)
	}

	// MARK: - Properties
	var user: User?
	var userIdentities: [UserIdentity] = []
	var searchQuery: String = ""
	var usersListFetchType: UsersListFetchType = .search
	var usersListType: UsersListType = .followers

	// MARK: - Mention search
	weak var mentionSelectionDelegate: UsersListMentionSelectionDelegate?
	private var mentionSearchController: UISearchController?
	private var mentionSearchTask: Task<Void, Never>?
	var isDismissingMentionSearch = false

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage { .Empty.follow }

	override var emptyStateTitle: String {
		switch self.usersListFetchType {
		case .follow: return "No \(self.usersListType.stringValue)"
		case .search: return "No Users"
		}
	}

	override var emptyStateDetail: String {
		let username = self.user?.attributes.username
		switch self.usersListFetchType {
		case .follow:
			switch self.usersListType {
			case .followers:
				if self.user?.id == User.current?.id {
					return "Follow other users so they will follow you back. Who knows, you might meet your next BFF!"
				} else {
					return "Be the first to follow \(username ?? "this user")!"
				}
			case .following:
				if self.user?.id == User.current?.id {
					return "Follow a user and they will show up here!"
				} else {
					return "\(username ?? "This user") is not following anyone yet."
				}
			}
		case .search:
			return "Can't get users list. Please reload the page or restart the app and check your WiFi connection."
		}
	}

	override var hasLoadedInitialData: Bool {
		!self.userIdentities.isEmpty
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.usersListType.stringValue

		if self.mentionSelectionDelegate != nil {
			self._prefersRefreshControlDisabled = true
			self.configureMentionSearchController()
		}

		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsersList(self.usersListType.stringValue))
		case .search:
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
				self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsersList(self.usersListType.stringValue.lowercased()))
			case .search:
				self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsers)
			}
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingUsersList(self.usersListType.stringValue.lowercased()))
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingUsers)
		}
		#endif

		do {
			switch self.usersListFetchType {
			case .follow:
				guard let user = self.user else { return }
				let userIdentity = UserIdentity(id: user.id)
				let response = try await KService.getFollowList(forUser: userIdentity, self.usersListType, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				if self.nextPageURL == nil {
					self.userIdentities = []
				}

				self.nextPageURL = response.next
				self.userIdentities.append(contentsOf: response.data)
				self.userIdentities.removeDuplicates()
			case .search:
				let searchResponse = try await KService.search(.kurozora, of: [.users], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil)

				if self.nextPageURL == nil {
					self.userIdentities = []
				}

				self.nextPageURL = searchResponse.data.users?.next
				self.userIdentities.append(contentsOf: searchResponse.data.users?.data ?? [])
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
		self.emptyBackgroundView.configureButton(title: "＋ Follow \(username)", handler: { [weak self] in
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
			let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity)
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
			self.nextPageURL = nil
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

			self.nextPageURL = nil
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

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			return collectionView.dequeueConfiguredReusableCell(using: userLockupCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		let items: [ItemKind] = self.userIdentities.map { .userIdentity($0) }
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot)
	}

	private func getConfiguredUserCell() -> UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind>(cellNib: UserLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .userIdentity:
				let user: User? = self.fetchModel(at: indexPath)

				if user == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(UserResponse.self, UserIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				if self.mentionSelectionDelegate != nil {
					cell.configureForMention(using: user)
				} else {
					cell.delegate = self
					cell.configure(using: user)
				}
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
			self.show(SegueIdentifiers.userDetailsSegue, sender: user)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		self.paginateIfNeeded(at: indexPath, totalItems: self.userIdentities.count)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let user = self.cache[indexPath] as? User else { return nil }

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

		Task {
			do {
				let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity)
				user.attributes.update(using: followUpdateResponse.data)
				cell.updateFollowButton(using: followUpdateResponse.data.followStatus)
			} catch {
				print("-----", error.localizedDescription)
			}
		}
	}
}
