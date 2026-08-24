//
//  BaseDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/01/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol BaseDetailHeaderCollectionViewCellDelegate: AnyObject {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async
}

class BaseDetailHeaderCollectionViewCell: UICollectionViewCell, MediaViewerHeaderCell {
	// MARK: - IBOutlet
	@IBOutlet var bannerImageView: UIImageView!
	@IBOutlet var visualEffectView: KVisualEffectView!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var rankButton: UIButton?
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var posterBorderView: BorderView?

	// MARK: - Properties
	weak var delegate: BaseDetailHeaderCollectionViewCellDelegate?
	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	// MARK: - Functions
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure visual effect
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.visualEffectView.effect = UIGlassEffect(style: .clear)
		}
		self.visualEffectView.layerCornerRadius = 30.0

		self.rankButton?.layerCornerRadius = 6.0

		// Configure poster
		self.posterImageView.tag = 0
		self.posterImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.posterImageView.addGestureRecognizer(posterTap)

		// Configure banner
		self.bannerImageView.tag = 1
		self.bannerImageView.isUserInteractionEnabled = true
		let bannerTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.bannerImageView.addGestureRecognizer(bannerTap)

		if #available(iOS 26.0, *) {
			self.extendHeaderMediaBeyondSafeArea()
		}
	}

	/// Fills the area the sidebar covers with a mirrored, blurred continuation of the
	/// header's media, leaving the media itself centered in the content area.
	@available(iOS 26.0, *)
	private func extendHeaderMediaBeyondSafeArea() {
		guard let container = self.bannerImageView.superview else { return }

		let bannerConstraints = container.constraints.filter { $0.firstItem === self.bannerImageView || $0.secondItem === self.bannerImageView }
		NSLayoutConstraint.deactivate(bannerConstraints)

		let extensionView = UIBackgroundExtensionView()
		extensionView.automaticallyPlacesContentView = false
		extensionView.translatesAutoresizingMaskIntoConstraints = false
		extensionView.isUserInteractionEnabled = true
		container.insertSubview(extensionView, at: container.subviews.firstIndex(of: self.bannerImageView) ?? 0)

		let mediaView = UIView()
		mediaView.translatesAutoresizingMaskIntoConstraints = false
		extensionView.contentView = mediaView
		mediaView.addSubview(self.bannerImageView)

		NSLayoutConstraint.activate([
			extensionView.topAnchor.constraint(equalTo: container.topAnchor),
			extensionView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
			extensionView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			extensionView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

			mediaView.topAnchor.constraint(equalTo: extensionView.topAnchor),
			mediaView.bottomAnchor.constraint(equalTo: extensionView.bottomAnchor),
			mediaView.leadingAnchor.constraint(equalTo: extensionView.safeAreaLayoutGuide.leadingAnchor),
			mediaView.trailingAnchor.constraint(equalTo: extensionView.safeAreaLayoutGuide.trailingAnchor),

			self.bannerImageView.topAnchor.constraint(equalTo: mediaView.topAnchor),
			self.bannerImageView.bottomAnchor.constraint(equalTo: mediaView.bottomAnchor),
			self.bannerImageView.leadingAnchor.constraint(equalTo: mediaView.leadingAnchor),
			self.bannerImageView.trailingAnchor.constraint(equalTo: mediaView.trailingAnchor)
		])
	}

	@objc private func didTapImage(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? UIImageView else { return }
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self, didTapImage: view, at: view.tag)
	}

	// MARK: - MediaViewerHeaderCell
	func imageView(at index: Int) -> UIImageView? {
		switch index {
		case 0: return self.posterImageView
		case 1: return self.bannerImageView
		default: return nil
		}
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressStatus: sender)
		}
	}
}
