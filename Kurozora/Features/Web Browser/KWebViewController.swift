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
	// MARK: - Views
	private var doneBarButtonItem: UIBarButtonItem!
	private var shareBarButtonItem: UIBarButtonItem!
	private var activityIndicatorView: KActivityIndicatorView!

	// MARK: - Properties
	var webView: WKWebView!
	var url: String?

	// MARK: - View
	override func loadView() {
		super.loadView()

		self.configureView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBar.prefersLargeTitles = false

		if let urlString = url, let url = URL(string: urlString) {
			let request = URLRequest(url: url)
			self.webView.load(request)
		}
	}

	// MARK: - Functions
	func configureView() {
		self.configureNavigationItems()
		self.configureActivityIndicator()
		self.configureWebView()
		self.configureViewHierarchy()
	}

	/// Configures the done bar button item.
	private func configureDoneBarButtonItem() {
		self.doneBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.dismiss(animated: true, completion: nil)
		})
		self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
	}

	/// Configures the share bar button item.
	private func configureShareBarButtonItem() {
		self.shareBarButtonItem = UIBarButtonItem(systemItem: .action, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.handleShareBarButtonItem()
		})
		self.navigationItem.rightBarButtonItems?.append(self.shareBarButtonItem)
	}

	private func configureNavigationItems() {
		self.configureDoneBarButtonItem()
		self.configureShareBarButtonItem()
	}

	func configureActivityIndicator() {
		self.activityIndicatorView = KActivityIndicatorView()
	}

	func configureWebView() {
		self.webView = WKWebView(frame: view.frame)
		self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.webView.navigationDelegate = self
	}

	func configureViewHierarchy() {
		self.view.addSubview(self.activityIndicatorView)
		self.view.addSubview(self.webView)
		self.view.sendSubviewToBack(self.webView)
	}

	func handleShareBarButtonItem() {
		guard let url = url else { return }
		guard let title = title else { return }

		let shareText = ["\(title)\r\n\(url)"]
		let activityViewController = UIActivityViewController(activityItems: shareText, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			popoverController.barButtonItem = self.shareBarButtonItem
		}
		self.present(activityViewController, animated: true, completion: nil)
	}
}

// MARK: - WKNavigationDelegate
extension KWebViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		self.activityIndicatorView.startAnimating()
	}

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		self.activityIndicatorView.stopAnimating()
	}

	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		self.activityIndicatorView.stopAnimating()
	}
}
