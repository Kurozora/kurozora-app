//
//  ForumsChildViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import EmptyDataSet_Swift
import SwiftTheme

class ForumsChildViewController: UIViewController, EmptyDataSetSource, EmptyDataSetDelegate {
    @IBOutlet var tableView: UITableView!

	private let refreshControl = UIRefreshControl()

    var sectionTitle: String?
	var sectionID: Int?
	var sectionIndex: Int?
	var forumThreads: [ForumThreadsElement]? {
		didSet {
			tableView.reloadData()
		}
	}
	var threadOrder: String?

	// Pagination
	var totalPages = 0
	var pageNumber = 0

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		GlobalVariables().KUserDefaults?.set(sectionIndex, forKey: "ForumsPage")
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		
		guard let sectionTitle = sectionTitle else { return }

		// Add Refresh Control to Table View
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl)
		}

		refreshControl.theme_tintColor = "Global.tintColor"
		refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads", attributes: [NSAttributedString.Key.foregroundColor : ThemeManager.color(for: "Global.tintColor") ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		refreshControl.addTarget(self, action: #selector(refreshThreadsData(_:)), for: .valueChanged)

		fetchThreads()
        
        // Setup table view
        tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedSectionHeaderHeight = 0
        
        // Setup empty table view
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: sectionTitle))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(true)
        }
    }

	// MARK: - Functions
	@objc private func refreshThreadsData(_ sender: Any) {
		guard let sectionTitle = sectionTitle else {return}
		refreshControl.attributedTitle = NSAttributedString(string: "Reloading \(sectionTitle) threads", attributes: [NSAttributedString.Key.foregroundColor : ThemeManager.color(for: "Global.tintColor") ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		pageNumber = 0
		fetchThreads()
	}

	// Fetch threads list for the current section
	func fetchThreads() {
		guard let sectionTitle = sectionTitle else { return }
		guard let sectionID = sectionID else { return }
		if let _ = threadOrder { } else { threadOrder = "top" }

		Service.shared.getForumThreads(for: sectionID, order: threadOrder, page: pageNumber, withSuccess: { (threads) in
			DispatchQueue.main.async {
				if let threadPages = threads?.threadPages {
					self.totalPages = threadPages
				}

				if self.pageNumber == 0 {
					self.forumThreads = threads?.threads
					self.pageNumber += 1
				} else if self.pageNumber <= self.totalPages-1 {
					for forumThreadElement in (threads?.threads)! {
						self.forumThreads?.append(forumThreadElement)
					}
					self.pageNumber += 1
				}

//				self.tableView.reloadData()
				self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh \(sectionTitle) threads", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.color(for: "Global.tintColor") ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
			}
		})

		self.refreshControl.endRefreshing()
	}

//	// Upvote/Downvote a thread
//	func voteFor(_ threadID: Int?, vote: Int?, forumCell: ForumCell?) {
//		Service.shared.vote(forThread: threadID, vote: vote, withSuccess: { (action) in
//			DispatchQueue.main.async {
//				if action == 1 {
//					forumCell?.upVoteButton.setTitleColor(#colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1), for: .normal)
//					forumCell?.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//				} else if action == 0 {
//					forumCell?.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//					forumCell?.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//				} else if action == -1 {
//					forumCell?.downVoteButton.setTitleColor(#colorLiteral(red: 1, green: 0.3019607843, blue: 0.262745098, alpha: 1), for: .normal)
//					forumCell?.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//				}
//			}
//		})
//	}

//	// Populate action list
//	func actionList(forCell forumCell: ForumCell?, _ forumThread: ForumThreadsElement?) {
//		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//		// Mod and Admin features actions
//		if let isAdmin = User.isAdmin(), let isMod = User.isMod() {
//			if isAdmin || isMod {
//				if let threadID = forumThread?.id, let locked = forumThread?.locked, threadID != 0 {
//					var lock = 0
//					var lockTitle = "Unlock"
//
//					if !locked {
//						lock = 1
//						lockTitle = "Lock"
//					}
//
//					action.addAction(UIAlertAction.init(title: lockTitle, style: .default, handler: { (_) in
//						Service.shared.lockThread(withID: threadID, lock: lock, withSuccess: { (locked) in
//							if locked {
//								forumCell?.lockLabel.isHidden = false
//								forumCell?.upVoteButton.isUserInteractionEnabled = false
//								forumCell?.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
//								forumCell?.downVoteButton.isUserInteractionEnabled = false
//								forumCell?.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 0.5), for: .normal)
//								forumThread?.locked = true
//							} else {
//								forumCell?.lockLabel.isHidden = true
//								forumCell?.upVoteButton.isUserInteractionEnabled = true
//								forumCell?.upVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//								forumCell?.downVoteButton.isUserInteractionEnabled = true
//								forumCell?.downVoteButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
//								forumThread?.locked = false
//							}
//						})
//					}))
//				}
//			}
//		}
//
//		// Upvote, downvote and reply actions
//		if let threadID = forumThread?.id, let locked = forumThread?.locked, threadID != 0 && !locked {
//			action.addAction(UIAlertAction.init(title: "Upvote", style: .default, handler: { (_) in
//				self.voteFor(threadID, vote: 1, forumCell: forumCell)
//			}))
//			action.addAction(UIAlertAction.init(title: "Downvote", style: .default, handler: { (_) in
//				self.voteFor(threadID, vote: 0, forumCell: forumCell)
//			}))
//			action.addAction(UIAlertAction.init(title: "Reply", style: .default, handler: { (_) in
//			}))
//		}
//
//		// Username action
//		if let username = forumThread?.posterUsername, username != "" {
//			action.addAction(UIAlertAction.init(title: username + "'s profile", style: .default, handler: { (_) in
//				if let posterId = forumThread?.posterUserID, posterId != 0 {
//					let storyboard = UIStoryboard(name: "profile", bundle: nil)
//					let profileViewController = storyboard.instantiateViewController(withIdentifier: "Profile") as? ProfileViewController
//					profileViewController?.otherUserID = posterId
//					let kurozoraNavigationController = KurozoraNavigationController.init(rootViewController: profileViewController!)
//
//					self.present(kurozoraNavigationController, animated: true, completion: nil)
//				}
//			}))
//		}
//
//		// Share thread action
//		action.addAction(UIAlertAction.init(title: "Share", style: .default, handler: { (_) in
//			if let forumCell = forumCell {
//				var shareText: String!
//				guard let threadID = forumThread?.id else { return }
//
//				if let title = forumCell.titleLabel.text {
//					shareText = "https://kurozora.app/thread/\(threadID)\nYou should read \"\(title)\" via @KurozoraApp"
//				} else {
//					shareText = "https://kurozora.app/thread/\(threadID)\nYou should read this thread via @KurozoraApp"
//				}
//
//				let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
//
//				if let popoverController = activityVC.popoverPresentationController {
//					popoverController.sourceView = self.view
//					popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//					popoverController.permittedArrowDirections = []
//				}
//				self.present(activityVC, animated: true, completion: nil)
//			}
//		}))
//
//		// Report thread action
//		action.addAction(UIAlertAction.init(title: "Report", style: .default, handler: { (_) in
//		}))
//
//		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
//
//		action.view.tintColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
//
//		//Present the controller
//		if let popoverController = action.popoverPresentationController {
//			popoverController.sourceView = self.view
//			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
//			popoverController.permittedArrowDirections = []
//		}
//
//		if !(self.navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
//			self.present(action, animated: true, completion: nil)
//		}
//	}

//	// Show cell options
//	@objc func showCellOptions(_ longPress: UILongPressGestureRecognizer) {
//		let pointInTable = longPress.location(in: self.tableView)
//
//		if let indexPath = self.tableView.indexPathForRow(at: pointInTable) {
//			if (self.tableView.cellForRow(at: indexPath) as? ForumCell) != nil {
//				let threadCell = longPress.view as? ForumCell
//				let thread = forumThreads?[indexPath.row]
//				actionList(forCell: threadCell, thread)
//			}
//		}
//	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ThreadSegue" {
			let threadViewController = segue.destination as? ThreadViewController
			threadViewController?.hidesBottomBarWhenPushed = true
			threadViewController?.forumThreadID = sender as? Int
		}
	}
}

