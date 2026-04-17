//
//  UsersListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol UsersListMentionSelectionDelegate: AnyObject {
	func usersListCollectionViewController(_ controller: UsersListCollectionViewController, didSelectUserForMention user: User)
}

enum UsersListFetchType {
	case follow
	case search
}

class UsersListCollectionViewController: KCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case userDetailsSegue
	}

	// MARK: - Properties
	var user: User?
	var userIdentities: [UserIdentity] = []
	var searchQuery: String = ""
	var usersListFetchType: UsersListFetchType = .search
	var usersListType: UsersListType = .followers

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	// Mention search
	weak var mentionSelectionDelegate: UsersListMentionSelectionDelegate?

	private var mentionSearchController: UISearchController?
	private var mentionSearchTask: Task<Void, Never>?
	var isDismissingMentionSearch = false

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
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if self.mentionSelectionDelegate != nil, let searchBar = self.mentionSearchController?.searchBar {
			DispatchQueue.main.async {
				searchBar.becomeFirstResponder()
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.usersListType.stringValue

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		if self.mentionSelectionDelegate != nil {
			self._prefersRefreshControlDisabled = true
		}

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsersList(self.usersListType.stringValue))
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsers)
		}
		#endif

		if self.mentionSelectionDelegate != nil {
			self.configureMentionSearchController()
		}

		self.configureDataSource()

		// Fetch follow list.
		if !self.userIdentities.isEmpty {
			self.endFetch()
		} else if self.mentionSelectionDelegate == nil || !self.searchQuery.isEmpty {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchUsers()
			}
		} else {
			self._prefersActivityIndicatorHidden = true
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if self.user != nil {
			self.nextPageURL = nil
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchUsers()
			}
		}
	}

	override func configureEmptyDataView() {
		var titleString: String
		var detailString: String
		var buttonTitle: String = ""
		var buttonAction: (() -> Void)?

		let username = self.user?.attributes.username
		switch self.usersListFetchType {
		case .follow:
			titleString = "No \(self.usersListType.stringValue)"

			switch self.usersListType {
			case .followers:
				if self.user?.id == User.current?.id {
					detailString = "Follow other users so they will follow you back. Who knows, you might meet your next BFF!"
				} else {
					detailString = "Be the first to follow \(username ?? "this user")!"
					buttonTitle = "＋ Follow \(username ?? "User")"
					buttonAction = {
						Task {
							await self.followUser()
						}
					}
				}
			case .following:
				if self.user?.id == User.current?.id {
					detailString = "Follow a user and they will show up here!"
				} else {
					detailString = "\(username ?? "This user") is not following anyone yet."
				}
			}
		case .search:
			titleString = "No Users"
			detailString = "Can't get users list. Please reload the page or restart the app and check your WiFi connection."
		}

		self.emptyBackgroundView.configureImageView(image: .Empty.follow)
		self.emptyBackgroundView.configureLabels(title: titleString, detail: detailString)
		self.emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
		#endif
	}

	/// Sends a request to follow the user whose followers list is being viewed.
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

	/// Fetch the follow list for the currently viewed profile.
	func fetchUsers() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingUsersList(self.usersListType.stringValue.lowercased()))
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingUsers)
		}
		#endif

		switch self.usersListFetchType {
		case .follow:
			guard let user = self.user else { return }
			let userIdentity = UserIdentity(id: user.id)

			do {
				let userIdentityResponse = try await KService.getFollowList(forUser: userIdentity, self.usersListType, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25)

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.userIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = userIdentityResponse.next
				self.userIdentities.append(contentsOf: userIdentityResponse.data)
				self.userIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		case .search:
			do {
				let searchResponse = try await KService.search(.kurozora, of: [.users], for: self.searchQuery, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil)

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.userIdentities = []
				}

				// Save next page url and append new data
				self.nextPageURL = searchResponse.data.users?.next
				self.userIdentities.append(contentsOf: searchResponse.data.users?.data ?? [])
				self.userIdentities.removeDuplicates()
			} catch {
				print(error.localizedDescription)
			}
		}

		self.endFetch()

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsersList(self.usersListType.stringValue.lowercased()))
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshUsers)
		}
		#endif
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
			guard let profileTableViewController = destination as? ProfileTableViewController else { return }
			guard let user = sender as? User else { return }
			profileTableViewController.user = user
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
			// Debounce 300ms to avoid excessive API calls while typing
			do {
				try await Task.sleep(nanoseconds: 300_000_000)
			} catch { return }

			guard let self = self, !Task.isCancelled else { return }

			self.nextPageURL = nil
			self.cache = [:]
			await self.fetchUsers()
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

// MARK: - SectionLayoutKind
extension UsersListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension UsersListCollectionViewController {
	/// List of item layout kind.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `UserIdentity` object.
		case userIdentity(_: UserIdentity)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .userIdentity(let userIdentity):
				hasher.combine(userIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.userIdentity(let userIdentity1), .userIdentity(let userIdentity2)):
				return userIdentity1 == userIdentity2
			}
		}
	}
}

// MARK: - Cell Configuration
extension UsersListCollectionViewController {
	func getConfiguredUserCell() -> UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind>(cellNib: UserLockupCollectionViewCell.nib) { [weak self] userLockupCollectionViewCell, indexPath, itemKind in
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
					userLockupCollectionViewCell.configureForMention(using: user)
				} else {
					userLockupCollectionViewCell.delegate = self
					userLockupCollectionViewCell.configure(using: user)
				}
			}
		}
	}
}
