//
//  FMDetailsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Kingfisher
import KurozoraKit
import UIKit

class FMDetailsTableViewController: KTableViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case feedMessageDetailsSegue
	}

	// MARK: - Properties
	private var pendingLayoutUpdate: DispatchWorkItem?
	var heightCache: [IndexPath: CGFloat] = [:]
	private var expandedMessageIDs: Set<KurozoraItemID> = []
	private var expandedOPIDs: Set<KurozoraItemID> = []

	var feedMessageID: KurozoraItemID = ""
	var feedMessage: FeedMessage! {
		didSet {
			self.feedMessageID = self.feedMessage?.id ?? ""

			let repliesCount = self.feedMessage.attributes.metrics.replyCount
			self.title = "\(repliesCount.kkFormatted(precision: 0)) replies"

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingMessageReplies)
			#endif
		}
	}

	// Reply variables
	var feedMessageReplies: [FeedMessage] = []

	// Delegates
	weak var fmDetailsTableViewControllerDelegate: FMDetailsTableViewControllerDelegate?

	/// The next page url of the pagination.
	var nextPageCursor: PageCursor?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	/// Initialize a new instance of FMDetailsTableViewController with the given feed message id.
	///
	/// - Parameter feedMessageID: The feed message id to use when initializing the view.
	///
	/// - Returns: an initialized instance of FMDetailsTableViewController.
	func callAsFunction(with feedMessageID: KurozoraItemID) -> FMDetailsTableViewController {
		let fmDetailsTableViewController = FMDetailsTableViewController()
		fmDetailsTableViewController.feedMessageID = feedMessageID
		return fmDetailsTableViewController
	}

	/// Initialize a new instance of FMDetailsTableViewController with the given feed message object.
	///
	/// - Parameter user: The `FeedMessage` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of FMDetailsTableViewController.
	func callAsFunction(with feedMessage: FeedMessage) -> FMDetailsTableViewController {
		let fmDetailsTableViewController = FMDetailsTableViewController()
		fmDetailsTableViewController.feedMessage = feedMessage
		return fmDetailsTableViewController
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshMessageDetails)
		#endif

		Task { [weak self] in
			guard let self = self else { return }

			if self.feedMessage == nil {
				await self.fetchDetails()
			} else {
				await self.fetchFeedReplies()
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KFMDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageCursor = nil
		self.heightCache.removeAll()
		self.expandedMessageIDs.removeAll()
		self.expandedOPIDs.removeAll()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		// TODO: Refactor
//		let verticalOffset = (self.tableView.tableHeaderView?.frame.size.height ?? 0 - self.view.frame.size.height) / 2

		emptyBackgroundView.configureImageView(image: .Empty.comment)
		emptyBackgroundView.configureLabels(title: "No Replies", detail: "Be the first to reply to this message!")

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfRows <= 1 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/// Updates the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateFeedMessage(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			// Start update process
			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				self.tableView.reloadRows(at: [indexPath], with: .none)
			}
		}
	}

	/// Deletes the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteFeedMessage(_ notification: NSNotification) {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }

			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				switch indexPath.section {
				case 1:
					// Start delete process
					self.tableView.performBatchUpdates({
						self.feedMessageReplies.remove(at: indexPath.item)
						self.tableView.deleteRows(at: [indexPath], with: .automatic)
					}, completion: nil)
				default:
					self.fmDetailsTableViewControllerDelegate?.fmDetailsTableViewController(delete: self.feedMessageID)
					self.navigationController?.popViewController(animated: true)
				}
			}
		}
	}

	func endFetch() {
		self.tableView.reloadData {
			self.isRequestInProgress = false
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshMessageDetails)
		#endif
	}

	/// Fetch feed message details.
	func fetchDetails() async {
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingMessageDetails)
		#endif

		do {
			let feedMessageIdentity = FeedMessageIdentity(id: self.feedMessageID)
			let feedMessageResponse = try await KService.feedMessageDetail(feedMessageIdentity).response()

			self.feedMessage = feedMessageResponse.data.first
		} catch {
			print(error.localizedDescription)
		}

		self.tableView.reloadData()

		await self.fetchFeedReplies()
	}

	/// Fetch the feed message replies.
	@MainActor
	func fetchFeedReplies() async {
		do {
			let feedMessageIdentity = FeedMessageIdentity(id: self.feedMessageID)
			let feedMessageResponse = try await KService.replies(forFeedMessage: feedMessageIdentity).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

			// Reset data if necessary
			if self.nextPageCursor == nil {
				self.feedMessageReplies = []
			}

			// Save next page url and append new data
			self.nextPageCursor = feedMessageResponse.nextCursor
			self.feedMessageReplies.append(contentsOf: feedMessageResponse.data)
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .feedMessageDetailsSegue: return FMDetailsTableViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .feedMessageDetailsSegue:
			// Segue to feed message details
			guard
				let fmDetailsTableViewController = destination as? FMDetailsTableViewController,
				let feedMessage = sender as? FeedMessage
			else { return }
			fmDetailsTableViewController.feedMessageID = feedMessage.id
			fmDetailsTableViewController.fmDetailsTableViewControllerDelegate = self
		}
	}
}

