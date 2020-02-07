//
//  ThreadTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView

class ThreadTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var lockImageView: UIImageView!
	@IBOutlet weak var discussionLabel: UILabel! {
		didSet {
			discussionLabel.theme_textColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var voteCountButton: UIButton! {
		didSet {
			voteCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			voteCountButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var commentCountButton: UIButton! {
		didSet {
			commentCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			commentCountButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var dateTimeButton: UIButton! {
		didSet {
			dateTimeButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			dateTimeButton.theme_setTitleColor(KThemePicker.tableViewCellActionDefaultColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var posterUsernameLabel: UIButton! {
		didSet {
			posterUsernameLabel.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var threadTitleLabel: UILabel! {
		didSet {
			threadTitleLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	@IBOutlet weak var richTextView: UITextView! {
		didSet {
			richTextView.theme_textColor = KThemePicker.textColor.rawValue
			richTextView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
			richTextView.textContainerInset = .zero
			richTextView.textContainer.lineFragmentPadding = 0
		}
	}
	@IBOutlet weak var upvoteButton: UIButton! {
		didSet {
			upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var downvoteButton: UIButton! {
		didSet {
			downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var replyButton: UIButton! {
		didSet {
			replyButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var shareButton: UIButton! {
		didSet {
			shareButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var actionsSeparatorView: UIView! {
		didSet {
			actionsSeparatorView.theme_backgroundColor = KThemePicker.separatorColor.rawValue
		}
	}
	@IBOutlet weak var actionsStackView: UIStackView!

	// MARK: - Properties
	var forumThreadID: Int?
	var forumsThreadElement: ForumsThreadElement? {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.forumThreadID = forumsThreadElement?.id
		}
	}
	var replyID: Int?
	var newReplyID: Int!
	var threadInformation: String?

	// Reply variables
	var replies: [ThreadRepliesElement]?
	var repliesOrder = "top"

	// Pagination
	var currentPage = 1
	var lastPage = 1

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
		if forumsThreadElement != nil {
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
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "forums", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "ThreadTableViewController")
	}

	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
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
		guard let forumsThreadElement = forumsThreadElement else { return }

		// Set thread title
		self.title = forumsThreadElement.title
		self.threadTitleLabel.text = forumsThreadElement.title

		// Set thread content
		if let contentText = forumsThreadElement.content {
			self.richTextView.text = contentText
		}

		// Set poster username
		self.posterUsernameLabel.setTitle(forumsThreadElement.posterUsername, for: .normal)

		// Set thread stats
		if let voteCount = forumsThreadElement.voteCount {
			voteCountButton.setTitle("\((voteCount >= 1000) ? voteCount.kFormatted : voteCount.string) · ", for: .normal)
		}

		if let commentCount = forumsThreadElement.commentCount {
			commentCountButton.setTitle("\((commentCount >= 1000) ? commentCount.kFormatted : commentCount.string) · ", for: .normal)
		}

		if let creationDate = forumsThreadElement.creationDate {
			dateTimeButton.setTitle(creationDate.timeAgo + " · by ", for: .normal)
		}

		// Thread vote state
		updateVoting(with: forumsThreadElement.currentUser?.likeAction)

		// Set locked state
		lockImageView.tintColor = .kLightRed
		if let locked = forumsThreadElement.locked {
			isLocked(locked)
		}
	}

	/// Fetch thread details for the current thread.
	func fetchDetails() {
		if forumsThreadElement == nil {
			KService.shared.getDetails(forThread: forumThreadID, withSuccess: { (thread) in
				DispatchQueue.main.async {
					self.forumsThreadElement = thread
					self.updateThreadDetails()
					self.tableView.reloadData()
				}
			})
		}
		getThreadReplies()
	}

	/// Fetch the thread replies for the current thread.
	func getThreadReplies() {
		KService.shared.getReplies(forThread: forumThreadID, order: repliesOrder, page: lastPage) { (replies) in
			DispatchQueue.main.async {
				self.currentPage = replies?.currentPage ?? 1
				self.lastPage = replies?.lastPage ?? 1

				if self.currentPage == 1 {
					self.replies = replies?.replies
				} else {
					for threadRepliesElement in replies?.replies ?? [] {
						self.replies?.append(threadRepliesElement)
					}
				}

				self.tableView.reloadData()
			}
		}
	}

	/**
		Vote the current thread with the given vote.

		- Parameter vote: The integer indicating whether to upvote or downvote the thread.
	*/
	func voteForThread(with vote: Int?) {
		WorkflowController.shared.isSignedIn {
			guard var threadScore = self.forumsThreadElement?.voteCount else { return }
			KService.shared.vote(forThread: self.forumThreadID, vote: vote, withSuccess: { (action) in
				DispatchQueue.main.async {
					if action == 1 { // upvote
						threadScore += 1
						self.upvoteButton.tintColor = .kGreen
						self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					} else if action == 0 { // no vote
						self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
						self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					} else if action == -1 { // downvote
						threadScore -= 1
						self.downvoteButton.tintColor = .kLightRed
						self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					}

					self.voteCountButton.setTitle("\((threadScore >= 1000) ? threadScore.kFormatted : threadScore.string) · ", for: .normal)
				}
			})
		}
	}

	/**
		Update the voting state of the reply.

		- Parameter action: The integer indicating whether to upvote, downvote or remove vote.
	*/
	fileprivate func updateVoting(with action: Int?) {
		if action == 1 { // upvote
			self.upvoteButton.tintColor = .kGreen
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		} else if action == 0 { // no vote
			self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		} else if action == -1 { // downvote
			self.downvoteButton.tintColor = .kLightRed
			self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}

	/// Presents the reply view for the current thread.
	func replyThread() {
		WorkflowController.shared.isSignedIn {
			let kCommentEditorViewController = KCommentEditorViewController.instantiateFromStoryboard() as? KCommentEditorViewController
			kCommentEditorViewController?.delegate = self
			kCommentEditorViewController?.forumsThreadElement = self.forumsThreadElement

			let kurozoraNavigationController = KNavigationController.init(rootViewController: kCommentEditorViewController!)
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false

			self.present(kurozoraNavigationController)
		}
	}

	/// Presents a share sheet to share the current thread.
	func shareThread(_ sender: UIButton? = nil, barButtonItem: UIBarButtonItem? = nil) {
		guard let threadID = forumThreadID else { return }
		let threadUrl = "https://kurozora.app/thread/\(threadID)"
		var shareText: [Any] = [URL(string: threadUrl) ?? threadUrl, "You should read this thread via @KurozoraApp"]

		if let title = forumsThreadElement?.title, !title.isEmpty {
			shareText = [URL(string: threadUrl) ?? threadUrl, "You should read \"\(title)\" via @KurozoraApp"]
		}

		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			if let sender = sender {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}
		self.present(activityVC, animated: true, completion: nil)
	}

	/// Sends a report of the selected thread to the mods.
	func reportThread() {
		WorkflowController.shared.isSignedIn {
		}
	}

	/**
		Shows and hides some elements according to the lock status of the current thread.

		- Parameter locked: The boolean indicating whather to show or hide the element.
	*/
	func isLocked(_ locked: Bool) {
		forumsThreadElement?.locked = locked
		// Set lock label
		if locked {
			lockImageView.isHidden = false
			upvoteButton.isUserInteractionEnabled = false
			downvoteButton.isUserInteractionEnabled = false
			replyButton.isUserInteractionEnabled = false
			actionsStackView.isHidden = true
		} else {
			lockImageView.isHidden = true
			upvoteButton.isUserInteractionEnabled = true
			downvoteButton.isUserInteractionEnabled = true
			replyButton.isUserInteractionEnabled = true
			actionsStackView.isHidden = false
		}
		tableView.reloadData()
	}

	/// Presents the profile view for the thread poster.
	func visitPosterProfilePage() {
		if let posterUserID = forumsThreadElement?.posterUserID, posterUserID != 0 {
			if let profileViewController = ProfileTableViewController.instantiateFromStoryboard() as? ProfileTableViewController {
				profileViewController.userID = posterUserID
				profileViewController.dismissButtonIsEnabled = true

				let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
				if #available(iOS 13.0, macCatalyst 13.0, *) {
					self.present(kurozoraNavigationController, animated: true, completion: nil)
				} else {
					self.presentAsStork(kurozoraNavigationController, height: nil, showIndicator: false, showCloseButton: false)
				}
			}
		}
	}

	/// Builds and presents an action sheet.
	func showActionList(_ sender: UIBarButtonItem) {
		guard let forumsThreadElement = forumsThreadElement else { return }
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions
//		if User.isAdmin || User.isMod {
//			if let threadID = forumsThreadElement.id, let locked = forumsThreadElement.locked, threadID != 0 {
//				var lock = 0
//				var lockTitle = "Locked"
//
//				if !locked {
//					lock = 1
//					lockTitle = "Unlocked"
//				}
//
//				let lockAction = UIAlertAction.init(title: lockTitle, style: .default, handler: { (_) in
//					KService.shared.lockThread(withID: threadID, lock: lock, withSuccess: { (locked) in
//						self.isLocked(locked)
//					})
//				})
//				lockAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
//
//				if locked {
//					lockAction.setValue(R.image.symbols.lock_fill()!, forKey: "image")
//				} else {
//					lockAction.setValue(R.image.symbols.lock_open_fill()!, forKey: "image")
//				}
//
//				action.addAction(lockAction)
//			}
//		}

		// Upvote, downvote and reply actions
		if let threadID = forumsThreadElement.id, let locked = forumsThreadElement.locked, threadID != 0 && !locked {
			let upvoteAction = UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
				self.voteForThread(with: 1)
			})
			let downvoteAction = UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
				self.voteForThread(with: 0)
			})
			let replyAction = UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
				self.replyThread()
			})

			upvoteAction.setValue(R.image.symbols.arrow_up_circle_fill()!, forKey: "image")
			upvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			downvoteAction.setValue(R.image.symbols.arrow_down_circle_fill()!, forKey: "image")
			downvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			replyAction.setValue(R.image.symbols.message_fill()!, forKey: "image")
			replyAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

			action.addAction(upvoteAction)
			action.addAction(downvoteAction)
			action.addAction(replyAction)
		}

		// Username action
		if let posterUsername = forumsThreadElement.posterUsername, !posterUsername.isEmpty {
			let userAction = UIAlertAction.init(title: posterUsername + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			})
			userAction.setValue(R.image.symbols.person_crop_circle_fill()!, forKey: "image")
			userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.addAction(userAction)
		}

		// Share thread action
		let shareAction = UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			self.shareThread(barButtonItem: sender)
		})
		shareAction.setValue(R.image.symbols.square_and_arrow_up_fill()!, forKey: "image")
		shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(shareAction)

		// Report thread action
		let reportAction = UIAlertAction.init(title: "Report", style: .destructive, handler: { (_) in
			self.reportThread()
		})
		reportAction.setValue(R.image.symbols.exclamationmark_circle_fill()!, forKey: "image")
		reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(reportAction)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(action, animated: true, completion: nil)
		}
	}

	// MARK: - IBActions
	@IBAction func showUserProfileButton(_ sender: UIButton) {
		visitPosterProfilePage()
	}

	@IBAction func upVoteButtonPressed(_ sender: UIButton) {
		voteForThread(with: 1)
		sender.animateBounce()
	}

	@IBAction func downVoteButtonPressed(_ sender: UIButton) {
		voteForThread(with: 0)
		sender.animateBounce()
	}

	@IBAction func replyButtonPressed(_ sender: UIButton) {
		replyThread()
		sender.animateBounce()
	}

	@IBAction func shareThreadButton(_ sender: UIButton) {
		shareThread(sender)
	}

	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		showActionList(sender)
	}
}

// MARK: - UITableViewDataSource
extension ThreadTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		if let repliesCount = replies?.count, repliesCount != 0 {
			return repliesCount
		}
		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let replyCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.replyCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.replyCell.identifier)")
		}

		replyCell.forumsThreadElement = forumsThreadElement
		replyCell.threadRepliesElement = replies?[indexPath.section]
		replyCell.threadViewController = self

		return replyCell
	}
}

// MARK: - UITableViewDelegate
extension ThreadTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections - 2 {
			if currentPage != lastPage {
				currentPage += 1
				getThreadReplies()
			}
		}
	}
}

// MARK: - KCommentEditorViewDelegate
extension ThreadTableViewController: KCommentEditorViewDelegate {
	func updateReplies(with threadRepliesElement: ThreadRepliesElement) {
		DispatchQueue.main.async {
			if self.replies == nil {
				self.replies = [threadRepliesElement]
			} else {
				self.replies?.prepend(threadRepliesElement)
			}
			self.tableView.reloadData()
		}
	}
}
