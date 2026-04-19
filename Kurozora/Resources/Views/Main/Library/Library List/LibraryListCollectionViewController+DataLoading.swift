//
//  LibraryListCollectionViewController+DataLoading.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LibraryListCollectionViewController {
	/// Fetches the library items for the current user and applies them to the data source.
	func fetchLibrary() async {
		guard let user = self.viewedUser else {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.shows.removeAll()
				self.literatures.removeAll()
				self.games.removeAll()
				self.collectionView.reloadData {
					self.toggleEmptyDataView()
				}
			}

			return
		}

		let libraryStatus: String

		switch UserSettings.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.collectionView.backgroundView?.alpha = 0

			self._prefersActivityIndicatorHidden = false

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingLibrary(libraryStatus.lowercased()))
			#endif
		}

		let userIdentity = UserIdentity(id: user.id)

		do {
			let libraryResponse = try await KService.getLibrary(
				forUser: userIdentity,
				libraryKind: UserSettings.libraryKind,
				withLibraryStatus: self.libraryStatus,
				withSortType: self.librarySortType,
				withSortOption: self.librarySortTypeOption,
				next: self.nextPageURL,
				limit: self.nextPageURL != nil ? 100 : 25
			)

			self.totalLibraryItemsCount = libraryResponse.total ?? 0
			self.delegate?.libraryListViewController(updateTotalCount: self.totalLibraryItemsCount)

			if self.nextPageURL == nil {
				switch UserSettings.libraryKind {
				case .shows:
					self.shows = []
				case .literatures:
					self.literatures = []
				case .games:
					self.games = []
				}
			}

			self.nextPageURL = libraryResponse.next
			if let shows = libraryResponse.data.shows {
				self.shows.appendDistinct(contentsOf: shows)
			}
			if let literatures = libraryResponse.data.literatures {
				self.literatures.appendDistinct(contentsOf: literatures)
			}
			if let games = libraryResponse.data.games {
				self.games.appendDistinct(contentsOf: games)
			}
		} catch {
			print(error.localizedDescription)
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshLibrary(libraryStatus.lowercased()))
		#endif
	}

	/// Refetches the library in response to an "AddTo<Status>Section" notification.
	///
	/// - Parameter notification: The broadcast notification that triggered the refetch.
	@objc func addToLibrary(_ notification: NSNotification) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchLibrary()
		}
	}

	/// Refetches the library in response to a "RemoveFrom<Status>Section" notification.
	///
	/// - Parameter notification: The broadcast notification that triggered the refetch.
	@objc func removeFromLibrary(_ notification: NSNotification) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchLibrary()
		}
	}
}

// MARK: - Empty Data View
extension LibraryListCollectionViewController {
	/// Fades the empty-data view in or out based on whether the collection has any items.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 || self.viewedUser == nil {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Populates the empty-data view with a title, detail and optional sign-in action
	/// appropriate to the current library kind and signed-in state.
	override func configureEmptyDataView() {
		let titleString: String
		var subtitleString: String
		let image: UIImage
		let buttonTitle: String
		let buttonAction: (() -> Void)?
		let libraryStatus: String

		switch UserSettings.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
			titleString = "No Shows"
			subtitleString = if self.viewedUser == User.current {
				"Add a show to your \(libraryStatus.lowercased()) list and it will show up here."
			} else {
				"\(self.viewedUser?.attributes.username ?? "") has no shows in their \(libraryStatus.lowercased()) list."
			}
			image = .Empty.animeLibrary
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
			titleString = "No Literatures"
			subtitleString = if self.viewedUser == User.current {
				"Add a literature to your \(libraryStatus.lowercased()) list and it will show up here."
			} else {
				"\(self.viewedUser?.attributes.username ?? "") has no literatures in their \(libraryStatus.lowercased()) list."
			}
			image = .Empty.mangaLibrary
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
			titleString = "No Games"
			subtitleString = if self.viewedUser == User.current {
				"Add a game to your \(libraryStatus.lowercased()) list and it will show up here."
			} else {
				"\(self.viewedUser?.attributes.username ?? "") has no games in their \(libraryStatus.lowercased()) list."
			}
			image = .Empty.gameLibrary
		}

		if self.viewedUser == nil {
			subtitleString = "Library is currently available to registered Kurozora users only."
			buttonTitle = "Sign In"
			buttonAction = {
				let signInTableViewController = SignInTableViewController()
				let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
				self.present(kNavigationController, animated: true)
			}
		} else {
			buttonTitle = ""
			buttonAction = nil
		}

		self.emptyBackgroundView.configureImageView(image: image)
		self.emptyBackgroundView.configureLabels(title: titleString, detail: subtitleString)
		self.emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Enables or disables the pull-to-refresh control based on the signed-in state.
	func enableRefreshControl() {
		self._prefersRefreshControlDisabled = self.viewedUser == nil
	}
}