// MARK: - UITableViewDataSource
extension ForumsChildViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let threadsCount = forumThreads?.count else { return 0 }
		return threadsCount
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let forumCell
		: ForumCell = tableView.dequeueReusableCell(withIdentifier: "ForumCell") as! ForumCell

		forumCell.forumThreadsElement = forumThreads?[indexPath.row]

		return forumCell
	}
}

// MARK: - UITableViewDelegate
extension ForumsChildViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let forumThreadID = forumThreads?[indexPath.row].id {
			performSegue(withIdentifier: "ThreadSegue", sender: forumThreadID)
		}
	}

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows-1 {
			if pageNumber <= totalPages-1 {
				fetchThreads()
			}
		}
	}
}

// // MARK: - UIGestureRecognizerDelegate
//extension ForumsChildViewController: UIGestureRecognizerDelegate {
//	// Upvote cell
//	@objc func upVoteCell(_ gesture: UITapGestureRecognizer) {
//		let pointInTable = gesture.location(in: self.tableView)
//
//		if let indexPath = self.tableView.indexPathForRow(at: pointInTable) {
//			if (self.tableView.cellForRow(at: indexPath) as? ForumCell) != nil {
//				let forumCell = gesture.view as? ForumCell
//				guard let threadID = forumThreads?[indexPath.row].id else { return }
//
//				voteFor(threadID, vote: 1, forumCell: forumCell)
//				forumCell?.upVoteButton.animateBounce()
//			}
//		}
//	}
//}

// MARK: - ForumCellDelegate
//extension ForumsChildViewController: ForumCellDelegate {
//	func moreButtonPressed(cell: ForumCell) {
//		if let indexPath = tableView.indexPath(for: cell) {
//			guard let thread = forumThreads?[indexPath.row] else { return }
//			actionList(forCell: cell, thread)
//		}
//	}
//}

// MARK: - KRichTextEditorControllerViewDelegate
extension ForumsChildViewController: KRichTextEditorControllerViewDelegate {
	func updateThreadsList(with thread: ForumThreadsElement) {
		DispatchQueue.main.async {
			if self.forumThreads == nil {
				self.forumThreads = [thread]
			} else {
				self.forumThreads?.prepend(thread)
			}
//			self.tableView.reloadData()
		}
	}
}
