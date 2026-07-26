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
	/// Fetches the library entries for the current user from the local store and applies them to the data source.
	func fetchLibrary() async {
		guard self.viewedUser != nil else {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.entries.removeAll()
				self.collectionView.reloadData {
					self.toggleEmptyDataView()
				}
			}

			return
		}

		let libraryStatus: String

		switch self.libraryKind {
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

		self.fetchLibraryFromLocalStore()

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

	/// Re-reads the currently-loaded window from the local store in its canonical sort order.
	///
	/// Used after an in-place data change that could have moved an entry's sort position, so
	/// the applied snapshot stays identical to `LibraryStore`'s current ordering without
	/// resetting how many entries are loaded.
	func resyncEntriesFromStore() {
		guard let slug = User.current?.attributes.slug, !self.entries.isEmpty else { return }

		self.entries = LibraryStore.shared.entries(
			forUserSlug: slug,
			kind: self.libraryKind,
			status: self.libraryStatus,
			sortType: self.librarySortType,
			sortOption: self.librarySortTypeOption,
			offset: 0,
			limit: self.entries.count
		)
		self.updateDataSource()
	}

	/// Reads a page of library entries from the local store and appends them to ``entries``.
	private func fetchLibraryFromLocalStore() {
		guard let slug = User.current?.attributes.slug else { return }

		let isFirstPage = self.entries.isEmpty
		let pageSize = isFirstPage ? 25 : 100
		let offset = self.entries.count

		let page = LibraryStore.shared.entries(
			forUserSlug: slug,
			kind: self.libraryKind,
			status: self.libraryStatus,
			sortType: self.librarySortType,
			sortOption: self.librarySortTypeOption,
			offset: offset,
			limit: pageSize
		)
		let total = LibraryStore.shared.count(forUserSlug: slug, kind: self.libraryKind, status: self.libraryStatus)
		self.totalLibraryItemsCount = total

		if self.isPageVisible {
			self.delegate?.libraryListViewController(updateTotalCount: total)
		}

		if isFirstPage {
			self.entries = page
		} else {
			self.entries.append(contentsOf: page)
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

		switch self.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
			titleString = L10n.noItemsTitle(L10n.shows)
			subtitleString = if self.viewedUser == User.current {
				L10n.addItemToList(L10n.show.lowercased(with: .current), libraryStatus.lowercased())
			} else {
				L10n.userHasNoInList(self.viewedUser?.attributes.username ?? "", L10n.shows.lowercased(with: .current), libraryStatus.lowercased())
			}
			image = .Empty.animeLibrary
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
			titleString = L10n.noItemsTitle(L10n.literatures)
			subtitleString = if self.viewedUser == User.current {
				L10n.addItemToList(L10n.literature.lowercased(with: .current), libraryStatus.lowercased())
			} else {
				L10n.userHasNoInList(self.viewedUser?.attributes.username ?? "", L10n.literatures.lowercased(with: .current), libraryStatus.lowercased())
			}
			image = .Empty.mangaLibrary
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
			titleString = L10n.noItemsTitle(L10n.games)
			subtitleString = if self.viewedUser == User.current {
				L10n.addItemToList(L10n.game.lowercased(with: .current), libraryStatus.lowercased())
			} else {
				L10n.userHasNoInList(self.viewedUser?.attributes.username ?? "", L10n.games.lowercased(with: .current), libraryStatus.lowercased())
			}
			image = .Empty.gameLibrary
		}

		if self.viewedUser == nil {
			subtitleString = L10n.librarySignedOutDetail
			buttonTitle = L10n.signIn
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
