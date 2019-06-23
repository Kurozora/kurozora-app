//
//  ThreadViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import RichTextView
import Kingfisher
import EmptyDataSet_Swift

class ThreadViewController: UIViewController, EmptyDataSetDelegate, EmptyDataSetSource {
	@IBOutlet weak var tableView: UITableView!

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
	var forumThreadElement: ForumThreadElement?
	var replyID: Int?
	var newReplyID: Int!
	var threadInformation: String?
	var isDismissEnabled = false

	// Reply vars
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

		// If presented modally, show a dismiss button instead of the default "back" button
		if isDismissEnabled {
			navigationItem.leftBarButtonItems = nil
			let stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissPressed(_:)))
			navigationItem.leftBarButtonItem = stopItem
		}

		// Fetch thread details
		Service.shared.getDetails(forThread: forumThreadID, withSuccess: { (thread) in
			DispatchQueue.main.async {
				self.forumThreadElement = thread
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
	@objc func dismissPressed(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}

	// Update the thread view with the fetched details
	func updateThreadDetails() {
		// Set thread stats
		if let voteCount = forumThreadElement?.score {
			voteCountButton.setTitle("\((voteCount >= 1000) ? voteCount.kFormatted : voteCount.string) · ", for: .normal)
		}

		if let commentCount = forumThreadElement?.replyCount {
			commentCountButton.setTitle("\((commentCount >= 1000) ? commentCount.kFormatted : commentCount.string) · ", for: .normal)
		}

		if let creationDate = forumThreadElement?.creationDate {
			dateTimeButton.setTitle("\(Date.timeAgo(creationDate)) · by ", for: .normal)
		}

		// Set poster username
		if let posterUsername = forumThreadElement?.user?.username {
			self.posterUsernameLabel.setTitle(posterUsername, for: .normal)
		}

		// Set thread title
		if let threadTitle = forumThreadElement?.title {
			self.title = threadTitle
			self.threadTitleLabel.text = threadTitle
		}

		// Set thread content
		if let threadContent = forumThreadElement?.content {
			self.richTextView.update(input: threadContent, textColor: KThemePicker.tableViewCellSubTextColor.colorValue(), completion: nil)
		}

		// Set locked state
		if let locked = forumThreadElement?.locked {
			isLocked(locked)
		}
	}

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

	// Vote for current thread
	func voteForThread(with vote: Int?) {
		guard var threadScore = forumThreadElement?.score else { return }

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

	// Share the current thread
	func shareThread() {
		guard let threadID = forumThreadID else { return }
		var shareText: [String] = ["https://kurozora.app/thread/\(threadID)\nYou should read this thread via @KurozoraApp"]

		if let title = forumThreadElement?.title, title != "" {
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

	// Lock thread
	func isLocked(_ locked: Bool) {
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
	}

	// Visit the poster's profile page
	func visitPosterProfilePage() {
		if let posterId = forumThreadElement?.user?.id, posterId != 0 {
			let storyboard = UIStoryboard(name: "profile", bundle: nil)
			let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController
			profileViewController?.otherUserID = posterId
			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController!)

			self.present(kurozoraNavigationController, animated: true, completion: nil)
		}
	}

	// Populate action list
	func actionList() {
		guard let forumThreadElement = forumThreadElement else { return }
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mod and Admin features actions
		if User.isAdmin || User.isMod {
			if let threadID = forumThreadElement.id, let locked = forumThreadElement.locked, threadID != 0 {
				var lock: Int
				var lockTitle: String

				if locked {
					lock = 1
					lockTitle = "Lock"
				} else {
					lock = 0
					lockTitle = "Unock"
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
		if let threadID = forumThreadElement.id, let locked = forumThreadElement.locked, threadID != 0 && !locked {
			let upvoteAction = UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
				self.voteForThread(with: 1)
			})
			let downvoteAction = UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
				self.voteForThread(with: 0)
			})
			let replyAction = UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
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
		if let username = forumThreadElement.user?.username, username != "" {
			let userAction = UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
				self.visitPosterProfilePage()
			})
			userAction.setValue(#imageLiteral(resourceName: "user_male"), forKey: "image")
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

		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}

		if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
			self.present(action, animated: true, completion: nil)
		}
	}

	// MARK: - IBActions
	@IBAction func showUserProfileButton(_ sender: UIButton) {
		if let posterID = forumThreadElement?.user?.id, posterID != 0 {
			let storyboard = UIStoryboard(name: "profile", bundle: nil)
			let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileTableViewController") as? ProfileTableViewController
			profileViewController?.otherUserID = posterID

			let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController!)

			self.present(kurozoraNavigationController, animated: true, completion: nil)
		}
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
		let storyboard = UIStoryboard(name: "editor", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "KCommentEditorViewController") as? KCommentEditorViewController
		vc?.delegate = self
		vc?.forumThread = forumThreadElement

		let kurozoraNavigationController = KNavigationController.init(rootViewController: vc!)
		if #available(iOS 11.0, *) {
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		}

		self.present(kurozoraNavigationController, animated: true, completion: nil)
	}

	@IBAction func shareThreadButton(_ sender: UIButton) {
		shareThread()
	}

	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		actionList()
	}
}

// MARK: - UITableViewDelegate
extension ThreadViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections-1 {
			if pageNumber <= totalPages-1 {
				getThreadReplies()
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ThreadViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		if let repliesCount = replies?.count, repliesCount != 0 {
			return repliesCount
		}
		return 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let replyCell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyCell

		replyCell.forumThreadElement = forumThreadElement
		replyCell.threadRepliesElement = replies?[indexPath.section]
		replyCell.threadViewController = self

		return replyCell
	}
}

// MARK: - KCommentEditorViewDelegate
extension ThreadViewController: KCommentEditorViewDelegate {
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
