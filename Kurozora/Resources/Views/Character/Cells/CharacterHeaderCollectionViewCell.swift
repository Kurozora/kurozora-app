//
//  CharacterHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class CharacterHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryImageView: CharacterImageView!
	@IBOutlet weak var primaryLabel: KLabel!

	// MARK: - Properties
	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure image view
		self.primaryImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.primaryImageView.addGestureRecognizer(posterTap)
	}

	// MARK: - functions
	/// Configure the cell with the given character object.
	///
	/// - Parameter character: The `Character` object used to configure the cell.
	func configure(using character: Character) {
		self.primaryLabel.text = character.attributes.name
		self.primaryImageView.setImage(with: character.attributes.profile?.url ?? "", placeholder: character.attributes.placeholderImage)
	}

	@objc private func didTapImage(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? UIImageView else { return }
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self, didTapImage: view, at: view.tag)
	}
}
