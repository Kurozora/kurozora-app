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
	var feedMessageID: Int = 0
	var feedMessage: FeedMessage! {
		didSet {
			self.feedMessageID = feedMessage?.id ?? feedMessageID

			let repliesCount = feedMessage.attributes.metrics.replyCount
			self.title = "\(repliesCount.kkFormatted) replies"

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing message replies...")
			#endif
		}
	}

	// Reply variables
	var feedMessageReplies: [FeedMessage] = [] {
		didSet {
			self.tableView.reloadData {
				self._prefersActivityIndicatorHidden = true
				self.toggleEmptyDataView()
			}

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh message details and replies!")
			#endif
		}
	}
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
	static func `init`(with feedMessageID: Int) -> FMDetailsTableViewController {
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
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(updateFeedMessage(_:)), name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteFeedMessage(_:)), name: .KFMDidDelete, object: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh message details and replies!")
		#endif

		DispatchQueue.global(qos: .userInteractive).async {
			if self.feedMessage == nil {
				self.fetchDetails()
			} else {
				self.fetchFeedReplies()
			}
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self, name: .KFMDidUpdate, object: nil)
		NotificationCenter.default.removeObserver(self, name: .KFMDidDelete, object: nil)
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.nextPageURL = nil
		self.fetchDetails()
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
	func fetchDetails() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing message details...")
			#endif
		}

		KService.getDetails(forFeedMessage: self.feedMessageID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let feedMessages):
				DispatchQueue.main.async {
					self.feedMessage = feedMessages.first
					self.tableView.reloadData()
				}
			case .failure: break
			}
		}

		self.fetchFeedReplies()
	}

	/// Fetch the feed message replies.
	func fetchFeedReplies() {
		KService.getReplies(forFeedMessage: self.feedMessageID, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let feedMessageResponse):
				DispatchQueue.main.async {
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.feedMessageReplies = []
					}

					// Save next page url and append new data
					self.nextPageURL = feedMessageResponse.next
					self.feedMessageReplies.append(contentsOf: feedMessageResponse.data)
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.fmDetailsTableViewController.feedMessageDetailsSegue.identifier {
			// Show detail for explore cell
			if let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController {
				if let feedMessageID = sender as? Int {
					fmDetailsTableViewController.feedMessageID = feedMessageID
					fmDetailsTableViewController.fmDetailsTableViewControllerDelegate = self
				}
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
			feedMessageCell.feedMessage = feedMessage
			return feedMessageCell
		default:
			guard let feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.feedMessageCell.identifier)")
			}
			feedMessageCell.delegate = self
			feedMessageCell.liveReplyEnabled = false
			feedMessageCell.liveReShareEnabled = false
			feedMessageCell.feedMessage = feedMessageReplies[indexPath.row]
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

	func baseFeedMessageCell(_ cell: BaseFeedMessageCell, didPressMoreButton button: UIButton) {
		if let indexPath = self.tableView.indexPath(for: cell) {
			switch indexPath.section {
			case 0:
				self.feedMessage.actionList(on: self, button, userInfo: [
					"indexPath": indexPath,
					"liveReplyEnabled": cell.liveReplyEnabled,
					"liveReShareEnabled": cell.liveReShareEnabled
				])
			default:
				self.feedMessageReplies[indexPath.row].actionList(on: self, button, userInfo: [
					"indexPath": indexPath,
					"liveReplyEnabled": cell.liveReplyEnabled,
					"liveReShareEnabled": cell.liveReShareEnabled
				])
			}
		}
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
	func fmDetailsTableViewController(delete messageID: Int) {
		self.feedMessageReplies.removeFirst { feedMessageReply in
			feedMessageReply.id == messageID
		}
	}
}
