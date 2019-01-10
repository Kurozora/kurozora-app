////
////  InAppBrowserViewController.swift
////  KDatabaseKit
////
////  Created by Khoren Katklian on 17/05/2018.
////  Copyright © 2018 Kusa. All rights reserved.
////
//
//import WebKit
//
//public class InAppBrowserViewController: UIViewController {
////
////    var initialStatusBarStyle: UIStatusBarStyle!
////    public var webView: WKWebView!
////
////    public var initialUrl: URL? {
////        didSet {
////            if let initialUrl = initialUrl {
////                lastRequest = NSURLRequest(url: initialUrl)
////            }
////        }
////    }
////
////    var lastRequest : NSURLRequest?
////
////    public var overrideTitle: String?
////
////    public func initWithInitialUrl(initialUrl: URL?, overrideTitle: String? = nil) {
////        self.initialUrl = initialUrl
////        if let overrideTitle = overrideTitle {
////            self.overrideTitle = overrideTitle
////            self.title = overrideTitle
////        } else {
////            self.title = "Loading..."
////        }
////    }
////
////    override public func viewDidLoad() {
////        super.viewDidLoad()
////        var frame = view.bounds
////        frame.origin.y = 0
////        frame.size.height = frame.size.height - 44
////        webView = WKWebView(frame: frame)
////        webView.navigationDelegate = self
////        view.insertSubview(webView, at: 0)
////
////        navigationController?.navigationBar.barTintColor = UIColor.darkBlue()
////        navigationController?.navigationBar.tintColor = UIColor.white
////
////        if let request = lastRequest {
////            webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
////            webView.load(request as URLRequest)
////        }
////    }
////
////    public override func viewWillAppear(_ animated: Bool) {
////        super.viewWillAppear(animated)
////
////        initialStatusBarStyle = UIApplication.shared.statusBarStyle
////        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
////    }
////
////    public override func viewWillDisappear(_ animated: Bool) {
////        super.viewWillDisappear(animated)
////
////        UIApplication.shared.setStatusBarStyle(initialStatusBarStyle, animated: true)
////    }
////
////    // MARK: - KVO
////
////    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
////        guard let change = change else {
////            return
////        }
////
////        if overrideTitle != nil {
////            return
////        }
////
////        if keyPath == "title" {
////            if let title = change["new"] as? String {
////                self.title = title
////            }
////        }
////    }
////
////    // MARK: - IBActions
////
////    @IBAction func dismissModal() {
////        dismiss(animated: true, completion: nil)
////    }
////
////    @IBAction func openInSafari(sender: AnyObject) {
////        if let url = initialUrl {
////            UIApplication.shared.open(url)
////        }
////    }
////
////    @IBAction func navigateBack(sender: AnyObject) {
////        if webView.canGoBack {
////            webView.goBack()
////        }
////    }
////
////    @IBAction func navigateForward(sender: AnyObject) {
////        if webView.canGoForward {
////            webView.goForward()
////        }
////    }
////
////    deinit {
////        webView.removeObserver(self, forKeyPath: "title")
////        webView = nil
////    }
////
////}
////
////
////// MARK: <UIWebViewDelegate>
////
////extension InAppBrowserViewController : WKNavigationDelegate {
////    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
////    }
////
//}
//
