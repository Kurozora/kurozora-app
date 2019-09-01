//
//  ShowCharacterCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

protocol ShowCharacterCellDelegate: class {
	func presentPhoto(withString string: String, from imageView: UIImageView)
	func presentPhoto(withUrl url: String, from imageView: UIImageView)
}

class ShowCharacterCell: UITableViewCell {
	//    @IBOutlet weak var characterImageView: CachedImageView!
	//    @IBOutlet weak var characterName: UILabel!
	//    @IBOutlet weak var characterRole: UILabel!

	@IBOutlet weak var actorImageView: UIImageView!
	@IBOutlet weak var actorShadowView: UIView!
	@IBOutlet weak var actorName: KLabel! {
		didSet {
			self.actorName.theme_textColor = KThemePicker.tintColor.rawValue
			self.actorName.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var actorJob: KLabel! {
		didSet {
			self.actorJob.theme_textColor = KThemePicker.textColor.rawValue
			self.actorJob.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			self.separatorView.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
		}
	}

	var actorElement: ActorsElement? = nil {
		didSet {
			configureCell()
		}
	}
	weak var delegate: ShowCharacterCellDelegate?

	fileprivate func configureCell() {
		guard let actorElement = actorElement else { return }

		// Actor name
		if let actorName = actorElement.name {
			self.actorName.text = actorName
		}

		// Actor role
		if let actorRole = actorElement.role {
			self.actorJob.text = actorRole
		}

		// Actor image view
		if let actorImage = actorElement.image, !actorImage.isEmpty {
			let actorImageUrl = URL(string: actorImage)
			let resource = ImageResource(downloadURL: actorImageUrl!)
			self.actorImageView.kf.indicatorType = .activity
			self.actorImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_person"), options: [.transition(.fade(0.2))])
		} else {
			self.actorImageView.image = #imageLiteral(resourceName: "placeholder_person")
		}

		// Actor shadow view
		self.actorShadowView.applyShadow()

		// Add gesture to actors image view
		if self.actorImageView.gestureRecognizers?.count ?? 0 == 0 {
			// if the image currently has no gestureRecognizer
			self.actorImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCast(_:))))
			self.actorImageView.isUserInteractionEnabled = true
		}
	}

	@objc func showCast(_ tap: UITapGestureRecognizer) {
		guard let actorElement = actorElement else { return }

		if let imageUrl = actorElement.image, !imageUrl.isEmpty {
			delegate?.presentPhoto(withUrl: imageUrl, from: actorImageView)
		} else {
			delegate?.presentPhoto(withString: "placeholder_person", from: actorImageView)
		}
	}
}

class ShowCharacterCollectionCell: UICollectionViewCell {
	//    @IBOutlet weak var characterImageView: CachedImageView!
	//    @IBOutlet weak var characterName: UILabel!
	//    @IBOutlet weak var characterRole: UILabel!

	@IBOutlet weak var actorImageView: UIImageView!
	@IBOutlet weak var actorShadowView: UIView!
	@IBOutlet weak var actorName: KLabel! {
		didSet {
			self.actorName.theme_textColor = KThemePicker.tintColor.rawValue
			self.actorName.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var actorJob: KLabel! {
		didSet {
			self.actorJob.theme_textColor = KThemePicker.textColor.rawValue
			self.actorJob.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var separatorView: UIView! {
		didSet {
			self.separatorView.theme_backgroundColor = KThemePicker.separatorColorLight.rawValue
		}
	}

	var actorElement: ActorsElement? {
		didSet {
			configureCell()
		}
	}
	weak var delegate: ShowCharacterCellDelegate?

	fileprivate func configureCell() {
		guard let actorElement = actorElement else { return }

		if let actorName = actorElement.name {
			self.actorName.text = actorName
		}

		if let actorRole = actorElement.role {
			self.actorJob.text = actorRole
		}

		if let actorImage = actorElement.image, !actorImage.isEmpty {
			let actorImageUrl = URL(string: actorImage)
			let resource = ImageResource(downloadURL: actorImageUrl!)
			self.actorImageView.kf.indicatorType = .activity
			self.actorImageView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_person"), options: [.transition(.fade(0.2))])
		} else {
			self.actorImageView.image = #imageLiteral(resourceName: "placeholder_person")
		}

		// Actor shadow view
		self.actorShadowView.applyShadow()

		// Add gesture to actors image view
		if self.actorImageView.gestureRecognizers?.count ?? 0 == 0 {
			// if the image currently has no gestureRecognizer
			self.actorImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCast(_:))))
			self.actorImageView.isUserInteractionEnabled = true
		}
	}

	@objc func showCast(_ tap: UITapGestureRecognizer) {
		guard let actorElement = actorElement else { return }

		if let imageUrl = actorElement.image, !imageUrl.isEmpty {
			delegate?.presentPhoto(withUrl: imageUrl, from: actorImageView)
		} else {
			delegate?.presentPhoto(withString: "placeholder_person", from: actorImageView)
		}
	}
}
