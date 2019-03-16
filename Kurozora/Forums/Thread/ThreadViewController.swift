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
	@IBOutlet weak var informationLabel: UILabel!
	@IBOutlet weak var posterUsernameLabel: UIButton!
	@IBOutlet weak var threadTitleLabel: UILabel!

	@IBOutlet weak var richTextView: RichTextView!
	@IBOutlet weak var upVoteButton: UIButton!
	@IBOutlet weak var downVoteButton: UIButton!
	@IBOutlet weak var replyButton: UIButton!
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet weak var actionsSeparatorView: UIView!

	var forumThreadID: Int?
	var forumThread: ForumThreadElement?
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
		view.theme_backgroundColor = "Global.backgroundColor"
		posterUsernameLabel.theme_setTitleColor("Global.tintColor", forState: .normal)
		informationLabel.theme_textColor = "Global.textColor"
		threadTitleLabel.theme_textColor = "Global.textColor"
		separatorView.theme_backgroundColor = "Global.separatorColor"
		actionsSeparatorView.theme_backgroundColor = "Global.separatorColor"
		richTextView.theme_backgroundColor = "Global.backgroundColor"

		// If presented modally, show a dismiss button instead of the default "back" button
		if isDismissEnabled {
			navigationItem.leftBarButtonItems = nil
			let stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissPressed(_:)))
			navigationItem.leftBarButtonItem = stopItem
		}

		// Fetch thread details
		Service.shared.getDetails(forThread: forumThreadID, withSuccess: { (thread) in
			DispatchQueue.main.async {
				self.forumThread = thread
				self.updateThreadDetails()
				self.getThreadReplies()
				self.tableView.reloadData()
			}
		})

		// Register comment cells
		tableView.register(UINib(nibName: "ReplyCell", bundle: nil), forCellReuseIdentifier: "ReplyCell")

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self
		tableView.estimatedRowHeight = 200
		tableView.rowHeight = UITableView.automaticDimension

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
		if let replyCount = forumThread?.replyCount, let creationDate = forumThread?.creationDate {
			informationLabel.text = "Discussion ·  \(replyCount)\((replyCount < 1000) ? "" : "K") ·  \(Date.timeAgo(creationDate)) · by "
		}

		// Set poster username
		if let posterUsername = forumThread?.user?.username {
			self.posterUsernameLabel.setTitle(posterUsername, for: .normal)
		}

		// Set thread title
		if let threadTitle = forumThread?.title {
			self.title = threadTitle
			self.threadTitleLabel.text = threadTitle
		}

		// Set thread content
		if let threadContent = forumThread?.content {
			self.richTextView.update(input: threadContent, textColor: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), completion: nil)
		}

		// Set locked state
		if let locked = forumThread?.locked, locked {
			self.lockLabel.isHidden = false
			self.upVoteButton.isUserInteractionEnabled = false
			self.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
			self.downVoteButton.isUserInteractionEnabled = false
			self.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
			self.replyButton.isUserInteractionEnabled = false
			self.replyButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
		} else {
			self.lockLabel.text = ""
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
	func vote(forThread threadID: Int?, vote: Int?) {
		Service.shared.vote(forThread: threadID, vote: vote, withSuccess: { (action) in
			DispatchQueue.main.async {
				if action == 1 {
					self.upVoteButton.setTitleColor(#colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1), for: .normal)
					self.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				} else if action == 0 {
					self.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
					self.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				} else if action == -1 {
					self.downVoteButton.setTitleColor(#colorLiteral(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1), for: .normal)
					self.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				}
			}
		})
	}

	func vote(forReply replyID: Int?, vote: Int?, replyCell: ReplyCell) {
		Service.shared.vote(forReply: replyID, vote: vote) { (action) in
			DispatchQueue.main.async {
				guard let countLabel = replyCell.upVoteCountLabel.text?.int else { return }
				if action == 1 {
					replyCell.upVoteCountLabel.text = String(countLabel + 1)
					replyCell.upVoteButton.setTitleColor(#colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1), for: .normal)
					replyCell.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				} else if action == 0 {
					if replyCell.upVoteButton.titleColor(for: .normal) == #colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1) {
						replyCell.upVoteCountLabel.text = String(countLabel - 1)
					} else if replyCell.downVoteButton.titleColor(for: .normal) == #colorLiteral(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1) {
						replyCell.upVoteCountLabel.text = String(countLabel + 1)
					}
					replyCell.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
					replyCell.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				} else if action == -1 {
					replyCell.upVoteCountLabel.text = String(countLabel - 1)
					replyCell.downVoteButton.setTitleColor(#colorLiteral(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1), for: .normal)
					replyCell.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
				}
			}
		}
	}

	// MARK: - IBActions
	@IBAction func showUserProfileButton(_ sender: UIButton) {
		if let posterID = forumThread?.user?.id, posterID != 0 {
			let storyboard = UIStoryboard(name: "profile", bundle: nil)
			let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController
			profileViewController?.otherUserID = posterID

			let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: profileViewController!)

			self.present(kurozoraNavigationController, animated: true, completion: nil)
		}
	}

	@IBAction func upVoteButtonPressed(_ sender: UIButton) {
		guard let threadId = forumThread?.id else { return }
		vote(forThread: threadId, vote: 1)
	}

	@IBAction func downVoteButtonPressed(_ sender: UIButton) {
		guard let threadId = forumThread?.id else { return }
		vote(forThread: threadId, vote: 0)
	}

	@IBAction func replyButtonPressed(_ sender: UIButton) {
		let storyboard = UIStoryboard(name: "editor", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "CommentEditor") as? KCommentEditorView
		vc?.delegate = self
		vc?.forumThread = forumThread

		let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: vc!)
		if #available(iOS 11.0, *) {
			kurozoraNavigationController.navigationBar.prefersLargeTitles = false
		}

		self.present(kurozoraNavigationController, animated: true, completion: nil)
	}

	@IBAction func shareThreadButton(_ sender: UIButton) {
		var shareText: String!
		guard let threadID = forumThreadID else { return }

		if let title = forumThread?.title {
			shareText = "https://kurozora.app/thread/\(threadID)\nYou should read \"\(title)\" via @KurozoraApp"
		} else {
			shareText = "https://kurozora.app/thread/\(threadID)\nYou should read this thread via @KurozoraApp"
		}

		let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		self.present(activityVC, animated: true, completion: nil)
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

		replyCell.forumThreadElement = forumThread
		replyCell.threadRepliesElement = replies?[indexPath.section]
		replyCell.delegate = self

		return replyCell
	}
}

// MARK: - ReplyCellDelegate
extension ThreadViewController: ReplyCellDelegate {
	func replyCellSelectedUserProfile(replyCell: ReplyCell) {
		if let indexPath = tableView.indexPath(for: replyCell) {
			if let replierID = replies?[indexPath.section].user?.id, replierID != 0 {
				let storyboard = UIStoryboard(name: "profile", bundle: nil)
				let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController
				profileViewController?.otherUserID = replierID

				let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: profileViewController!)

				self.present(kurozoraNavigationController, animated: true, completion: nil)
			}
		}
	}

	func replyCellSelectedComment(replyCell: ReplyCell) {
	}

	func replyCellSelectedUpVoteButton(replyCell: ReplyCell) {
		if let indexPath = tableView.indexPath(for: replyCell) {
			if let replyID = replies?[indexPath.section].id, replyID != 0 {
				vote(forReply: replyID, vote: 1, replyCell: replyCell)
			}
		}
	}

	func replyCellSelectedDownVoteButton(replyCell: ReplyCell) {
		if let indexPath = tableView.indexPath(for: replyCell) {
			if let replyID = replies?[indexPath.section].id, replyID != 0 {
				vote(forReply: replyID, vote: 0, replyCell: replyCell)
			}
		}
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
