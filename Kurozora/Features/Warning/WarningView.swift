//
//  WarningView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

protocol WarningViewDelegate: AnyObject {
	func handleActionButtonPressed()
}

final class WarningView: UIView {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryImageView: UIImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var actionButton: KButton!

	// MARK: - Properties
	public weak var viewDelegate: WarningViewDelegate?

	// MARK: - XIB loaded
	override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	// MARK: - Display
	func setData(warningType: WarningType) {
		self.primaryImageView.image = warningType.image
		self.primaryLabel.text = warningType.title
		self.secondaryLabel.text = warningType.message
		self.actionButton.setTitle(warningType.buttonTitle, for: .normal)
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
		self.viewDelegate?.handleActionButtonPressed()
	}
}

// MARK: - Setup
private extension WarningView {
	func setup() {
		self.setupViews()
	}

	// MARK: - View setup
	func setupViews() {
		self.setupView()
	}

	func setupView() { }
}