// MARK: - UITableViewDataSource
extension FMDetailsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return self.feedMessage != nil ? 1 : 0
		default:
			return self.feedMessageReplies.count
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			let feedMessageCell: BaseFeedMessageCell!
			let isSimpleReShare = self.feedMessage.attributes.isReShare && self.feedMessage.attributes.content.isEmpty
			let isQuoteReShare = self.feedMessage.attributes.isReShare && !self.feedMessage.attributes.content.isEmpty

			if isQuoteReShare {
				feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageReShareCell.self, for: indexPath)
			} else {
				feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageCell.self, for: indexPath)
			}
			feedMessageCell.delegate = self
			feedMessageCell.liveReplyEnabled = true
			feedMessageCell.liveReShareEnabled = false

			if let reShareCell = feedMessageCell as? FeedMessageReShareCell {
				let parentID = self.feedMessage.relationships.parent?.data.first?.id
				let isOPExpanded = parentID.map { self.expandedOPIDs.contains($0) } ?? false
				reShareCell.configureCell(using: self.feedMessage, isOnProfile: false, isExpanded: true, isOPExpanded: isOPExpanded)
			} else if isSimpleReShare {
				let parent = self.feedMessage.relationships.parent?.data.first ?? self.feedMessage
				let resharer = self.feedMessage.relationships.users.data.first
				feedMessageCell.configureCell(using: parent, isOnProfile: false, isExpanded: true, attributedTo: resharer)
			} else {
				feedMessageCell.configureCell(using: self.feedMessage, isOnProfile: false, isExpanded: true)
			}

			feedMessageCell.moreButton.menu = self.feedMessage.makeContextMenu(in: self, userInfo: [
				"indexPath": indexPath,
				"liveReplyEnabled": feedMessageCell.liveReplyEnabled,
				"liveReShareEnabled": feedMessageCell.liveReShareEnabled
			], sourceView: feedMessageCell.moreButton, barButtonItem: nil)
			return feedMessageCell
		default:
			guard let feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageCell.self, for: indexPath) else {
				fatalError("Cannot dequeue reusable cell with identifier \(FeedMessageCell.reuseID)")
			}
			let reply = self.feedMessageReplies[indexPath.row]
			feedMessageCell.delegate = self
			feedMessageCell.liveReplyEnabled = false
			feedMessageCell.liveReShareEnabled = false
			feedMessageCell.configureCell(using: reply, isOnProfile: false, isExpanded: self.expandedMessageIDs.contains(reply.id))
			feedMessageCell.moreButton.menu = reply.makeContextMenu(in: self, userInfo: [
				"indexPath": indexPath,
				"liveReplyEnabled": feedMessageCell.liveReplyEnabled,
				"liveReShareEnabled": feedMessageCell.liveReShareEnabled
			], sourceView: feedMessageCell.moreButton, barButtonItem: nil)
			return feedMessageCell
		}
	}
}

// MARK: - KTableViewDataSource
extension FMDetailsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			FeedMessageCell.self,
			FeedMessageReShareCell.self
		]
	}
}

