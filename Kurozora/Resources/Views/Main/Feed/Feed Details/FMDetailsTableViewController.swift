//
//  FMDetailsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FMDetailsTableViewController: KTableViewController {
	// MARK: - Properties
	var feedMessageID: String = ""
	var feedMessage: FeedMessage! {
		didSet {
			self.feedMessageID = feedMessage?.id ?? ""

			let repliesCount = feedMessage.attributes.metrics.replyCount
			self.title = "\(repliesCount.kkFormatted) replies"

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing message replies...")
			#endif
		}
	}

	// Reply variables
	var feedMessageReplies: [FeedMessage] = []
	var nextPageURL: String?

	// Delegates
	weak var fmDetailsTableViewControllerDelegate: FMDetailsTableViewControllerDelegate?

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
	static func `init`(with feedMessageID: String) -> FMDetailsTableViewController {
		if let fmDetailsTableViewController = R.storyboard.feed.fmDetailsTableViewController() {
			fmDetailsTableViewController.feedMessageID = feedMessageID
			return fmDetailsTableViewController
		}

		fatalError("Failed to instantiate FMDetailsTableViewController with the given feed message id.")
	}

	/// Initialize a new instance of FMDetailsTableViewController with the given feed message object.
	///
	/// - Parameter user: The `FeedMessage` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of FMDetailsTableViewController.
	static func `init`(with feedMessage: FeedMessage) -> FMDetailsTableViewController {
		if let fmDetailsTableViewController = R.storyboard.feed.fmDetailsTableViewController() {
			fmDetailsTableViewController.feedMessage = feedMessage
			return fmDetailsTableViewController
		}

		fatalError("Failed to instantiate FMDetailsTableViewController with the given FeedMessage object.")
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
		// TODO: - HERE: Look at this
//		let verticalOffset = (self.tableView.tableHeaderView?.height ?? 0 - self.view.height) / 2

		emptyBackgroundView.configureImageView(image: R.image.empty.comment()!)
		emptyBackgroundView.configureLabels(title: "No Replies", detail: "Be the first to reply to this message!")

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfRows() <= 1 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/// Updates the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func updateFeedMessage(_ notification: NSNotification) {
		// Start update process
		self.tableView.performBatchUpdates({
			if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
				self.tableView.reloadRows(at: [indexPath], with: .none)
			}
		}, completion: nil)
	}

	/// Deletes the feed message with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc func deleteFeedMessage(_ notification: NSNotification) {
		if let indexPath = notification.userInfo?["indexPath"] as? IndexPath {
			switch indexPath.section {
			case 1:
				// Start delete process
				self.tableView.performBatchUpdates({
					self.feedMessageReplies.remove(at: indexPath.item)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
				}, completion: nil)
			default:
				self.fmDetailsTableViewControllerDelegate?.fmDetailsTableViewController(delete: feedMessageID)
				self.navigationController?.popViewController(animated: true, nil)
			}
		}
	}

	/// Fetch feed message details.
	func fetchDetails() async {
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing message details...")
		#endif

		do {
			let feedMessageResponse = try await KService.getDetails(forFeedMessage: self.feedMessageID).value

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
			let feedMessageResponse = try await KService.getReplies(forFeedMessage: self.feedMessageID, next: self.nextPageURL).value

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

		self.tableView.reloadData {
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh message details and replies!")
		#endif
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.fmDetailsTableViewController.feedMessageDetailsSegue.identifier {
			// Show detail for explore cell
			if let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController {
				guard let feedMessageID = sender as? String else { return }
				fmDetailsTableViewController.feedMessageID = feedMessageID
				fmDetailsTableViewController.fmDetailsTableViewControllerDelegate = self
			}
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
				feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageReShareCell, for: indexPath)
			} else {
				feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath)
			}
			feedMessageCell.delegate = self
			feedMessageCell.liveReplyEnabled = true
			feedMessageCell.liveReShareEnabled = false
			feedMessageCell.configureCell(using: self.feedMessage)
			feedMessageCell.moreButton.menu = self.feedMessage.makeContextMenu(in: self, userInfo: [
				"indexPath": indexPath,
				"liveReplyEnabled": feedMessageCell.liveReplyEnabled,
				"liveReShareEnabled": feedMessageCell.liveReShareEnabled
			])
			return feedMessageCell
		default:
			guard let feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.feedMessageCell.identifier)")
			}
			feedMessageCell.delegate = self
			feedMessageCell.liveReplyEnabled = false
			feedMessageCell.liveReShareEnabled = false
			feedMessageCell.configureCell(using: self.feedMessageReplies[indexPath.row])
			feedMessageCell.moreButton.menu = self.feedMessageReplies[indexPath.row].makeContextMenu(in: self, userInfo: [
				"indexPath": indexPath,
				"liveReplyEnabled": feedMessageCell.liveReplyEnabled,
				"liveReShareEnabled": feedMessageCell.liveReShareEnabled
			])
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
	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressHeartButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				self.feedMessage.heartMessage(via: self, userInfo: ["indexPath": indexPath])
			default:
				self.feedMessageReplies[indexPath.row].heartMessage(via: self, userInfo: ["indexPath": indexPath])
			}
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReplyButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				self.feedMessage.replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
			default:
				self.feedMessageReplies[indexPath.row].replyToMessage(via: self, userInfo: ["liveReplyEnabled": cell.liveReplyEnabled])
			}
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressReShareButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				self.feedMessage.reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
			default:
				self.feedMessageReplies[indexPath.row].reShareMessage(via: self, userInfo: ["liveReShareEnabled": cell.liveReShareEnabled])
			}
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressUserName sender: AnyObject) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				self.feedMessage.visitOriginalPosterProfile(from: self)
			default:
				self.feedMessageReplies[indexPath.row].visitOriginalPosterProfile(from: self)
			}
		}
	}

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressProfileBadge button: UIButton, for profileBadge: ProfileBadge) {
		if let badgeViewController = R.storyboard.badge.instantiateInitialViewController() {
			badgeViewController.profileBadge = profileBadge

			#if targetEnvironment(macCatalyst)
			#else
			if #available(iOS 16.0, *) {
				badgeViewController.sheetPresentationController?.detents = [.custom(resolver: { _ in
					return badgeViewController.preferredContentSize.height
				})]
			} else {
				badgeViewController.sheetPresentationController?.detents = [.medium()]
			}
			#endif

			badgeViewController.popoverPresentationController?.sourceView = button
			badgeViewController.popoverPresentationController?.sourceRect = button.bounds
			badgeViewController.sheetPresentationController?.prefersGrabberVisible = true

			self.present(badgeViewController, animated: true, completion: nil)
		}
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressUserName sender: AnyObject) {
		self.feedMessage.relationships.parent?.data.first?.visitOriginalPosterProfile(from: self)
	}

	func feedMessageReShareCell(_ cell: FeedMessageReShareCell, didPressOPMessage sender: AnyObject) {
		self.performSegue(withIdentifier: R.segue.fmDetailsTableViewController.feedMessageDetailsSegue.identifier, sender: self.feedMessage.relationships.parent?.data.first?.id)
	}
}

// MARK: - KRichTextEditorViewDelegate
extension FMDetailsTableViewController: KFeedMessageTextEditorViewDelegate {
	func kFeedMessageTextEditorView(updateMessagesWith feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessageReplies.prepend(feedMessage)
		}
		self.tableView.reloadSections([1], with: .automatic)
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.performSegue(withIdentifier: R.segue.fmDetailsTableViewController.feedMessageDetailsSegue.identifier, sender: feedMessage.id)
	}
}

// MARK: - FMDetailsTableViewControllerDelegate
extension FMDetailsTableViewController: FMDetailsTableViewControllerDelegate {
	func fmDetailsTableViewController(delete messageID: String) {
		self.feedMessageReplies.removeFirst { feedMessageReply in
			feedMessageReply.id == String(messageID)
		}
	}
}
