//
//  UsersListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

enum UsersListFetchType {
	case follow
	case search
}

class UsersListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var user: User? = nil
	var users: [IndexPath: User] = [:]
	var userIdentities: [UserIdentity] = []
	var searachQuery: String = ""
	var usersListFetchType: UsersListFetchType = .search
	var usersListType: UsersListType = .followers
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, UserIdentity>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

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

	// MARK: - Views
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = self.usersListType.stringValue

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		switch self.usersListFetchType {
		case .follow:
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the \(self.usersListType.stringValue).")
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the users.")
		}
		#endif

		self.configureDataSource()

		// Fetch follow list.
		if !self.userIdentities.isEmpty {
			self.endFetch()
		} else {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchUsers()
			}
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
		var buttonAction: (() -> Void)? = nil

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
						self.followUser()
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

		emptyBackgroundView.configureImageView(image: R.image.empty.follow()!)
		emptyBackgroundView.configureLabels(title: titleString, detail: detailString)
		emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

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
	func followUser() {
		guard let userID = self.user?.id else { return }
		let userIdentity = UserIdentity(id: userID)

		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }

			Task {
				do {
					let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
					DispatchQueue.main.async {
						self.user?.attributes.update(using: followUpdateResponse.data)
						self.handleRefreshControl()
					}
				} catch {
					print("-----", error.localizedDescription)
				}
			}
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
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing \(self.usersListType.stringValue.lowercased())...")
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing users...")
		}
		#endif

		switch self.usersListFetchType {
		case .follow:
			guard let user = self.user else { return }
			let userIdentity = UserIdentity(id: user.id)

			do {
				let userIdentityResponse = try await KService.getFollowList(forUser: userIdentity, self.usersListType, next: self.nextPageURL).value

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
				let searchResponse = try await KService.search(.kurozora, of: [.users], for: self.searachQuery, next: self.nextPageURL, limit: 25, filter: nil).value

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
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the \(self.usersListType.stringValue.lowercased()).")
		case .search:
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh the users.")
		}
		#endif
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.usersListCollectionViewController.userDetailsSegue.identifier:
			guard let profileTableViewController = segue.destination as? ProfileTableViewController else { return }
			guard let user = sender as? User else { return }
			profileTableViewController.user = user
		default: break
		}
	}
}

// MARK: - UserLockupCollectionViewCellDelegate
extension UsersListCollectionViewController: UserLockupCollectionViewCellDelegate {
	func userLockupCollectionViewCell(_ cell: UserLockupCollectionViewCell, didPressFollow button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard var user = self.users[indexPath] else { return }
		let userIdentity = UserIdentity(id: user.id)

		Task {
			do {
				let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
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
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
