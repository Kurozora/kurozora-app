//
//  CommentViewController.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import Parse
//import Bolts
import KCommonKit
import SDWebImage

//public protocol CommentViewControllerDelegate: class {
//    func commentViewControllerDidFinishedPosting(newPost: PFObject, parentPost: PFObject?, edited: Bool)
//}

//public enum ThreadType {
//    case Timeline
//    case Episode
//    case Custom
//}

public class CommentViewController: UIViewController {
    
//    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
//
//    @IBOutlet weak var inReply: UILabel!
//    @IBOutlet weak var photoButton: UIButton!
//    @IBOutlet weak var videoButton: UIButton!
//    @IBOutlet weak var linkButton: UIButton?
//    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var photoCountLabel: UILabel!
//    @IBOutlet weak var videoCountLabel: UILabel!
//    @IBOutlet weak var linkCountLabel: UILabel?
//    @IBOutlet weak var spoilersSwitch: UISwitch!
//
//    public weak var delegate: CommentViewControllerDelegate?
//
//    var animator: ZFModalTransitionAnimator!
//    var dataPersisted = false
//
//    var selectedImageData: ImageData? {
//        didSet {
//            updateMediaCountLabels()
//        }
//    }
//
//    var selectedVideoID: String? {
//        didSet {
//            updateMediaCountLabels()
//        }
//    }
//
//    var selectedLinkData: LinkData?
//    var selectedLinkUrl: URL? {
//        didSet {
//            updateMediaCountLabels()
//        }
//    }
//
//    var initialStatusBarStyle: UIStatusBarStyle!
//    var postedBy = User.currentUser()
//    var postedIn: User!
//    var parentPost: Postable?
//    var thread: Thread?
//    var threadType: ThreadType = .Timeline
//    var editingPost: PFObject?
//    var anime: Anime?
//
//    var fetchingData = false
//
//    public func initWithTimelinePost(delegate: CommentViewControllerDelegate?, postedIn: User, editingPost: PFObject? = nil, parentPost: Postable? = nil) {
//        self.postedIn = postedIn
//        self.threadType = .Timeline
//        self.editingPost = editingPost
//        self.delegate = delegate
//        self.parentPost = parentPost
//    }
//
//    public func initWith(thread: Thread? = nil, threadType: ThreadType, delegate: CommentViewControllerDelegate?, editingPost: PFObject? = nil, parentPost: Postable? = nil, anime: Anime? = nil) {
//        self.postedBy = User.currentUser()!
//        self.thread = thread
//        self.threadType = threadType
//        self.editingPost = editingPost
//        self.delegate = delegate
//        self.parentPost = parentPost
//        self.anime = anime
//    }
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//
//        photoCountLabel.isHidden = true
//        videoCountLabel.isHidden = true
//        linkCountLabel?.isHidden = true
//    }
//
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if isBeingPresented {
//            initialStatusBarStyle = UIApplication.shared.statusBarStyle
//        }
//        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
//    }
//
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        if isBeingDismissed {
//            UIApplication.shared.setStatusBarStyle(initialStatusBarStyle, animated: true)
//            view.endEditing(true)
//        }
//    }
//
//
//    // MARK: - NSNotificationCenter
//
//    @objc func keyboardWillShow(notification: NSNotification) {
//        let userInfo = notification.userInfo! as Dictionary
//
//        let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
//        let keyboardEndFrame = view.convert(endFrameValue.cgRectValue, from: nil)
//
//        updateInputForHeight(height: keyboardEndFrame.size.height)
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        updateInputForHeight(height: 0)
//    }
//
//    // MARK: - Functions
//
//    func updateInputForHeight(height: CGFloat) {
//
//        textViewBottomSpaceConstraint.constant = height
//
//        view.setNeedsUpdateConstraints()
//
//        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//    }
//
//    // MARK: - Override
//    func performPost() {
//    }
//
//    func performUpdate(post: PFObject) {
//    }
//
//    func completeRequest(post: PFObject, parentPost: PFObject?, error: NSError?) {
//        if let _ = error {
//            // TODO: Show error
//            self.sendButton.setTitle("Send", for: .normal)
//            self.sendButton.backgroundColor = UIColor.peterRiver()
//            self.sendButton.isUserInteractionEnabled = true
//        } else {
//            // Success!
//            dataPersisted = true
//            self.delegate?.commentViewControllerDidFinishedPosting(post, parentPost:parentPost, edited: (editingPost != nil))
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
//
//    func updateMediaCountLabels() {
//        if let _ = selectedVideoID {
//            videoCountLabel.isHidden = false
//        } else {
//            videoCountLabel.isHidden = true
//        }
//
//        if let _ = selectedImageData {
//            photoCountLabel.isHidden = false
//        } else {
//            photoCountLabel.isHidden = true
//        }
//
//        if let _ = selectedLinkUrl {
//            linkCountLabel?.isHidden = false
//        } else {
//            linkCountLabel?.isHidden = true
//        }
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func dimissViewControllerPressed(sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func addImagePressed(sender: AnyObject) {
//
//        if let _ = selectedImageData {
//            selectedImageData = nil
//        } else {
//            let imagesController = KDatabaseKit.commentStoryboard().instantiateViewController(withIdentifier: "Images") as! ImagesViewController
//            imagesController.delegate = self
//            animator = presentViewControllerModal(controller: imagesController)
//        }
//
//    }
//
//    @IBAction func addVideoPressed(sender: AnyObject) {
//
//        if let _ = selectedVideoID {
//            selectedVideoID = nil
//        } else {
//            let navController = KDatabaseKit.commentStoryboard().instantiateViewController(withIdentifier: "BrowserSelector") as! UINavigationController
//            let videoController = navController.viewControllers.last as! InAppBrowserSelectorViewController
//            let initialURL = URL(string: "https://www.youtube.com")
//            videoController.initWithInitialUrl(initialUrl: initialURL, overrideTitle: "Select a video")
//            videoController.delegate = self
//            present(navController, animated: true, completion: nil)
//        }
//
//    }
//
//    @IBAction func addLinkPressed(sender: AnyObject) {
//        if let _ = selectedLinkUrl {
//            selectedLinkUrl = nil
//        } else {
//            presentBasicAlertWithTitle(title: "Paste any link in text area", message: nil)
//        }
//    }
//
//    @IBAction func sendPressed(sender: AnyObject) {
//        if let editingPost = editingPost {
//            performUpdate(editingPost)
//        } else {
//            performPost()
//        }
//    }
//}
//
//extension CommentViewController: ImagesViewControllerDelegate {
//    func imagesViewControllerSelected(imageData: ImageData) {
//        selectedImageData = imageData
//        selectedVideoID = nil
//        selectedLinkUrl = nil
//    }
//}
//
//extension CommentViewController: InAppBrowserSelectorViewControllerDelegate {
//    public func inAppBrowserSelectorViewControllerSelectedSite(siteURL: String) {
//        if let url = URL(string: siteURL), let parameters = BFURL(URL: url).inputQueryParameters, let videoID = parameters["v"] as? String {
//            selectedVideoID = videoID
//            selectedImageData = nil
//            selectedLinkUrl = nil
//        }
//    }
//}
//
//extension CommentViewController: UITextViewDelegate {
//    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        // Grab pasted urls
//        if selectedLinkUrl == nil && text.count > 1 {
//            let types: NSTextCheckingResult.CheckingType = .link
//
//            let detector = try? NSDataDetector(types: types.rawValue)
//
//            guard let detect = detector else {
//                return true
//            }
//
//            let matches = detect.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
//
//            for match in matches {
//                if let url = match.url {
//
//                    // Pin youtube videos separately
//                    if let host = url.host, host.contains("youtube.com") || host.contains("youtu.be") {
//                        if host.contains("youtube.com") {
//                            inAppBrowserSelectorViewControllerSelectedSite(siteURL: url.absoluteString)
//                        }
//
//                        if host.contains("youtu.be") {
//                            let videoID = url.pathComponents[1]
//                            inAppBrowserSelectorViewControllerSelectedSite(siteURL: "http://www.youtube.com/watch?v=\(videoID)")
//                        }
//                        return false
//                    }
//
//                    // Append image if it's an image
//
//                    if  let lastPathComponent = url.lastPathComponent as Optional,
//                        lastPathComponent.ends(with: ".png") ||
//                        lastPathComponent.ends(with: ".jpeg") ||
//                        lastPathComponent.ends(with: ".gif") ||
//                        lastPathComponent.ends(with: ".jpg") {
//                            scrapeImageWithURL(url: url)
//                            return false
//                    }
//
//                    if  let host = url.host,
//                        let imageId = url.lastPathComponent as Optional,
//                        let imageURL = URL(string: "http://i.imgur.com/\(imageId).jpg"), host.contains("imgur.com") {
//                            scrapeImageWithURL(url: imageURL)
//                            return false
//                    }
//
//                    selectedLinkUrl = url
//                    scrapeLinkWithURL(url: url)
//                    // If only added 1 link and it's the same as the added text, don't add it
//                    if matches.count == 1 && match.range.length == text.count {
//                        return false
//                    }
//                }
//                break
//            }
//        }
//        return true
//    }
//
//    func scrapeLinkWithURL(url: URL) {
//        linkCountLabel?.text = ""
//        fetchingData = true
//
//        let scapper = LinkScrapper(viewController: self)
//        scapper.findInformationForLink(url).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject? in
//
//            self.fetchingData = false
//            if let linkData = task.result as? LinkData {
//                self.selectedLinkData = linkData
//                self.linkCountLabel?.text = "1"
//            } else {
//                self.selectedLinkUrl = nil
//            }
//
//            return nil
//        })
//    }
//
//    func scrapeImageWithURL(url: URL) {
//        photoCountLabel.text = ""
//        fetchingData = true
//
//        let manager = SDWebImageManager.shared()
//        manager.loadImage(with: url, options: [], progress: nil) {
//            (image, error, cacheType, finished, true, imageUrl) -> Void in
//            self.fetchingData = false
//
//            if let error = error {
//                print(error)
//                self.photoCountLabel?.text = nil
//            } else {
//                self.photoCountLabel?.text = "1"
//                let imageData = ImageData(url: url.absoluteString, width: Int((image?.size.width)!), height: Int((image?.size.height)!))
//                self.imagesViewControllerSelected(imageData: imageData)
//            }
//        }
//    }
}
