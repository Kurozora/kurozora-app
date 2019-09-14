//
//  ThreadTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import Kingfisher
import RichTextView
import SwiftyJSON
import SCLAlertView

class ThreadTableViewController: UITableViewController, EmptyDataSetDelegate, EmptyDataSetSource {
	@IBOutlet weak var lockLabel: UILabel!
	@IBOutlet weak var discussionLabel: UILabel! {
		didSet {
			discussionLabel.theme_textColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var voteCountButton: UIButton! {
		didSet {
			voteCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var commentCountButton: UIButton! {
		didSet {
			commentCountButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
		}
	}
	@IBOutlet weak var dateTimeButton: UIButton! {
		didSet {
			dateTimeButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
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

	@IBOutlet weak var richTextView: RichTextView! {
		didSet {
			richTextView.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
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

	var forumThreadID: Int?
	var forumsThreadElement: ForumsThreadElement?
	var replyID: Int?
	var newReplyID: Int!
	var threadInformation: String?
	var dismissButtonIsEnabled = false {
		didSet {
			// If presented modally, show a dismiss button instead of the default "back" button
			if dismissButtonIsEnabled {
				navigationItem.leftBarButtonItems = nil
				let stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissPressed(_:)))
				navigationItem.leftBarButtonItem = stopItem
			}
		}
	}

	// Reply variables
	var replies: [ThreadRepliesElement]?
	var order = "top"

	// Pagination
	var totalPages = 0
	var pageNumber = 0

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Fetch thread details
		Service.shared.getDetails(forThread: forumThreadID, withSuccess: { (thread) in
			DispatchQueue.main.async {
				self.forumsThreadElement = thread
				self.updateThreadDetails()
				self.getThreadReplies()
				self.tableView.reloadData()
			}
		})

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No replies yet. Be the first to reply!"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
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

	/**
		Dismisses the view controller. Used for navigation bar buttons.

		- Parameter sender: The object requesting the dismisssal of the current view.
	*/
	@objc func dismissPressed(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}

	/// Update the thread view with the fetched details.
	func updateThreadDetails() {
		// Set thread stats
		if let voteCount = forumsThreadElement?.score {
			voteCountButton.setTitle("\((voteCount >= 1000) ? voteCount.kFormatted : voteCount.string) · ", for: .normal)
		}

		if let commentCount = forumsThreadElement?.replyCount {
			commentCountButton.setTitle("\((commentCount >= 1000) ? commentCount.kFormatted : commentCount.string) · ", for: .normal)
		}

		if let creationDate = forumsThreadElement?.creationDate {
			dateTimeButton.setTitle("\(Date.timeAgo(creationDate)) · by ", for: .normal)
		}

		// Set poster username
		if let posterUsername = forumsThreadElement?.posterUsername {
			self.posterUsernameLabel.setTitle(posterUsername, for: .normal)
		}

		// Set thread title
		if let threadTitle = forumsThreadElement?.title {
			self.title = threadTitle
			self.threadTitleLabel.text = threadTitle
		}

		// Set thread content
		if let threadContent = forumsThreadElement?.content {
			self.richTextView.update(input: threadContent, textColor: KThemePicker.tableViewCellSubTextColor.colorValue, completion: nil)
		}

		// Set locked state
		if let locked = forumsThreadElement?.locked {
			isLocked(locked)
		}
	}

	/// Fetch the thread replies for the current thread.
	func getThreadReplies() {
		Service.shared.getReplies(forThread: forumThreadID, order: order, page: pageNumber) { (replies) in
			DispatchQueue.main.async {
				if let replyPages = replies.replyPages {
					self.totalPages = replyPages
				}

				if self.pageNumber == 0 {
					self.replies = replies.replies
					self.pageNumber += 1
				} else if self.pageNumber <= self.totalPages-1 {
					for threadRepliesElement in (replies.replies)! {
						self.replies?.append(threadRepliesElement)
					}
					self.pageNumber += 1
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
		guard var threadScore = forumsThreadElement?.score else { return }
		Service.shared.vote(forThread: forumThreadID, vote: vote, withSuccess: { (action) in
			DispatchQueue.main.async {
				if action == 1 { // upvote
					threadScore += 1
					self.upvoteButton.tintColor = #colorLiteral(red: 0.2156862745, green: 0.8274509804, blue: 0.1294117647, alpha: 1)
					self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				} else if action == 0 { // no vote
					self.downvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
					self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				} else if action == -1 { // downvote
					threadScore -= 1
					self.downvoteButton.tintColor = #colorLiteral(red: 1, green: 0.2549019608, blue: 0.3450980392, alpha: 1)
					self.upvoteButton.theme_tintColor = KThemePicker.tableViewCellActionDefaultColor.rawValue
				}

				self.voteCountButton.setTitle("\((threadScore >= 1000) ? threadScore.kFormatted : threadScore.string) · ", for: .normal)
			}
		})
	}

	/// Presents the reply view for the current thread.
	func replyThread() {
		let kCommentEditorViewController = KCommentEditorViewController.instantiateFromStoryboard() as? KCommentEditorViewController
		kCommentEditorViewController?.delegate = self
		kCommentEditorViewController?.forumsThreadElement = forumsThreadElement

		let kurozoraNavigationController = KNavigationController.init(rootViewController: kCommentEditorViewController!)
		kurozoraNavigationController.navigationBar.prefersLargeTitles = false

		if #available(iOS 13.0, *) {
			self.present(kurozoraNavigationController, animated: true, completion: nil)
		} else {
			self.presentAsStork(kurozoraNavigationController, height: nil, showIndicator: false, showCloseButton: false)
		}
	}

	/// Presents a share sheet to share the current thread.
	func shareThread() {
		guard let threadID = forumThreadID else { return }
		var shareText: [String] = ["https://kurozora.app/thread/\(threadID)\nYou should read this thread via @KurozoraApp"]

		if let title = forumsThreadElement?.title, !title.isEmpty {
			shareText = ["https://kurozora.app/thread/\(threadID)\nYou should read \"\(title)\" via @KurozoraApp"]
		}

		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		self.present(activityVC, animated: true, completion: nil)
	}

	/**
		Shows and hides some elements according to the lock status of the current thread.

		- Parameter locked: The boolean indicating whather to show or hide the element.
	*/
	func isLocked(_ locked: Bool) {
		forumsThreadElement?.locked = locked
		// Set lock label
		if locked {
			lockLabel.isHidden = false
			upvoteButton.isUserInteractionEnabled = false
			downvoteButton.isUserInteractionEnabled = false
			replyButton.isUserInteractionEnabled = false
			actionsStackView.isHidden = true
		} else {
			lockLabel.isHidden = true
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
				if #available(iOS 13.0, *) {
					self.present(kurozoraNavigationController, animated: true, completion: nil)
				} else {
					self.presentAsStork(kurozoraNavigationController, height: nil, showIndicator: false, showCloseButton: false)
				}
			}
		}
	}

	/// Builds and presents an action sheet.
	func showActionList() {
		guard let forumsThreadElement = forumsThreadElement else { return }
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions
		if User.isAdmin || User.isMod {
			if let threadID = forumsThreadElement.id, let locked = forumsThreadElement.locked, threadID != 0 {
				var lock = 0
				var lockTitle = "Locked"

				if !locked {
					lock = 1
					lockTitle = "Unlocked"
				}

				let lockAction = UIAlertAction.init(title: lockTitle, style: .default, handler: { (_) in
					Service.shared.lockThread(withID: threadID, lock: lock, withSuccess: { (locked) in
						self.isLocked(locked)
					})
				})
				lockAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

				if locked {
					lockAction.setValue(#imageLiteral(resourceName: "locked"), forKey: "image")
				} else {
					lockAction.setValue(#imageLiteral(resourceName: "unlocked"), forKey: "image")
				}

				action.addAction(lockAction)
			}
		}

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

			upvoteAction.setValue(#imageLiteral(resourceName: "arrow_up"), forKey: "image")
			upvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			downvoteAction.setValue(#imageLiteral(resourceName: "arrow_down"), forKey: "image")
			downvoteAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			replyAction.setValue(#imageLiteral(resourceName: "comment"), forKey: "image")
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
			userAction.setValue(#imageLiteral(resourceName: "profile"), forKey: "image")
			userAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			action.addAction(userAction)
		}

		// Share thread action
		let shareAction = UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
			self.shareThread()
		})
		shareAction.setValue(#imageLiteral(resourceName: "share"), forKey: "image")
		shareAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(shareAction)

		// Report thread action
		let reportAction = UIAlertAction.init(title: "Report", style: .destructive, handler: { (_) in
		})
		reportAction.setValue(#imageLiteral(resourceName: "info_icon"), forKey: "image")
		reportAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(reportAction)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
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
		shareThread()
	}

	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		showActionList()
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
		let replyCell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyCell

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

		if indexPath.section == numberOfSections-1 {
			if pageNumber <= totalPages-1 {
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
