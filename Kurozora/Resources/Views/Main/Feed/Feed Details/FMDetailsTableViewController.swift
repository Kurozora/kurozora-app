//
//  FMDetailsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FMDetailsTableViewController: KTableViewController, StoryboardInstantiable {
	static var storyboardName: String = "Feed"

	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case feedMessageDetailsSegue
	}

	// MARK: - Properties
	var feedMessageID: KurozoraItemID = ""
	var feedMessage: FeedMessage! {
		didSet {
			self.feedMessageID = feedMessage?.id ?? ""

			let repliesCount = feedMessage.attributes.metrics.replyCount
			self.title = "\(repliesCount.kkFormatted(precision: 0)) replies"

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing message replies...")
			#endif
		}
	}

	// Reply variables
	var feedMessageReplies: [FeedMessage] = []

	// Delegates
	weak var fmDetailsTableViewControllerDelegate: FMDetailsTableViewControllerDelegate?

	/// The next page url of the pagination.
	var nextPageURL: String?

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	/// Initialize a new instance of FMDetailsTableViewController with the given feed message id.
	///
	/// - Parameter feedMessageID: The feed message id to use when initializing the view.
	///
	/// - Returns: an initialized instance of FMDetailsTableViewController.
	func callAsFunction(with feedMessageID: KurozoraItemID) -> FMDetailsTableViewController {
		let fmDetailsTableViewController = FMDetailsTableViewController.instantiate()
		fmDetailsTableViewController.feedMessageID = feedMessageID
		return fmDetailsTableViewController
	}

	/// Initialize a new instance of FMDetailsTableViewController with the given feed message object.
	///
	/// - Parameter user: The `FeedMessage` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of FMDetailsTableViewController.
	func callAsFunction(with feedMessage: FeedMessage) -> FMDetailsTableViewController {
		let fmDetailsTableViewController = FMDetailsTableViewController.instantiate()
		fmDetailsTableViewController.feedMessage = feedMessage
		return fmDetailsTableViewController
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh message details and replies!")
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
		NotificationCenter.default.addObserver(self, selector: #selector(updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KFMDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil

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
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh message details and replies!")
		#endif
	}

	/// Fetch feed message details.
	func fetchDetails() async {
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing message details...")
		#endif

		do {
            let feedMessageIdentity = FeedMessageIdentity(id: self.feedMessageID)
			let feedMessageResponse = try await KService.getDetails(forFeedMessage: feedMessageIdentity).value

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
			let feedMessageResponse = try await KService.getReplies(forFeedMessage: feedMessageIdentity, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.feedMessageReplies = []
			}

			// Save next page url and append new data
			self.nextPageURL = feedMessageResponse.next
			self.feedMessageReplies.append(contentsOf: feedMessageResponse.data)
		} catch {
			print(error.localizedDescription)
		}

		self.endFetch()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard
			let segueIdentifier = segue.identifier,
			let segueID = SegueIdentifiers(rawValue: segueIdentifier)
		else { return }

		switch segueID {
		case .feedMessageDetailsSegue:
			// Show detail for explore cell
			guard
				let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController,
				let feedMessageID = sender as? KurozoraItemID
			else { return }
			fmDetailsTableViewController.feedMessageID = feedMessageID
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
			return feedMessageReplies.count
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			let feedMessageCell: BaseFeedMessageCell!
			if self.feedMessage.attributes.isReShare {
				feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageReShareCell.self, for: indexPath)
			} else {
				feedMessageCell = tableView.dequeueReusableCell(withIdentifier: FeedMessageCell.self, for: indexPath)
			}
			feedMessageCell.delegate = self
			feedMessageCell.liveReplyEnabled = true
			feedMessageCell.liveReShareEnabled = false
			feedMessageCell.configureCell(using: self.feedMessage, isOnProfile: false)
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
			feedMessageCell.delegate = self
			feedMessageCell.liveReplyEnabled = false
			feedMessageCell.liveReShareEnabled = false
			feedMessageCell.configureCell(using: self.feedMessageReplies[indexPath.row], isOnProfile: false)
			feedMessageCell.moreButton.menu = self.feedMessageReplies[indexPath.row].makeContextMenu(in: self, userInfo: [
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

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReShareButton button: UIButton) async {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				await self.feedMessage.reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
			default:
				await self.feedMessageReplies[indexPath.row].reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
			}
		}
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
		let badgeViewController = BadgeViewController.instantiate()
		badgeViewController.profileBadge = profileBadge
		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) async {
		self.feedMessage.relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) async {
		guard let feedMessage = self.feedMessage.relationships.parent?.data.first else { return }
		self.performSegue(withIdentifier: SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage.id)
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
		self.performSegue(withIdentifier: SegueIdentifiers.feedMessageDetailsSegue, sender: feedMessage.id)
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
