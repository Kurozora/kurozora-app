//
//  PersonHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class PersonHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryImageView: PersonImageView!
	@IBOutlet weak var primaryLabel: KLabel!

	// MARK: - Properties
	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure primary image view
		self.primaryImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.primaryImageViewPressed))
		self.primaryImageView.addGestureRecognizer(posterTap)
	}

	// MARK: - Functions
	/// Configure the cell with the given person object.
	///
	/// - Parameter person: The `Person` object used to configure the cell.
	func configure(using person: Person) {
		self.primaryLabel.text = person.attributes.fullName
		self.primaryImageView.setImage(with: person.attributes.profile?.url ?? "", placeholder: person.attributes.placeholderImage)
	}

	@objc private func primaryImageViewPressed(_ sender: UIImageView) {
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self, didTapImage: sender, at: 0)
	}
}
