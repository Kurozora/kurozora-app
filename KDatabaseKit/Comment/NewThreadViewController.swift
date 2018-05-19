//
//  NewThreadViewController.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse
//import Bolts
import TTTAttributedLabel_moolban

public class NewThreadViewController: CommentViewController {
    
//    let EditingTitleCacheKey = "NewThread.TitleContent"
//    let EditingContentCacheKey = "NewThread.TextContent"
//
//    @IBOutlet weak var threadTitle: UITextField!
//    @IBOutlet weak var tagLabel: TTTAttributedLabel!
//
//    var tags: [PFObject] = [] {
//        didSet {
//            tagLabel.updateTags(tags, delegate: self)
//        }
//    }
//
//    var tagsToSet: [PFObject] = []
//
//    public func initCustomThreadWithDelegate(delegate: CommentViewControllerDelegate?, tags: [PFObject] = []) {
//        super.initWith(threadType: ThreadType.Custom, delegate: delegate)
//        tagsToSet = tags
//    }
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let title = UserDefaults.standard.object(forKey: EditingTitleCacheKey) as? String {
//            UserDefaults.standard.removeObject(forKey: EditingTitleCacheKey)
//            UserDefaults.standard.synchronize()
//            threadTitle.text = title
//        }
//
//        if let content = UserDefaults.standard.object(forKey: EditingContentCacheKey) as? String {
//            UserDefaults.standard.removeObject(forKey: EditingContentCacheKey)
//            UserDefaults.standard.synchronize()
//            textView.text = content
//        }
//
//        threadTitle.becomeFirstResponder()
//        threadTitle.textColor = UIColor.black
//        tagLabel.attributedText = nil
//
//        tags = tagsToSet
//
//        if let anime = anime, let animeTitle = anime.title {
//            threadTitle.placeholder = "Enter a thread title for \(animeTitle)"
//        } else {
//            threadTitle.placeholder = "Enter a thread title"
//        }
//
//        if let anime = anime {
//            tags = [anime]
//        }
//
//        if var thread = editingPost as? Thread {
//            textView.text = thread.content
//            threadTitle.text = thread.title
//            tags = thread.tags
//
//            if let youtubeID = thread.youtubeID {
//                selectedVideoID = youtubeID
//                videoCountLabel.isHidden = false
//                photoCountLabel.isHidden = true
//            } else if let imageData = thread.imagesData?.last {
//                selectedImageData = imageData
//                videoCountLabel.isHidden = true
//                photoCountLabel.isHidden = false
//            }
//        }
//    }
//
//    public override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        if !dataPersisted && editingPost == nil {
//            UserDefaults.standard.set(threadTitle.text, forKey: EditingTitleCacheKey)
//            UserDefaults.standard.set(textView.text, forKey: EditingContentCacheKey)
//            UserDefaults.standard.synchronize()
//        }
//    }
//
//    override func performPost() {
//        super.performPost()
//
//        if !validThread() {
//            return
//        }
//
//        self.sendButton.setTitle("Creating...", for: .normal)
//        self.sendButton.backgroundColor = UIColor.watching()
//        self.sendButton.isUserInteractionEnabled = false
//
//        var thread = Thread()
//        thread.edited = false
//        thread.title = threadTitle.text!
//        thread.content = textView.text
//        var postable = thread as! Postable
//        postable.replyCount = 0
//        thread.tags = tags
//        thread.subscribers = [postedBy!]
//        thread.lastPostedBy = postedBy
//
//        if let selectedImageData = selectedImageData {
//            thread.imagesData = [selectedImageData]
//        }
//
//        if let youtubeID = selectedVideoID {
//            thread.youtubeID = youtubeID
//        }
//
//        thread.startedBy = postedBy
//        thread.saveInBackgroundWithBlock({ (result, error) -> Void in
//            self.postedBy?.incrementPostCount(1)
//            self.completeRequest(thread, parentPost:nil, error: error)
//        })
//
//    }
//
//    override func performUpdate(post: PFObject) {
//        super.performUpdate(post)
//
//        if !validThread() {
//            return
//        }
//
//        self.sendButton.setTitle("Updating...", for: .normal)
//        self.sendButton.backgroundColor = UIColor.watching()
//        self.sendButton.isUserInteractionEnabled = false
//
//        if var thread = post as? Thread {
//            thread.edited = true
//            thread.title = threadTitle.text!
//            thread.content = textView.text
//            thread.tags = tags
//
//            if let selectedImageData = selectedImageData {
//                thread.imagesData = [selectedImageData]
//            } else {
//                thread.imagesData = []
//            }
//
//            if let youtubeID = selectedVideoID {
//                thread.youtubeID = youtubeID
//            } else {
//                thread.youtubeID = nil
//            }
//
//            thread.saveInBackgroundWithBlock({ (result, error) -> Void in
//                self.completeRequest(thread, parentPost:nil, error: error)
//            })
//        }
//    }
//
//    override func completeRequest(post: PFObject, parentPost: PFObject?, error: NSError?) {
//        super.completeRequest(post, parentPost: parentPost, error: error)
//        UserDefaults.standard.removeObject(forKey: EditingTitleCacheKey)
//        UserDefaults.standard.removeObject(forKey: EditingContentCacheKey)
//        UserDefaults.standard.synchronize()
//    }
//
//    func validThread() -> Bool {
//        let content = textView.text
//
//        if User.muted(viewController: self) {
//            return false
//        }
//
//        if (content?.count)! < 20 {
//            presentBasicAlertWithTitle(title: "Content too Short", message: "Content should be a 20 characters or longer, now \(String(describing: content?.count))")
//            return false
//        }
//
//        let title = threadTitle.text
//        if title!.count < 10 {
//            presentBasicAlertWithTitle(title: "Title too Short", message: "Thread title should be 10 characters or longer, now \(String(describing: content?.count))")
//            return false
//        }
//
//        if tags.count == 0 {
//            presentBasicAlertWithTitle(title: "Add a tag", message: "You need to add at least one tag")
//            return false
//        }
//
//        return true
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func addTags(sender: AnyObject) {
//    let tagsController = KDatabaseKit.commentStoryboard().instantiateViewController(withIdentifier: "Tags") as! TagsViewController
//        tagsController.selectedDataSource = tags
//        tagsController.delegate = self
//        animator = presentViewControllerModal(controller: tagsController)
//    }
//}
//
//extension NewThreadViewController: TagsViewControllerDelegate {
//    func tagsViewControllerSelected(tags: [PFObject]) {
//        self.tags = tags
//    }
//}
//
//extension NewThreadViewController: TTTAttributedLabelDelegate {
//
//    public func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
//        if let host = url.host, host == "tag", let index = url.pathComponents?[1], let idx = Int(index) {
//            tags.removeAtIndex(idx)
//        }
//    }
//}
//
//extension NewThreadViewController: ModalTransitionScrollable {
//    public var transitionScrollView: UIScrollView? {
//        return textView
//    }
}
