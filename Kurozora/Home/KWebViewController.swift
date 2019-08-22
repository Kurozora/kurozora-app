//
//  KWebViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import WebKit

class KWebViewController: UIViewController {
	@IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

	var webView: WKWebView!
	var url: String?

	override func loadView() {
		super.loadView()

		webView = WKWebView(frame: view.frame)
		webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		webView.navigationDelegate = self
		view.addSubview(webView)
		view.sendSubviewToBack(webView)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = false
		}

		if let urlString = url, let url = URL(string: urlString) {
			let request = URLRequest(url: url)
			webView.load(request)
		}
	}

	// MARK: - IBActions
	@IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func actionButtonPressed(_ sender: UIBarButtonItem) {
		guard let url = url else { return }
		guard let title = title else { return }

		let shareText = ["\(title)\r\n\(url)"]
		let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityVC.popoverPresentationController {
			popoverController.barButtonItem = sender
		}
		self.present(activityVC, animated: true, completion: nil)
	}
}

// MARK: - WKNavigationDelegate
extension KWebViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		activityIndicatorView.startAnimating()
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		activityIndicatorView.stopAnimating()
	}

	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		activityIndicatorView.stopAnimating()
	}
}
