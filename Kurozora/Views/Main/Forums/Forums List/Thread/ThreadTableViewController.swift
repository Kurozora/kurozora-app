//
//  ThreadTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ThreadTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var lockImageView: UIImageView!
	@IBOutlet weak var topicLabel: UILabel! {
		didSet {
			self.topicLabel.theme_textColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var voteCountButton: CellActionButton!
	@IBOutlet weak var commentCountButton: CellActionButton!
	@IBOutlet weak var dateTimeButton: CellActionButton!
	@IBOutlet weak var posterUsernameLabel: KButton!
	@IBOutlet weak var threadTitleLabel: KLabel!

	@IBOutlet weak var richTextView: KTextView!
	@IBOutlet weak var upvoteButton: CellActionButton!
	@IBOutlet weak var downvoteButton: CellActionButton!
	@IBOutlet weak var replyButton: CellActionButton!
	@IBOutlet weak var shareButton: CellActionButton!
	@IBOutlet weak var separatorView: SeparatorView!
	@IBOutlet weak var actionsSeparatorView: SecondarySeparatorView!
	@IBOutlet weak var actionsStackView: UIStackView!

	// MARK: - Properties
	var forumThreadID: Int = 0
	var forumsThread: ForumsThread! {
		didSet {
			self.forumThreadID = forumsThread?.id ?? self.forumThreadID
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing thread replies...")
			#endif
		}
	}
	var replyID: Int?
	var newReplyID: Int!
	var threadInformation: String?
	var sectionTitle = "Discussion"

	// Reply variables
	var threadReplies: [ThreadReply] = [] {
		didSet {
			tableView.reloadData {
				self._prefersActivityIndicatorHidden = true
				self.toggleEmptyDataView()
			}

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh thread details!")
			#endif
		}
	}
	var repliesOrder: ForumOrder = .top
	var nextPageURL: String?

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
	/**
		Initialize a new instance of ThreadTableViewController with the given forum thread id.

		- Parameter forumThreadID: The forum thread id to use when initializing the view.

		- Returns: an initialized instance of ThreadTableViewController.
	*/
	static func `init`(with forumThreadID: Int) -> ThreadTableViewController {
		if let threadTableViewController = R.storyboard.thread.threadTableViewController() {
			threadTableViewController.forumThreadID = forumThreadID
			return threadTableViewController
		}

		fatalError("Failed to instantiate ThreadTableViewController with the given forum thread id.")
	}

	/**
	Initialize a new instance of ThreadTableViewController with the given thread object.

	- Parameter forumsThread: The `ForumsThread` object to use when initializing the view controller.

	- Returns: an initialized instance of ThreadTableViewController.
	*/
	static func `init`(with forumsThread: ForumsThread) -> ThreadTableViewController {
		if let threadTableViewController = R.storyboard.thread.threadTableViewController() {
			threadTableViewController.forumsThread = forumsThread
			return threadTableViewController
		}

		fatalError("Failed to instantiate ThreadTableViewController with the given ForumsThread object.")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(updateForumsThread(_:)), name: .KFTDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateReplyCell(_:)), name: .KTRDidUpdate, object: nil)

		// Fetch thread details
		if forumsThread != nil {
			DispatchQueue.main.async {
				self.updateThreadDetails()
			}
		}

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh thread details!")
		#endif

		DispatchQueue.global(qos: .background).async {
			if self.forumsThread == nil {
				self.fetchDetails()
			} else {
				self.fetchThreadReplies()
			}
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard let headerView = tableView.tableHeaderView else { return }

		headerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

		if headerView.frame.size.height != size.height {
			headerView.frame.size.height = size.height

			tableView.tableHeaderView = headerView
			tableView.layoutIfNeeded()
		}
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
		emptyBackgroundView.configureLabels(title: "No Replies", detail: "Be the first to reply on this thread!")

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfSections == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/**
		Updates the forums thread with the received information.

		- Parameter notification: An object containing information broadcast to registered observers.
	*/
	@objc func updateForumsThread(_ notification: NSNotification) {
		self.updateThreadDetails()
	}

	/**
		Updates the replies with the received information.

		- Parameter notification: An object containing information broadcast to registered observers.
	*/
	@objc func updateReplyCell(_ notification: NSNotification) {
		let userInfo = notification.userInfo
		if let indexPath = userInfo?["indexPath"] as? IndexPath {
			let replyCell = tableView.cellForRow(at: indexPath) as? ReplyCell
			replyCell?.configureCell()
		}
	}

	/// Update the thread view with the fetched details.
	@objc func updateThreadDetails() {
		// Set topic label
		topicLabel.text = "In \(sectionTitle) by"

		// Set thread title
		self.title = forumsThread.attributes.title
		self.threadTitleLabel.text = forumsThread.attributes.title

		// Set thread content
		self.richTextView.text = forumsThread.attributes.content

		if let user = forumsThread.relationships.users.data.first {
			// Set poster username
			self.posterUsernameLabel.setTitle(user.attributes.username, for: .normal)
		}

		// Set thread stats
		let voteCount = forumsThread.attributes.metrics.weight
		voteCountButton.setTitle("\(voteCount.kkFormatted) · ", for: .normal)

		let commentCount = forumsThread.attributes.replyCount
		commentCountButton.setTitle("\(commentCount.kkFormatted) · ", for: .normal)

		dateTimeButton.setTitle(forumsThread.attributes.createdAt.timeAgo, for: .normal)

		// Thread vote state
		self.updateVoting(withVoteStatus: forumsThread.attributes.voteAction)

		// Set locked state
		lockImageView.tintColor = .kLightRed
		isLocked(forumsThread.attributes.lockStatus)
	}

	/// Fetch thread details for the current thread.
	func fetchDetails() {
		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing thread details...")
			#endif
		}

		KService.getDetails(forThread: forumThreadID) {[weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let threads):
				DispatchQueue.main.async {
					self.forumsThread = threads.first
					self.updateThreadDetails()
				}
			case .failure: break
			}
		}

		self.fetchThreadReplies()
	}

	/// Fetch the thread replies for the current thread.
	func fetchThreadReplies() {
		KService.getReplies(forThread: forumThreadID, orderedBy: repliesOrder, next: nextPageURL) {[weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let threadRepliesResponse):
				DispatchQueue.main.async {
					// Reset data if necessary
					if self.nextPageURL == nil {
						self.threadReplies = []
					}

					// Append new data and save next page url
					self.threadReplies.append(contentsOf: threadRepliesResponse.data)
					self.nextPageURL = threadRepliesResponse.next
				}
			case .failure: break
			}
		}
	}

	/**
		Update the voting status of the thread.

		- Parameter voteStatus: The `VoteStatus` value indicating whether to upvote, downvote or novote a thread.
	*/
	fileprivate func updateVoting(withVoteStatus voteStatus: VoteStatus) {
		if voteStatus == .upVote {
			self.upvoteButton.tintColor = .kGreen
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		} else if voteStatus == .noVote {
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		} else if voteStatus == .downVote {
			self.downvoteButton.tintColor = .kLightRed
			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	/**
		Shows and hides some elements according to the lock status of the current thread.

		- Parameter lockStatus: The `LockStatus` value indicating whather to show or hide some views.
	*/
	func isLocked(_ lockStatus: LockStatus) {
		forumsThread.attributes.lockStatus = lockStatus
		lockImageView.isHidden = !lockStatus.boolValue
		actionsStackView.isHidden = lockStatus.boolValue
		tableView.reloadData()
	}

	// MARK: - IBActions
	@IBAction func showUserProfileButton(_ sender: UIButton) {
		self.forumsThread.visitOriginalPosterProfile(from: self)
	}

	@IBAction func upVoteButtonPressed(_ sender: UIButton) {
		self.forumsThread.voteOnThread(as: .upVote, at: nil)
		sender.animateBounce()
	}

	@IBAction func downVoteButtonPressed(_ sender: UIButton) {
		self.forumsThread.voteOnThread(as: .downVote, at: nil)
		sender.animateBounce()
	}

	@IBAction func replyButtonPressed(_ sender: UIButton) {
		self.forumsThread.replyToThread(via: self)
		sender.animateBounce()
	}

	@IBAction func shareThreadButton(_ sender: UIButton) {
		self.forumsThread.openShareSheet(on: self, sender)
	}

	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		self.forumsThread.actionList(on: self, barButtonItem: sender, userInfo: nil)
	}
}

