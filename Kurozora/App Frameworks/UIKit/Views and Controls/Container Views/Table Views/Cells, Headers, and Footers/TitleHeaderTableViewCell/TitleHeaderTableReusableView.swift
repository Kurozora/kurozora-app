//
//  TitleHeaderTableReusableView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol TitleHeaderTableReusableViewDelegate: AnyObject {
	func titleHeaderTableReusableView(_ reusableView: TitleHeaderTableReusableView, didPress button: UIButton)
}

class TitleHeaderTableReusableView: UITableViewHeaderFooterView {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var headerButton: HeaderButton!

	// MARK: - Properties
	static let reuseIdentifier = "TitleHeaderTableReusableView"
	weak var delegate: TitleHeaderTableReusableViewDelegate?
	private(set)var section: Int?

	// MARK: - Functions
	/// Configures the views in the resuable view.
	///
	/// - Parameters:
	///  - title: The title of the section.
	///  - subtitle: The subtitle of the section.
	///  - buttonTitle: The title of the button.
	///  - buttonIsHidden: Whether the button is shown.
	///  - section: The `Int` of the section.
	func configure(withTitle title: String? = nil, subtitle: String? = nil, buttonTitle: String? = nil, buttonIsHidden: Bool = false, section: Int? = nil) {
		self.section = section
		self.isUserInteractionEnabled = true

		// Configure labels
		self.primaryLabel.text = title
		self.secondaryLabel.text = subtitle

		// Configure button
		self.headerButton.setTitle(buttonTitle, for: .normal)
		self.headerButton.isHidden = buttonIsHidden
	}

	// MARK: - IBActions
	@IBAction func headerButtonPressed(_ sender: UIButton) {
		self.delegate?.titleHeaderTableReusableView(self, didPress: sender)
	}
}
