//
//  InAppBrowserSelectorViewController.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import WebKit
import KCommonKit

public protocol InAppBrowserSelectorViewControllerDelegate: class {
    func inAppBrowserSelectorViewControllerSelectedSite(siteURL: String)
}

public class InAppBrowserSelectorViewController: InAppBrowserViewController {
//
//    public weak var delegate: InAppBrowserSelectorViewControllerDelegate?
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Insert UIBarButtonAction
//        let selectBBI = UIBarButtonItem(title: "Select", style: UIBarButtonItemStyle.plain, target: self, action: #selector(selectedWebSite))
//        navigationItem.rightBarButtonItem = selectBBI
//    }
//
//    @objc func selectedWebSite(sender: AnyObject) {
//        if let urlString = webView.url?.absoluteString {
//            delegate?.inAppBrowserSelectorViewControllerSelectedSite(siteURL: urlString)
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
}
