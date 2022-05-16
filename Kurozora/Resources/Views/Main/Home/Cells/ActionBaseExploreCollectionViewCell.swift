//
//  ActionBaseExploreCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

protocol ActionBaseExploreCollectionViewCellDelegate: AnyObject {
	func actionButtonPressed(_ sender: UIButton, cell: ActionBaseExploreCollectionViewCell)
}

class ActionBaseExploreCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var actionButton: KButton?

	// MARK: - Properties
	weak var delegate: ActionBaseExploreCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configure(using quickAction: QuickAction) {
		self.actionButton?.setTitle(quickAction.title, for: .normal)
	}

	/// Configure the cell with the given details.
	func configure(using quickLink: QuickLink) {
		self.actionButton?.setTitle(quickLink.title, for: .normal)
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: UIButton) {
		self.delegate?.actionButtonPressed(sender, cell: self)
	}
}
