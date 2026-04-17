//
//  ProfileHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ProfileHeaderCollectionViewCell: UICollectionViewCell, MediaViewerHeaderCell {
	// MARK: - IBOutlets
	@IBOutlet weak var bannerImageView: BannerImageView!
	@IBOutlet weak var primaryImageView: CircularImageView!
	@IBOutlet weak var labelStackView: UIStackView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!

	// MARK: - Properties
	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		// Tap gestures
		self.primaryImageView.tag = 0
		self.primaryImageView.isUserInteractionEnabled = true
		let primaryTap = UITapGestureRecognizer(target: self, action: #selector(self.imageViewPressed))
		self.primaryImageView.addGestureRecognizer(primaryTap)

		self.bannerImageView.tag = 1
		self.bannerImageView.isUserInteractionEnabled = true
		self.bannerImageView.layer.borderWidth = 0
		self.bannerImageView.applyCornerRadius(0)
		let bannerTap = UITapGestureRecognizer(target: self, action: #selector(self.imageViewPressed))
		self.bannerImageView.addGestureRecognizer(bannerTap)

		// Banner fade
		self.bannerImageView.applyGradientMask(.bottomFade())

		self.primaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.secondaryLabel.theme_textColor = KThemePicker.subTextColor.rawValue
	}

	// MARK: - Configure
	/// Configure the cell with the given person details.
	///
	/// - Parameter person: The person object used to configure the cell.
	func configure(using person: Person) {
		self.primaryLabel.text = person.attributes.fullName
		self.setSecondaryText(nil)

		self.applyBannerBackground(hex: person.attributes.profile?.backgroundColor)
		self.bannerImageView.image = nil

		person.attributes.profileImage(imageView: self.primaryImageView)
	}

	/// Configure the cell with the given character details.
	///
	/// - Parameter character: The character object used to configure the cell.
	func configure(using character: Character) {
		self.primaryLabel.text = character.attributes.name
		self.setSecondaryText(nil)

		self.applyBannerBackground(hex: character.attributes.profile?.backgroundColor)
		self.bannerImageView.image = nil

		character.attributes.profileImage(imageView: self.primaryImageView)
	}

	/// Configure the cell with the given studio details.
	///
	/// - Parameter studio: The studio object used to configure the cell.
	func configure(using studio: Studio) {
		self.primaryLabel.text = studio.attributes.name

		if let foundingYear = studio.attributes.foundedAt {
			self.setSecondaryText(Trans.foundedOn(date: foundingYear.formatted(date: .abbreviated, time: .omitted)))
		} else {
			self.setSecondaryText(nil)
		}

		self.applyBannerBackground(hex: studio.attributes.banner?.backgroundColor)
		studio.attributes.bannerImage(imageView: self.bannerImageView)

		if studio.attributes.profile != nil {
			studio.attributes.profileImage(imageView: self.primaryImageView)
		} else {
			studio.attributes.logoImage(imageView: self.primaryImageView)
		}
	}

	// MARK: - Helpers
	private func applyBannerBackground(hex: String?) {
		if let hex = hex, let color = UIColor(hexString: hex) {
			self.bannerImageView.backgroundColor = color
		} else {
			self.bannerImageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	private func setSecondaryText(_ text: String?) {
		self.secondaryLabel.text = text
		let hasText = !(text?.isEmpty ?? true)
		self.secondaryLabel.isHidden = !hasText
	}

	// MARK: - Actions
	@objc private func imageViewPressed(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? UIImageView else { return }
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self, didTapImage: view, at: view.tag)
	}

	// MARK: - MediaViewerHeaderCell
	func imageView(at index: Int) -> UIImageView? {
		switch index {
		case 0: return self.primaryImageView
		case 1: return self.bannerImageView
		default: return nil
		}
	}

	// MARK: - Navigation appearance
	/// Configures a navigation item so its nav bar is transparent (background
	/// hidden, title text clear) when the scroll edge is at the top, and falls
	/// back to the inherited themed `standardAppearance` as the user scrolls.
	///
	/// Call from `viewDidLoad` of a controller that hosts a
	/// `ProfileHeaderCollectionViewCell` as the first visible cell.
	///
	/// - Parameter navigationItem: The navigation item to configure.
	static func configureTransparentNavigationAppearance(on navigationItem: UINavigationItem) {
		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		// Explicitly suppress the background effect. `configureWithTransparentBackground`
		// on iOS 26 still lights up the Liquid Glass material at the scroll
		// edge; nulling the effect keeps the nav bar truly invisible at top.
		appearance.backgroundEffect = nil
		appearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
		navigationItem.scrollEdgeAppearance = appearance
		navigationItem.largeTitleDisplayMode = .never
	}
}
