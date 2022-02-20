//
//  TitleHeaderCollectionReusableView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var subTitleHeader: KSecondaryLabel!
	@IBOutlet weak var headerButton: HeaderButton!
	@IBOutlet weak var separatorView: SeparatorView!

	// MARK: - Properties
	static let reuseIdentifier = "TitleHeaderCollectionReusableView"
	weak var delegate: TitleHeaderCollectionReusableViewDelegate?
	private(set)var segueID: String = ""
	private(set)var indexPath: IndexPath?

	// MARK: - Functions
	/// Configures the views in the resuable view.
	///
	/// - Parameters:
	///  - title: The title of the section.
	///  - subtitle: The subtitle of the section.
	///  - indexPath: The `IndexPath` of the section.
	///  - segueID: The ID that should be used for the segue when pressing the header button.
	func configure(withTitle title: String? = nil, _ subtitle: String? = nil, indexPath: IndexPath? = nil, segueID: String = "") {
		self.segueID = segueID
		self.indexPath = indexPath

		// Configure title
		self.titleLabel.text = title
		self.subTitleHeader.text = subtitle

		// Show or hide see all button
		self.headerButton.isHidden = segueID.isEmpty
	}

	// MARK: - IBActions
	@IBAction func headerButtonPressed(_ sender: UIButton) {
		self.delegate?.titleHeaderCollectionReusableView(self, didPressButton: sender)
	}
}
