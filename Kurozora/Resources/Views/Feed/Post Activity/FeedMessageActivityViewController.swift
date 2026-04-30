//
//  FeedMessageActivityViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Tabman
import UIKit

final class FeedMessageActivityViewController: KTabbedViewController {
	// MARK: - Properties
	/// The feed message whose activity is being shown.
	private let feedMessage: FeedMessage

	/// The currently selected sort.
	private var currentSort: ReSharesSortType = .default

	/// Cached child view controllers.
	private var quotesViewController: FeedMessageQuotesViewController?
	private var reSharesViewController: FeedMessageReSharesViewController?

	// MARK: - Initializers
	init(feedMessage: FeedMessage) {
		self.feedMessage = feedMessage
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.postActivity
		self.navigationItem.largeTitleDisplayMode = .never
		self.configureSortMenu()
		self.repositionTabBarToTop()
	}

	// MARK: - Functions
	private func repositionTabBarToTop() {
		self.removeBar(self.bar)
		self.bottomBarView.isHidden = true

		self.bar.layout.contentMode = .intrinsic
		self.bar.layout.alignment = .centerDistributed
		self.bar.layout.contentInset = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)

		self.addBar(self.bar, dataSource: self, at: .top)
	}

	private func configureSortMenu() {
		let sortButton = UIBarButtonItem(
			image: UIImage(systemName: "arrow.up.arrow.down.circle"),
			style: .plain,
			target: nil,
			action: nil
		)
		sortButton.menu = self.makeSortMenu()
		self.navigationItem.rightBarButtonItem = sortButton
	}

	private func makeSortMenu() -> UIMenu {
		let topAction = UIAction(
			title: L10n.top,
			image: UIImage(systemName: "flame"),
			state: self.currentSort == .top ? .on : .off
		) { [weak self] _ in
			self?.applySort(.top)
		}

		let recentAction = UIAction(
			title: L10n.recent,
			image: UIImage(systemName: "clock"),
			state: self.currentSort == .recent ? .on : .off
		) { [weak self] _ in
			self?.applySort(.recent)
		}

		return UIMenu(title: L10n.sort, children: [topAction, recentAction])
	}

	private func applySort(_ sort: ReSharesSortType) {
		guard self.currentSort != sort else { return }
		self.currentSort = sort
		self.navigationItem.rightBarButtonItem?.menu = self.makeSortMenu()

		NotificationCenter.default.post(
			name: .KFMActivitySortDidChange,
			object: nil,
			userInfo: ["sort": sort]
		)
	}

	// MARK: - KTabbedViewControllerDataSource
	override func initializeViewControllers(with count: Int) -> [UIViewController] {
		let quotes = FeedMessageQuotesViewController(feedMessage: self.feedMessage, sort: self.currentSort)
		let reShares = FeedMessageReSharesViewController(feedMessage: self.feedMessage, sort: self.currentSort)

		self.quotesViewController = quotes
		self.reSharesViewController = reShares

		return [quotes, reShares]
	}

	// MARK: - TMBarDataSource
	override func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		switch index {
		case 0: return TMBarItem(title: L10n.quotes)
		case 1: return TMBarItem(title: L10n.reShares)
		default: return TMBarItem(title: "")
		}
	}
}
