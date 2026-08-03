//
//  UserAchievementsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class UserAchievementsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var user: User?
	var achievements: [Achievement] = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Achievement>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, Achievement>! = nil

	/// The next page cursor for pagination.
	var nextPageCursor: PageCursor?

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

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.achievements

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.achievements.lowercased(with: Locale.current)))
		#endif

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchAchievements()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		guard self.user != nil else { return }

		self.nextPageCursor = nil

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchAchievements()
		}
	}

	override func configureEmptyDataView() {
		let titleString = L10n.noAchievementsTitle
		let detailString: String = if self.user?.id == User.current?.id {
			L10n.noAchievementsCurrentUserDetail
		} else if let username = self.user?.attributes.username {
			L10n.noAchievementsOtherUserDetail(username)
		} else {
			""
		}

		self.emptyBackgroundView.configureImageView(image: .Empty.rosetteStar)
		self.emptyBackgroundView.configureLabels(title: titleString, detail: detailString)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades the empty data view in or out based on the current item count.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems(inSection: 0) == 0 {
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
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
	}

	/// Fetches the achievements list for the currently viewed profile.
	func fetchAchievements() async {
		guard !self.isRequestInProgress else { return }
		guard let user = self.user else { return }

		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.achievements.lowercased(with: Locale.current)))
		#endif

		let userIdentity = UserIdentity(id: user.id)

		do {
			let response = try await KService.achievements(forUser: userIdentity)
				.cursor(self.nextPageCursor)
				.limit(self.nextPageCursor != nil ? 100 : 25)
				.response()

			if self.nextPageCursor == nil {
				self.achievements = []
			}

			self.nextPageCursor = response.nextCursor
			self.achievements.append(contentsOf: response.data)
			self.achievements.removeDuplicates()
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.achievements.lowercased(with: Locale.current)))
		#endif
	}
}

// MARK: - SectionLayoutKind
extension UserAchievementsCollectionViewController {
	/// List of section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