// MARK: - UITableViewDataSourcePrefetching
extension FMDetailsTableViewController {
	override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		var imageURLs: [URL] = []

		for indexPath in indexPaths {
			switch indexPath.section {
			case 0:
				self.feedMessage?.collectPrefetchURLs(into: &imageURLs)
			default:
				self.feedMessageReplies[safe: indexPath.row]?.collectPrefetchURLs(into: &imageURLs)
			}
		}

		if !imageURLs.isEmpty {
			ImagePrefetcher(urls: imageURLs).start()
		}
	}
}

// MARK: - BaseFeedMessageCellDelegate
extension FMDetailsTableViewController: BaseFeedMessageCellDelegate {
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				await self.feedMessage.heartMessage(via: self, userInfo: ["indexPath": indexPath])
			default:
				await self.feedMessageReplies[indexPath.row].heartMessage(via: self, userInfo: ["indexPath": indexPath])
			}
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				await self.feedMessage.replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
			default:
				await self.feedMessageReplies[indexPath.row].replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
			}
		}
	}

	func baseFeedMessageCellReShareMenu(_ cell: BaseFeedMessageCell) -> UIMenu? {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return nil }
		let feedMessage: FeedMessage = indexPath.section == 0
			? self.feedMessage
			: self.feedMessageReplies[indexPath.row]
		return feedMessage.reShareMenu(in: self, userInfo: [
			"indexPath": indexPath,
			"liveReShareEnabled": cell.liveReShareEnabled
		])
	}

	func baseFeedMessageCellDidTapAttribution(_ cell: BaseFeedMessageCell) {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		let envelope: FeedMessage = indexPath.section == 0
			? self.feedMessage
			: self.feedMessageReplies[indexPath.row]

		guard let resharer = envelope.relationships.users.data.first else { return }
		let profileTableViewController = ProfileTableViewController()(with: resharer)
		self.show(profileTableViewController, sender: nil)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				self.feedMessage.visitOriginalPosterProfile(from: self)
			default:
				self.feedMessageReplies[indexPath.row].visitOriginalPosterProfile(from: self)
			}
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) async {
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didUpdateContentLayout sender: AnyObject) {
		self.pendingLayoutUpdate?.cancel()
		let work = DispatchWorkItem { [weak self] in
			guard let self else { return }
			self.tableView.performBatchUpdates(nil)
		}
		self.pendingLayoutUpdate = work
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: work)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMore sender: AnyObject) {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		guard indexPath.section == 1 else { return }

		let id = self.feedMessageReplies[indexPath.row].id
		self.expandedMessageIDs.insert(id)
		self.heightCache.removeValue(forKey: indexPath)
		self.tableView.reloadRows(at: [indexPath], with: .none)
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didTapShowMoreOnOP sender: AnyObject) {
		guard let indexPath = self.tableView.indexPath(for: cell) else { return }
		let parentID: KurozoraItemID?

		switch indexPath.section {
		case 0:
			parentID = self.feedMessage.relationships.parent?.data.first?.id
		default:
			parentID = self.feedMessageReplies[indexPath.row].relationships.parent?.data.first?.id
		}

		guard let parentID = parentID else { return }
		self.expandedOPIDs.insert(parentID)
		self.heightCache.removeValue(forKey: indexPath)
		self.tableView.reloadRows(at: [indexPath], with: .none)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		self.feedMessage.relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let feedMessage = self.feedMessage.relationships.parent?.data.first else { return }
		self.show(.feedMessageDetailsSegue, sender: feedMessage)
	}
}

// MARK: - KRichTextEditorViewDelegate
extension FMDetailsTableViewController: KFeedMessageTextEditorViewDelegate {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessageReplies.insert(feedMessage, at: 0)
		}
		self.tableView.reloadSections([1], with: .automatic)
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.show(.feedMessageDetailsSegue, sender: feedMessage)
	}
}

// MARK: - FMDetailsTableViewControllerDelegate
extension FMDetailsTableViewController: FMDetailsTableViewControllerDelegate {
	func fmDetailsTableViewController(delete messageID: KurozoraItemID) {
		self.feedMessageReplies.removeFirst { feedMessageReply in
			feedMessageReply.id == messageID
		}
	}
}
