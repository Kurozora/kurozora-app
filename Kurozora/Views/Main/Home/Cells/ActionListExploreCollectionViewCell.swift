//
//  ActionListExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ActionListExploreCollectionViewCell: ActionBaseExploreCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var separatorView: UIView? {
		didSet {
			separatorView?.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
		}
	}

	// MARK: - Properties
	var separatorIsHidden = false

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		super.configureCell()
		separatorView?.isHidden = separatorIsHidden
	}

	// MARK: - IBActions
	override func actionButtonPressed(_ sender: UIButton) {
		if let kNavigationController = R.storyboard.webBrowser.kWebViewKNavigationController() {
			if let kWebViewController = kNavigationController.viewControllers.first as? KWebViewController {
				kWebViewController.url = actionItem?["url"]
				kWebViewController.title = actionItem?["title"]
			}

			kNavigationController.modalPresentationStyle = .custom
			self.parentViewController?.present(kNavigationController)
		}
	}
}
