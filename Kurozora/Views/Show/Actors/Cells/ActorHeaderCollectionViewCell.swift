//
//  ActorHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ActorHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var actorImageView: ActorImageView!
	@IBOutlet weak var nameLabel: KLabel!

	// MARK: - Properties
	var actor: Actor! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		self.nameLabel.text = self.actor.attributes.fullName
		self.actorImageView.image = self.actor.attributes.personalImage
	}
}
