//
//  FeedMessageQuotesViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

final class FeedMessageQuotesViewController: KTableViewController {
	// MARK: - Properties
	private let feedMessage: FeedMessage
	private var sort: ReSharesSortType
	private var quotes: [FeedMessage] = []
	private var nextPageCursor: PageCursor?
	private var isRequestInProgress = false
	private var hasFetched = false

	private var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	init(feedMessage: FeedMessage, sort: ReSharesSortType) {
		self.feedMessage = feedMessage
		self.sort = sort
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		Task { [weak self] in
		 	await self?.fetch()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.sortDidChange(_:)), name: .KFMActivitySortDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.feedMessageDidUpdate(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.feedMessageDidDelete(_:)), name: .KFMDidDelete, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.feedMessageTranslationDidUpdate(_:)), name: .KTranslationDidUpdate, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageCursor = nil
		Task { [weak self] in
			await self?.fetch()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: .Empty.message2)
		emptyBackgroundView.configureLabels(title: L10n.noQuotesHeadline, detail: L10n.noQuotesSubheadline)
		emptyBackgroundView.configureButton(title: L10n.quote) { [weak self] in
			guard let self = self else { return }

			Task { @MainActor in
				await self.feedMessage.quoteMessage(via: self, userInfo: nil)
			}
		}
		tableView.backgroundView?.alpha = 0
	}

	@objc private func sortDidChange(_ notification: Notification) {
		guard let newSort = notification.userInfo?["sort"] as? ReSharesSortType else { return }
		guard newSort != self.sort else { return }

		self.sort = newSort
		self.nextPageCursor = nil

		Task { [weak self] in
			await self?.fetch()
		}
	}

	@objc private func feedMessageDidUpdate(_ notification: Notification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}

	@objc private func feedMessageDidDelete(_ notification: Notification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}

	@objc private func feedMessageTranslationDidUpdate(_ notification: Notification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
	}

	private func fetch() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		do {
			let identity = FeedMessageIdentity(id: self.feedMessage.id)
			let response = try await KService.quotes(forFeedMessage: identity)
				.cursor(self.nextPageCursor)
				.limit(self.nextPageCursor != nil ? 100 : 25)
				.sort(self.sort)
				.response()

			if self.nextPageCursor == nil {
				self.quotes = []
			}

			self.nextPageCursor = response.nextCursor
			self.quotes.append(contentsOf: response.data)

			// The table's prefetching never covers the first screen, so start the page
			// translating here instead of letting it swap in under the reader.
			if #available(iOS 26.4, macCatalyst 26.4, *) {
				TranslationService.shared.prefetch(response.data)
			}
		} catch {
			print(error.localizedDescription)
		}

		await MainActor.run {
			self.hasFetched = true
			self.isRequestInProgress = false
			self._prefersActivityIndicatorHidden = true
			self.tableView.reloadData()
			self.toggleEmptyDataView()
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	private func toggleEmptyDataView() {
		if self.quotes.isEmpty {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}
}

// MARK: - UITableViewDataSource
extension FeedMessageQuotesViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.quotes.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedMessageReShareCell.self, for: indexPath) else {
			fatalError("Cannot dequeue reusable cell with identifier \(FeedMessageReShareCell.reuseID)")
		}
		let quote = self.quotes[indexPath.row]
		cell.delegate = self
		cell.liveReplyEnabled = false
		cell.liveReShareEnabled = false
		cell.configureCell(using: quote, isOnProfile: false, isExpanded: true, isOPExpanded: false)
		cell.moreButton.menu = quote.makeContextMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReplyEnabled": false,
			"liveReShareEnabled": false
		], sourceView: cell.moreButton, barButtonItem: nil)
		return cell
	}
}

// MARK: - KTableViewDataSource
extension FeedMessageQuotesViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [FeedMessageReShareCell.self]
	}
}

// MARK: - UITableViewDelegate
extension FeedMessageQuotesViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let nearEnd = indexPath.row == self.quotes.count - 1

		if nearEnd, self.nextPageCursor != nil, !self.isRequestInProgress {
			Task { [weak self] in await self?.fetch() }
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		let quote = self.quotes[indexPath.row]
		quote.visitRepliesView(from: self)
	}
}

// MARK: - BaseFeedMessageCellDelegate
extension FeedMessageQuotesViewController: BaseFeedMessageCellDelegate {
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		await self.quotes[indexPath.row].heartMessage(via: self, userInfo: ["indexPath": indexPath])
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		await self.quotes[indexPath.row].replyToMessage(via: self, userInfo: ["liveReplyEnabled": false])
	}

	func baseFeedMessageCellReShareMenu(_ cell: BaseFeedMessageCell) -> UIMenu? {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return nil }
		return self.quotes[indexPath.row].reShareMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReShareEnabled": false
		])
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		self.quotes[indexPath.row].visitOriginalPosterProfile(from: self)
	}

	func baseFeedMessageCellDidTapTranslation(_ cell: BaseFeedMessageCell) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		TranslationService.shared.toggleTranslation(for: self.quotes[indexPath.row])
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapTranslationSettings button: UIButton) {
		guard #available(iOS 26.4, macCatalyst 26.4, *) else { return }
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }

		TranslationSettingsViewController.present(for: self.quotes[indexPath.row], from: button, in: self)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) async {}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didUpdateContentLayout sender: AnyObject) {
		UIView.performWithoutAnimation {
			self.tableView.beginUpdates()
			self.tableView.endUpdates()
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		self.quotes[indexPath.row].visitOriginalPosterProfile(from: self)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard let parent = self.quotes[indexPath.row].relationships.parent?.data.first else { return }
		parent.visitRepliesView(from: self)
	}
}
