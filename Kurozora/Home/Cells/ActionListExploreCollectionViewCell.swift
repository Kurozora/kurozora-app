//
//  ActionListExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ActionListExploreCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var urlButton: UIButton! {
		didSet {
			urlButton.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			separatorView.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
		}
	}
	var actionUrlItem: [String: String]? {
		didSet {
			configureCell()
		}
	}
	var separatorIsHidden = false
	var homeCollectionViewController: HomeCollectionViewController?

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let actionUrlItem = actionUrlItem else { return }

		urlButton.setTitle(actionUrlItem["title"], for: .normal)
		separatorView.isHidden = separatorIsHidden
	}

	// MARK: - IBActions
	@IBAction func urlButtonPressed(_ sender: UIButton) {
		if let kNavigationController = KWebViewController.instantiateFromStoryboard() as? KNavigationController {
			if let kWebViewController = kNavigationController.viewControllers.first as? KWebViewController {
				kWebViewController.url = actionUrlItem?["url"]
				kWebViewController.title = actionUrlItem?["title"]
			}

			homeCollectionViewController?.presentAsStork(kNavigationController, height: nil, showIndicator: false, showCloseButton: false)
		}
	}
}
