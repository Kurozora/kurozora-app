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
			topicLabel.theme_textColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var voteCountButton: CellActionButton!
	@IBOutlet weak var commentCountButton: CellActionButton!
	@IBOutlet weak var dateTimeButton: CellActionButton!
	@IBOutlet weak var posterUsernameLabel: UIButton! {
		didSet {
			posterUsernameLabel.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var threadTitleLabel: KLabel!

	@IBOutlet weak var richTextView: KTextView! {
		didSet {
			richTextView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
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
			_prefersActivityIndicatorHidden = true
			self.forumThreadID = forumsThread?.id ?? self.forumThreadID
		}
	}
	var replyID: Int?
	var newReplyID: Int!
	var threadInformation: String?
	var sectionTitle = "Discussion"

	// Reply variables
	var threadReplies: [ThreadReply] = [] {
		didSet {
			tableView.reloadData()
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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Fetch thread details
		if forumsThread != nil {
			_prefersActivityIndicatorHidden = true
			DispatchQueue.main.async {
				self.updateThreadDetails()
			}
		}

		DispatchQueue.global(qos: .background).async {
			self.fetchDetails()
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
	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }

			let verticalOffset = (self.tableView.tableHeaderView?.height ?? 0 - self.view.height) / 2
			view.titleLabelString(NSAttributedString(string: "No Replies", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Be the first to reply on this thread!", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.comment())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(verticalOffset < 0 ? 0 : verticalOffset)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	/**
		Dismisses the view controller. Used for navigation bar buttons.

		- Parameter sender: The object requesting the dismisssal of the current view.
	*/
	@objc func dismissPressed(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}

	/// Update the thread view with the fetched details.
	func updateThreadDetails() {
		// Set topic label
		topicLabel.text = "In \(sectionTitle) by"

		// Set thread title
		self.title = forumsThread.attributes.title
		self.threadTitleLabel.text = forumsThread.attributes.title

		// Set thread content
		self.richTextView.text = forumsThread.attributes.content

		if let user = forumsThread.relationships.user.data.first {
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
		if forumsThread == nil {
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
		}
		getThreadReplies()
	}

	/// Fetch the thread replies for the current thread.
	func getThreadReplies() {
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
		self.forumsThread.voteOnThread(as: .upVote) { [weak self] forumsThread in
			guard let self = self else { return }
			self.forumsThread = forumsThread
			self.updateThreadDetails()
		}
		sender.animateBounce()
	}

	@IBAction func downVoteButtonPressed(_ sender: UIButton) {
		self.forumsThread.voteOnThread(as: .downVote) { [weak self] forumsThread in
			guard let self = self else { return }
			self.forumsThread = forumsThread
			self.updateThreadDetails()
		}
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
		fatalError("Implement more button.")
//		let menu = UIMenuController.shared
//		menu.menuItems =
//			[UIMenuItem(title: "Test me", action: Selector("deleteLine")),
//			 UIMenuItem(title: "Test me", action: Selector("deleteLine")),
//			 UIMenuItem(title: "Test me", action: Selector("deleteLine"))]
//		menu.showMenu(from: self.view, rect: self.view.frame)
//		becomeFirstResponder()
//		showActionList(sender)
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
				self.getThreadReplies()
			}
		}
	}

	override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if let replyCell = tableView.cellForRow(at: indexPath) as? ReplyCell {
			replyCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue

			replyCell.usernameLabel.theme_textColor = KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			replyCell.contentTextView.theme_textColor = KThemePicker.tableViewCellSelectedSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if let replyCell = tableView.cellForRow(at: indexPath) as? ReplyCell {
			replyCell.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

			replyCell.usernameLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
			replyCell.contentTextView.theme_textColor = KThemePicker.tableViewCellSubTextColor.rawValue
		}
	}

	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return self.threadReplies[indexPath.section].contextMenuConfiguration(in: self, onThread: self.forumsThread)
	}
}

// MARK: - ReplyCellDelegate
extension ThreadTableViewController: ReplyCellDelegate {
	func voteOnReplyCell(_ cell: ReplyCell, with voteStatus: VoteStatus) {
		if let indexPath = tableView.indexPath(for: cell) {
			let threadReply = self.threadReplies[indexPath.section]
			threadReply.voteOnThread(as: voteStatus) { [weak self] threadReply in
				guard let self = self else { return }
				self.threadReplies[indexPath.section] = threadReply
				cell.threadReply = threadReply
			}
		}
	}

	func visitOriginalPosterProfile(_ cell: ReplyCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			let threadReply = self.threadReplies[indexPath.section]
			threadReply.visitOriginalPosterProfile(from: self)
		}
	}
}

// MARK: - KCommentEditorViewDelegate
extension ThreadTableViewController: KCommentEditorViewDelegate {
	func updateReplies(with threadReplies: [ThreadReply]) {
		DispatchQueue.main.async {
			for threadReply in threadReplies {
				self.threadReplies.prepend(threadReply)
			}
		}
	}
}
