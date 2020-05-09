//
//  TitleHeaderReusableView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class TitleHeaderReusableView: UICollectionReusableView {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var subTitleHeader: KLabel?
	@IBOutlet weak var headerButton: HeaderButton!
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	static let reuseIdentifier = "TitleHeaderReusableView"
	var title: String? = nil {
		didSet {
			configureView()
		}
	}
	var segueID: String = ""
	var indexPath: IndexPath?

	// MARK: - Functions
	/// Configures the views in the resuable view.
	private func configureView() {
		// Configure title
		self.titleLabel.text = title

		// Show or hide see all button
		self.headerButton.isHidden = segueID.isEmpty
	}

	// MARK: - IBActions
	@IBAction func headerButtonPressed(_ sender: UIButton) {
		self.parentViewController?.performSegue(withIdentifier: segueID, sender: indexPath)
	}
}
