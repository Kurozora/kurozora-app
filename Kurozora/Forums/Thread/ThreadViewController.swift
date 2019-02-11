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

class ThreadViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var lockLabel: UILabel!
	@IBOutlet weak var informationLabel: UILabel!
	@IBOutlet weak var posterUsernameLabel: UIButton!
	@IBOutlet weak var threadTitleLabel: UILabel!
	@IBOutlet weak var richTextView: RichTextView!
	@IBOutlet weak var upVoteButton: UIButton!
	@IBOutlet weak var downVoteButton: UIButton!
	@IBOutlet weak var replyButton: UIButton!

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

		// If presented modally, show a dismiss button instead of the default "back" button
		if isDismissEnabled {
			navigationItem.leftBarButtonItems = nil
			let stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissPressed(_:)))
			navigationItem.leftBarButtonItem = stopItem
		}

		// Fetch thread details
		if let threadID = forumThreadID, threadID != 0 {
			Service.shared.getDetails(forThread: threadID, withSuccess: { (thread) in
				DispatchQueue.main.async {
					self.forumThread = thread
					self.updateThreadDetails()
					self.tableView.reloadData()
				}
			})

			getThreadReplies(for: threadID)
		}

		// Register comment cells
		tableView.register(UINib(nibName: "ReplyCell", bundle: nil), forCellReuseIdentifier: "ReplyCell")

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self

		tableView.estimatedRowHeight = 200
		tableView.rowHeight = UITableView.automaticDimension
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
			self.richTextView.update(input: threadContent, completion: nil)
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

	// Get thread replies
	func getThreadReplies(for threadID: Int) {
		Service.shared.getReplies(forThread: threadID, order: order, page: pageNumber) { (replies) in
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

//    public let FetchLimit = 12
//
//    @IBOutlet public weak var tableView: UITableView!
//
//    public var thread: Thread?
//    public var threadType: ThreadType!
//
//    public var fetchController = FetchController()
//    public var refreshControl = UIRefreshControl()
//    public var loadingView: LoaderView!
//
//    var animator: ZFModalTransitionAnimator!
//    var playerController: XCDYouTubeVideoPlayerViewController?
//
//    var baseWidth: CGFloat {
//        get {
//            if UIDevice.isPad() {
//                return 600
//            } else {
//                return view.bounds.size.width
//            }
//        }
//    }
//
//    public func initWithThread(thread: Thread) {
//        self.thread = thread
//        self.threadType = .Custom
//    }
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        NotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
//
//        tableView.alpha = 0.0
//        tableView.estimatedRowHeight = 112.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//
//        CommentCell.registerNibFor(tableView: tableView)
//        LinkCell.registerNibFor(tableView: tableView)
//        WriteACommentCell.registerNibFor(tableView: tableView)
//        ShowMoreCell.registerNibFor(tableView: tableView)
//
//        loadingView = LoaderView(parentView: view)
//        addRefreshControl(refreshControl, action:"fetchPosts", forTableView: tableView)
//
//        if let thread = thread {
//            updateUIWithThread(thread: thread)
//        } else {
//            fetchThread()
//        }
//
//    }
//
//    deinit {
//        fetchController.tableView = nil
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    public func updateUIWithThread(thread: Thread) {
//        fetchPosts()
//    }
//
//    // MARK: - Fetching
//    public func fetchThread() {
//
//    }
//
//    public func fetchPosts() {
//
//    }
//
//    // MARK: - Internal functions
//
//    public func openProfile(user: User) {
//        if let profileController = self as? ProfileViewController {
//            if profileController.userProfile != user && !user.isTheCurrentUser() {
//                openProfileNow(user: user)
//            }
//        } else if !user.isTheCurrentUser() {
//            openProfileNow(user: user)
//        }
//    }
//
//    func openProfileNow(user: User? = nil, username: String? = nil) {
//        let profileController = KAnimeKit.profileViewController()
//        if let user = user  {
//            profileController.initWithUser(user: user)
//        } else if let username = username {
//            profileController.initWithUsername(username: username)
//        }
//
//        navigationController?.pushViewController(profileController, animated: true)
//    }
//
//    public func showImage(imageURLString: String, imageView: UIImageView) {
//        if let imageURL = URL(string: imageURLString) {
//            presentImageViewController(imageView, imageUrl: imageURL)
//        }
//    }
//
//    public func playTrailer(videoID: String) {
//        playerController = XCDYouTubeVideoPlayerViewController(videoIdentifier: videoID)
//        presentMoviePlayerViewControllerAnimated(playerController)
//    }
//
//    public func replyTo(post: Commentable) {
//        guard User.currentUserLoggedIn() else {
//            presentBasicAlertWithTitle(title: "Login first", message: "Select 'Me' tab")
//            return
//        }
//
//        let comment = KDatabaseKit.newPostViewController()
//        if let post = post as? ThreadPostable, let thread = thread, !thread.locked {
//            if thread.locked {
//                presentBasicAlertWithTitle(title: "Thread is locked")
//            } else {
//                comment.initWith(thread, threadType: threadType, delegate: self, parentPost: post)
//                animator = presentViewControllerModal(comment)
//            }
//
//        } else if let post = post as? TimelinePostable {
//            comment.initWithTimelinePost(self, postedIn:post.userTimeline, parentPost: post)
//            animator = presentViewControllerModal(comment)
//        }
//    }
//
//    func shouldShowAllRepliesForPost(post: Commentable, forIndexPath indexPath: IndexPath? = nil) -> Bool {
//        var indexPathIsSafe = true
//        if let indexPath = indexPath {
//            indexPathIsSafe = indexPath.row - 1 < post.replies.count
//        }
//        return (post.replies.count <= 3 || post.showAllReplies) && indexPathIsSafe
//    }
//
//    func shouldShowContractedRepliesForPost(post: Commentable, forIndexPath indexPath: IndexPath) -> Bool {
//        return post.replies.count > 3 && indexPath.row < 5
//    }
//
//    func indexForContactedReplyForPost(post: Commentable, forIndexPath indexPath: IndexPath) -> Int {
//        return post.replies.count - 5 + indexPath.row
//    }
//
//    public func postForCell(cell: UITableViewCell) -> Commentable? {
//        if let indexPath = tableView.indexPath(for: cell), let post = fetchController.objectAtIndex(index: indexPath.section) as? Commentable {
//            if indexPath.row == 0 {
//                return post
//                // TODO organize this code better it has dup lines everywhere D:
//            } else if shouldShowAllRepliesForPost(post: post, forIndexPath: indexPath) {
//                return post.replies[indexPath.row - 1] as? Commentable
//            } else if shouldShowContractedRepliesForPost(post: post, forIndexPath: indexPath) {
//                let index = indexForContactedReplyForPost(post: post, forIndexPath: indexPath)
//                return post.replies[index] as? Commentable
//            }
//        }
//
//        return nil
//    }
//
//    public func like(post: Commentable) {
//        if !User.currentUserLoggedIn() {
//            presentBasicAlertWithTitle(title: "Login first", message: "Select 'Profile' tab")
//            return
//        }
//
//        if let post = post as? PFObject, !post.dirty {
//            let likedBy = (post as! Commentable).likedBy ?? []
//            let currentUser = User.currentUser()!
//            if likedBy.contains(currentUser) {
//                post.removeObject(currentUser, forKey: "likedBy")
//            } else {
//                post.addUniqueObject(currentUser, forKey: "likedBy")
//            }
//            post.saveInBackground()
//        }
//    }
//
//    // MARK: - IBAction
//
//    @IBAction public func dismissPressed(sender: AnyObject) {
//        navigationController?.dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction public func replyToThreadPressed(sender: AnyObject) {
//
//    }
//}
//
//
//extension ThreadViewController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return fetchController.dataCount()
//    }
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let post = fetchController.objectInSection(section: section) as! Commentable
//        if post.replies.count > 0 {
//            if shouldShowAllRepliesForPost(post: post) {
//                return 1 + (post.replies.count ?? 0) + 1
//            } else {
//                // 1 post, 1 show more, 3 replies, 1 reply to post
//                return 1 + 1 + 3 + 1
//            }
//        } else {
//            return 1
//        }
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        var post = fetchController.objectAtIndex(index: indexPath.section) as! Commentable
//
//        if indexPath.row == 0 {
//
//            var reuseIdentifier = ""
//            if post.imagesData?.count != 0 || post.youtubeID != nil {
//                // Post image or video cell
//                reuseIdentifier = "PostImageCell"
//            } else if post.linkData != nil {
//                // Post link cell
//                reuseIdentifier = "LinkCell"
//            } else {
//                // Text post update
//                reuseIdentifier = "PostTextCell"
//            }
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostCell
//            cell.delegate = self
//            updateCell(cell: cell, withPost: post)
//            cell.layoutIfNeeded()
//            return cell
//
//        } else if shouldShowAllRepliesForPost(post: post, forIndexPath: indexPath) {
//
//            let replyIndex = indexPath.row - 1
//            return reuseCommentCellFor(comment: post, replyIndex: replyIndex)
//
//        } else if shouldShowContractedRepliesForPost(post: post, forIndexPath: indexPath) {
//            // Show all
//            if indexPath.row == 1 {
//                let cell = tableView.dequeueReusableCell(WithIdentifier: "ShowMoreCell") as! ShowMoreCell
//                cell.layoutIfNeeded()
//                return cell
//            } else {
//                let replyIndex = indexForContactedReplyForPost(post: post, forIndexPath: indexPath)
//                return reuseCommentCellFor(comment: post, replyIndex: replyIndex)
//            }
//        } else {
//
//            // Write a comment cell
//            let cell = tableView.dequeueReusableCell(WithIdentifier: "WriteACommentCell") as! WriteACommentCell
//            cell.layoutIfNeeded()
//            return cell
//        }
//    }
//
//    func reuseCommentCellFor(comment: Commentable, replyIndex: Int) -> CommentCell {
//        var comment = comment.replies[replyIndex] as! Commentable
//
//        var reuseIdentifier = ""
//        if comment.imagesData?.count != 0 || comment.youtubeID != nil {
//            // Comment image cell
//            reuseIdentifier = "CommentImageCell"
//        } else {
//            // Text comment update
//            reuseIdentifier = "CommentTextCell"
//        }
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! CommentCell
//        cell.delegate = self
//        updateCell(cell, withPost: comment)
//        cell.layoutIfNeeded()
//        return cell
//    }
//
//    func updateCell(cell: PostCell, withPost post: Commentable) {
//        // Updates to both styles
//
//        // Text content
//        var textContent = ""
//        if let content = post.content {
//            textContent = content
//        }
//
//        // Setting images and youtube
//        if post.hasSpoilers && post.isSpoilerHidden {
//            textContent += "\n\n(Show Spoilers)"
//            cell.imageHeightConstraint?.constant = 0
//            cell.playButton?.isHidden = true
//        } else {
//            if let spoilerContent = post.spoilerContent {
//                textContent += "\n\n\(spoilerContent)"
//            }
//            let calculatedBaseWidth = post.replyLevel == 0 ? baseWidth : baseWidth - 60
//            setImages(post.imagesData, imageView: cell.imageContent, imageHeightConstraint: cell.imageHeightConstraint, baseWidth: calculatedBaseWidth)
//            prepareForVideo(playButton: cell.playButton, imageView: cell.imageContent, imageHeightConstraint: cell.imageHeightConstraint, youtubeID: post.youtubeID)
//        }
//
//        // Poster information
//        if let postedBy = post.postedBy, let avatarFile = postedBy.avatarThumb {
//            cell.avatar.setImageWithPFFile(avatarFile)
//            cell.username?.text = postedBy.kurozoraUsername
//            cell.onlineIndicator.hidden = !postedBy.active
//        }
//
//        // Edited date
//        cell.date.text = post.createdDate?.timeAgo()
//        if var postedAgo = cell.date.text, post.edited {
//            postedAgo += " · Edited"
//            cell.date.text = postedAgo
//        }
//
//        // Like button
//        updateLikeButton(cell, post: post)
//
//        let postedByUsername = post.postedBy?.kurozoraUsername ?? ""
//        // Updates to each style
//        if let _ = cell as? CommentCell {
//            textContent = postedByUsername + " " + textContent
//        } else {
//            updatePostCell(cell: cell, withPost: post)
//        }
//
//        // Adding links to text content
//        updateAttributedTextProperties(textContent: cell.textContent)
//        cell.textContent.setText(textContent, afterInheritingLabelAttributesAndConfiguringWith: { (attributedString) -> NSMutableAttributedString? in
//            return attributedString
//        })
//
//        if let encodedUsername = postedByUsername.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()),
//            let url = URL(string: "kurozoraapp://profile/"+encodedUsername) {
//            let range = (textContent as String).rangeOfString(postedByUsername)
//            cell.textContent.addLinkToURL(url, withRange: range)
//        }
//    }
//
//    func updatePostCell(cell: PostCell, withPost post: Commentable) {
//
//        // Only embed links on post cells for now
//        if let linkCell = cell as? LinkCell, let linkData = post.linkData, let linkUrl = linkData.url {
//            linkCell.linkDelegate = self
//            linkCell.linkTitleLabel.text = linkData.title
//            linkCell.linkContentLabel.text = linkData.description
//            linkCell.linkUrlLabel.text = URL(string: linkUrl)?.host?.uppercaseString
//            if let imageURL = linkData.imageUrls.first {
//                linkCell.imageContent?.setImageFrom(urlString: imageURL, animated: false)
//                linkCell.imageHeightConstraint?.constant = (baseWidth - 16) * CGFloat(158)/CGFloat(305)
//            } else {
//                linkCell.imageContent?.image = nil
//                linkCell.imageHeightConstraint?.constant = 0
//            }
//        }
//
//        // From and to information
//        if let timelinePostable = post as? TimelinePostable, let postedBy = post.postedBy, timelinePostable.userTimeline != postedBy {
//            cell.toUsername?.text = timelinePostable.userTimeline.kurozoraUsername
//            cell.toIcon?.text = ""
//        } else {
//            cell.toUsername?.text = ""
//            cell.toIcon?.text = ""
//        }
//
//        // Reply button
//        let repliesTitle = repliesButtonTitle(repliesCount: post.replies.count)
//        cell.replyButton.setTitle(repliesTitle, forState: .Normal)
//    }
//
//    public func setImages(images: [ImageData]?, imageView: UIImageView?, imageHeightConstraint: NSLayoutConstraint?, baseWidth: CGFloat) {
//        if let image = images?.first {
//            imageHeightConstraint?.constant = baseWidth * CGFloat(image.height)/CGFloat(image.width)
//            imageView?.setImageFrom(urlString: image.url, animated: false)
//        } else {
//            imageHeightConstraint?.constant = 0
//        }
//    }
//
//    public func repliesButtonTitle(repliesCount: Int) -> String {
//        if repliesCount > 0 {
//            return " \(repliesCount)"
//        } else {
//            return " "
//        }
//    }
//
//    public func prepareForVideo(playButton: UIButton?, imageView: UIImageView?, imageHeightConstraint: NSLayoutConstraint?, youtubeID: String?) {
//        if let playButton = playButton {
//            if let youtubeID = youtubeID {
//                let urlString = "https://i.ytimg.com/vi/\(youtubeID)/maxresdefault.jpg"
//                imageView?.setImageFrom(urlString: urlString, animated: false)
//                imageHeightConstraint?.constant = baseWidth * CGFloat(180)/CGFloat(340)
//
//                playButton.isHidden = false
//                playButton.layer.borderWidth = 1.0;
//                playButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor;
//            } else {
//                playButton.isHidden = true
//            }
//        }
//    }
//
//    func updateAttributedTextProperties(textContent: UILabel) {
//        textContent.linkAttributes = [kCTForegroundColorAttributeName: UIColor.peterRiver()]
//        textContent.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
//        textContent.delegate = self;
//    }
//
//    func updateHeartButton(cell: PostCell, post: Commentable) {
//        if let likedBy = post.likedBy, likedBy.count > 0 {
//            cell.likeButton.setTitle(" \(likedBy.count)", forState: .Normal)
//        } else {
//            cell.heartButton.setTitle(" ", for: .normal)
//        }
//
//        if let likedBy = post.likedBy, let currentUser = User.currentUser(), likedBy.contains(currentUser) {
//            cell.heartButton.setImage(UIImage(named: "hear-red"), for: .normal)
//        } else {
//            cell.heartButton.setImage(UIImage(named: "heart-gray"), for: .normal)
//        }
//    }
//}
//
//extension ThreadViewController: UITableViewDelegate {
//    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.1
//    }
//
//    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return UIDevice.isPad() ? 6.0 : 4.0
//    }
//
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        var post = fetchController.objectAtIndex(index: indexPath.section) as! Commentable
//
//        if indexPath.row == 0 {
//            if post.hasSpoilers && post.isSpoilerHidden == true {
//                post.isSpoilerHidden = false
//                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
//            } else {
//                showSheetFor(post: post, indexPath: indexPath)
//            }
//
//        } else if shouldShowAllRepliesForPost(post: post, forIndexPath: indexPath) {
//            if let comment = post.replies[indexPath.row - 1] as? Commentable {
//                pressedOnAComment(post, comment: comment, indexPath: indexPath)
//            }
//        } else if shouldShowContractedRepliesForPost(post: post, forIndexPath: indexPath) {
//            // Show all
//            if indexPath.row == 1 {
//                post.showAllReplies = true
//                tableView.reloadData()
//            } else {
//                let index = indexForContactedReplyForPost(post: post, forIndexPath: indexPath)
//                if let comment = post.replies[index] as? Commentable {
//                    pressedOnAComment(post, comment: comment, indexPath: indexPath)
//                }
//            }
//        } else {
//            // Write a comment cell
//            replyTo(post: post)
//        }
//    }
//    func pressedOnAComment(post: Commentable, comment: Commentable, indexPath: IndexPath) {
//        if comment.hasSpoilers && comment.isSpoilerHidden == true {
//            comment.isSpoilerHidden = false
//            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
//        } else {
//            showSheetFor(post: comment, parentPost: post, indexPath: indexPath)
//        }
//    }
//    func showSheetFor(post: Commentable, parentPost: Commentable? = nil, indexPath: IndexPath) {
//        // If user's comment show delete/edit
//
//        guard let currentUser = User.currentUser(), let postedBy = post.postedBy, let cell = tableView.cellForRow(at: indexPath) else {
//            return
//        }
//
//        let administrating = currentUser.isAdmin() && !postedBy.isAdmin() || currentUser.isTopAdmin()
//        if let postedBy = post.postedBy, postedBy.isTheCurrentUser() ||
//            // Current user is admin and posted by non-admin user
//            administrating {
//
//            let alert: UIAlertController!
//
//            if administrating {
//                alert = UIAlertController(title: "Warning: Editing \(postedBy.kurozoraUsername) post", message: "Only edit user posts if they are breaking guidelines", preferredStyle: UIAlertControllerStyle.ActionSheet)
//                alert.popoverPresentationController?.sourceView = cell.superview
//                alert.popoverPresentationController?.sourceRect = cell.frame
//            } else {
//                alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//                alert.popoverPresentationController?.sourceView = cell.superview
//                alert.popoverPresentationController?.sourceRect = cell.frame
//            }
//
//            alert.addAction(UIAlertAction(title: "Edit", style: administrating ? UIAlertActionStyle.Destructive : UIAlertActionStyle.Default, handler: { (alertAction: UIAlertAction!) -> Void in
//                let comment = KDatabaseKit.newPostViewController()
//                if let post = post as? TimelinePost {
//                    comment.initWithTimelinePost(self, postedIn: currentUser, editingPost: post)
//                } else if let post = post as? Post, let thread = self.thread {
//                    comment.initWith(thread, threadType: self.threadType, delegate: self, editingPost: post)
//                }
//                self.animator = self.presentViewControllerModal(comment)
//            }))
//
//            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (alertAction: UIAlertAction!) -> Void in
//                if let post = post as? PFObject {
//                    if let parentPost = parentPost as? PFObject {
//                        // Just delete child post
//                        self.deletePosts([post], parentPost: parentPost, removeParent: false)
//                    } else {
//                        // This is parent post, remove child too
//                        var className = ""
//                        if let _ = post as? Post {
//                            className = "Post"
//                        } else if let _ = post as? TimelinePost {
//                            className = "TimelinePost"
//                        }
//
//                        let childPostsQuery = PFQuery(className: className)
//                        childPostsQuery.whereKey("parentPost", equalTo: post)
//                        childPostsQuery.findObjectsInBackgroundWithBlock({ (result, error) -> Void in
//                            if let result = result {
//                                self.deletePosts(result, parentPost: post, removeParent: true)
//                            } else {
//                                // TODO: Show error
//                            }
//                        })
//                    }
//                }
//            }))
//
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil))
//
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func deletePosts(childPosts: [PFObject] = [], parentPost: PFObject, removeParent: Bool) {
//        var allPosts = childPosts
//
//        if removeParent {
//            allPosts.append(parentPost)
//        }
//
//        PFObject.deleteAllInBackground(allPosts, block: { (success, error) -> Void in
//            if let _ = error {
//                // Show some error
//            } else {
//
//                func decrementPostCount() {
//                    for post in allPosts {
//                        (post["postedBy"] as? User)?.incrementPostCount(-1)
//                    }
//                }
//
//                if let thread = self.thread, !thread.isForumGame {
//                    // Decrement post counts only if thread does not contain #ForumGame tag
//                    decrementPostCount()
//                } else {
//                    decrementPostCount()
//                }
//
//                self.thread?.incrementReplyCount(byAmount: -allPosts.count)
//                self.thread?.saveInBackground()
//
//                if removeParent {
//                    // Delete parent post, and entire section
//                    if let section = self.fetchController.dataSource.indexOf(parentPost) {
//                        self.fetchController.dataSource.removeAtIndex(section)
//                        self.tableView.reloadData()
//                    }
//                } else {
//                    // Delete child post
//                    var parentPost = parentPost as! Commentable
//                    if let index = parentPost.replies.indexOf(childPosts.last!) {
//                        parentPost.replies.removeAtIndex(index)
//                        self.tableView.reloadData()
//                    }
//                }
//            }
//        })
//    }
//
//    func moviePlayerPlaybackDidFinish(notification: NSNotification) {
//        playerController = nil;
//    }
//}
//
//extension ThreadViewController: FetchControllerDelegate {
//    public func didFetchFor(skip: Int) {
//        refreshControl.endRefreshing()
//    }
//}
//
//extension ThreadViewController: CommentViewControllerDelegate {
//    public func commentViewControllerDidFinishedPosting(newPost: PFObject, parentPost: PFObject?, edited: Bool) {
//        if let thread = newPost as? Thread {
//            self.thread = thread
//        }
//    }
//}
//
//extension ThreadViewController: PostCellDelegate {
//    public func postCellSelectedImage(postCell: PostCell) {
//        if var post = postForCell(cell: postCell), let imageView = postCell.imageContent {
//            print(post)
//            if let imageData = post.imagesData?.first {
//                showImage(imageURLString: imageData.url, imageView: imageView)
//            } else if let videoID = post.youtubeID {
//                playTrailer(videoID: videoID)
//            }
//        }
//    }
//
//    public func postCellSelectedUserProfile(postCell: PostCell) {
//        if let post = postForCell(cell: postCell), let postedByUser = post.postedBy {
//            openProfile(postedByUser)
//        }
//    }
//
//    public func postCellSelectedComment(postCell: PostCell) {
//        if let post = postForCell(cell: postCell) {
//            replyTo(post: post)
//        }
//    }
//
//    public func postCellSelectedToUserProfile(postCell: PostCell) {
//        if let post = postForCell(postCell) as? TimelinePostable {
//            openProfile(post.userTimeline)
//        }
//    }
//
//    public func postCellSelectedHeart(postCell: PostCell) {
//        if let post = postForCell(cell: postCell) {
//            like(post: post)
//            updateLikeButton(postCell, post: post)
//        }
//    }
//}
//
//extension ThreadViewController: LinkCellDelegate {
//    public func postCellSelectedLink(linkCell: LinkCell) {
//        guard let indexPath = tableView.indexPath(for: linkCell),
//            var postable = fetchController.objectAtIndex(index: indexPath.section) as? Commentable,
//            let linkData = postable.linkData,
//            let url = linkData.url else {
//                return
//        }
//
//        let (navController, webController) = KDatabaseKit.webViewController()
//        let initialUrl = URL(string: url)
//        webController.initWithInitialUrl(initialUrl)
//        presentViewController(navController, animated: true, completion: nil)
//    }
//}
//
//extension ThreadViewController: FetchControllerQueryDelegate {
//
//    public func queriesForSkip(skip: Int) -> [PFQuery]? {
//        let query = PFQuery()
//        return [query]
//    }
//
//    public func processResult(result: [PFObject], dataSource: [PFObject]) -> [PFObject] {
//
//        let posts = result.filter({ $0["replyLevel"] as? Int == 0 })
//        let replies = result.filter({ $0["replyLevel"] as? Int == 1 })
//
//        // If page 0 was loaded and there are new posts, page 1 could return repeated results,
//        // For this, we need to remove duplicates
//        var searchIn: [PFObject] = []
//        if dataSource.count > result.count {
//            let b = dataSource.count
//            let a = b-result.count
//            searchIn = Array(dataSource[a..<b])
//        } else {
//            searchIn = dataSource
//        }
//        var uniquePosts: [PFObject] = []
//        for post in posts {
//            let exists = searchIn.filter({$0.objectId! == post.objectId!})
//            if exists.count == 0 {
//                uniquePosts.append(post)
//            }
//        }
//
//        for post in uniquePosts {
//            let postReplies = replies.filter({ ($0["parentPost"] as! PFObject) == post }) as [PFObject]
//            var postable = post as! Commentable
//            postable.replies = postReplies
//        }
//
//        return uniquePosts
//    }
//}

// MARK: - UITableViewDelegate
extension ThreadViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfSections = tableView.numberOfSections

		if indexPath.section == numberOfSections-1 {
			if let forumThreadID = forumThreadID, pageNumber <= totalPages-1 {
				getThreadReplies(for: forumThreadID)
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

		if let avatar = replies?[indexPath.section].user?.avatar, avatar != "" {
			let avatar = URL(string: avatar)
			let resource = ImageResource(downloadURL: avatar!)
			replyCell.avatar.kf.indicatorType = .activity
			replyCell.avatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))])
		} else {
			replyCell.avatar.image = #imageLiteral(resourceName: "default_avatar")
		}

		if let username = replies?[indexPath.section].user?.username, username != "" {
			replyCell.username?.text = username
		}

		if let dateTime = replies?[indexPath.section].postedAt, dateTime != "" {
			replyCell.dateTime.text = "·  \(Date.timeAgo(dateTime)) ·  "
		} else {
			replyCell.dateTime.text = ""
		}

		if let content = replies?[indexPath.section].content {
			replyCell.textContent.text = content
		}

		if let score = replies?[indexPath.section].score {
			replyCell.upVoteCountLabel.text = "\(score)\((score < 1000) ? "" : "K")"
		}

		if let locked = forumThread?.locked, locked {
			replyCell.upVoteButton.isHidden = true
			replyCell.upVoteButton.isUserInteractionEnabled = false
			replyCell.downVoteButton.isHidden = true
			replyCell.downVoteButton.isUserInteractionEnabled = false
		}

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