// MARK: - UITableViewDataSource
extension ThreadTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return threadReplies.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let replyCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.replyCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.replyCell.identifier)")
		}
		replyCell.delegate = self
		replyCell.forumsThread = forumsThread
		replyCell.threadReply = threadReplies[indexPath.section]
		return replyCell
	}
}

// MARK: - UITableViewDelegate
extension ThreadTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections - 5 {
			if self.nextPageURL != nil {
				self.fetchThreadReplies()
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let replyCell = tableView.cellForRow(at: indexPath) as? ReplyCell {
			replyCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			replyCell.usernameLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			replyCell.contentTextView.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let replyCell = tableView.cellForRow(at: indexPath) as? ReplyCell {
			replyCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			replyCell.usernameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			replyCell.contentTextView.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return self.threadReplies[indexPath.section].contextMenuConfiguration(in: self, userInfo: ["parentThread": self.forumsThread!, "indexPath": indexPath])
	}
}

// MARK: - ReplyCellDelegate
extension ThreadTableViewController: ReplyCellDelegate {
	func voteOnReplyCell(_ cell: ReplyCell, with voteStatus: VoteStatus) {
		if let indexPath = tableView.indexPath(for: cell) {
			self.threadReplies[indexPath.section].voteOnReply(as: voteStatus, at: indexPath)
		}
	}

	func visitOriginalPosterProfile(_ cell: ReplyCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			self.threadReplies[indexPath.section].visitOriginalPosterProfile(from: self)
		}
	}

	func showActionsList(_ cell: ReplyCell, sender: UIButton) {
		if let indexPath = tableView.indexPath(for: cell) {
			self.threadReplies[indexPath.section].actionList(sender, userInfo: ["parentThread": self.forumsThread!, "indexPath": indexPath])
		}
	}
}

// MARK: - KCommentEditorViewDelegate
extension ThreadTableViewController: KCommentEditorViewDelegate {
	func kCommentEditorView(updateRepliesWith threadReplies: [ThreadReply]) {
		DispatchQueue.main.async {
			for threadReply in threadReplies {
				self.threadReplies.prepend(threadReply)
			}
		}
	}
}
