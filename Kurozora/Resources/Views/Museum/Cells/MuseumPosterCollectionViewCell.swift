//
//  MuseumPosterCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class MuseumPosterCollectionViewCell: UICollectionViewCell {
	// MARK: - Views
	/// The poster image view filling the cell.
	private let posterImageView = PosterImageView()

	/// The book texture drawn over a literature's poster.
	private let posterImageOverlayView = UIImageView(image: .bookTexture)

	// MARK: - Properties
	/// The book-cover mask applied to a literature's poster.
	private lazy var literatureMask: UIImageView = {
		let maskView = UIImageView(image: .bookMask)
		return maskView
	}()

	/// The observation keeping the book-cover mask sized to the poster.
	private var posterBoundsObservation: NSKeyValueObservation?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.syncLiteratureMaskFrame()
	}

	// MARK: - Functions
	/// The shared init of the cell.
	private func sharedInit() {
		self.contentView.clipsToBounds = true

		self.posterImageView.translatesAutoresizingMaskIntoConstraints = false
		self.posterImageView.contentMode = .scaleAspectFill
		self.posterImageView.clipsToBounds = true
		self.contentView.addSubview(self.posterImageView)

		self.posterBoundsObservation = self.posterImageView.observe(\.bounds, options: [.new]) { [weak self] _, _ in
			self?.syncLiteratureMaskFrame()
		}

		self.posterImageOverlayView.translatesAutoresizingMaskIntoConstraints = false
		self.posterImageOverlayView.contentMode = .scaleAspectFill
		self.posterImageOverlayView.isUserInteractionEnabled = false
		self.posterImageOverlayView.isHidden = true
		self.contentView.addSubview(self.posterImageOverlayView)

		NSLayoutConstraint.activate([
			self.posterImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.posterImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			self.posterImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.posterImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.posterImageOverlayView.topAnchor.constraint(equalTo: self.posterImageView.topAnchor),
			self.posterImageOverlayView.bottomAnchor.constraint(equalTo: self.posterImageView.bottomAnchor),
			self.posterImageOverlayView.leadingAnchor.constraint(equalTo: self.posterImageView.leadingAnchor),
			self.posterImageOverlayView.trailingAnchor.constraint(equalTo: self.posterImageView.trailingAnchor),
		])
	}

	/// Configures the cell with the given museum entry, or as a skeleton when absent.
	///
	/// - Parameters:
	///    - museumEntry: The `MuseumEntry` object used to configure the cell.
	///    - libraryKind: The library kind the museum entry belongs to.
	///    - isDimmed: Whether the poster is dimmed.
	func configure(using museumEntry: MuseumEntry?, libraryKind: LibraryKind, isDimmed: Bool = false) {
		self.setDimmed(isDimmed)
		self.posterImageView.image = nil

		guard let museumEntry = museumEntry else {
			self.posterImageView.mask = nil
			self.posterImageView.applyCornerRadius(10.0)
			self.posterImageOverlayView.isHidden = true
			self.posterImageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
			self.isAccessibilityElement = false
			self.accessibilityLabel = nil
			return
		}

		self.applyPosterStyle(for: libraryKind)

		if let backgroundColor = museumEntry.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		} else {
			self.posterImageView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}

		self.posterImageView.setImage(with: museumEntry.attributes.poster?.url ?? "", placeholder: .Placeholders.showPoster)
		self.isAccessibilityElement = true
		self.accessibilityLabel = museumEntry.attributes.title
	}

	/// Applies the corner radius and mask for the given library kind.
	///
	/// - Parameter libraryKind: The library kind that determines the poster style.
	private func applyPosterStyle(for libraryKind: LibraryKind) {
		switch libraryKind {
		case .shows:
			self.posterImageView.mask = nil
			self.posterImageView.applyCornerRadius(8.0)
			self.posterImageOverlayView.isHidden = true
		case .literatures:
			self.posterImageView.applyCornerRadius(0.0)
			self.literatureMask.frame = self.posterImageView.bounds
			self.posterImageView.mask = self.literatureMask
			self.posterImageOverlayView.isHidden = false
		case .games:
			self.posterImageView.mask = nil
			self.posterImageView.applyCornerRadius(24.0)
			self.posterImageOverlayView.isHidden = true
		}
	}

	/// Dims or restores the poster for library membership.
	///
	/// - Parameter isDimmed: Whether the poster is dimmed.
	func setDimmed(_ isDimmed: Bool) {
		self.contentView.alpha = isDimmed ? 0.25 : 1.0
	}

	/// Keeps the book-cover mask sized to the poster.
	private func syncLiteratureMaskFrame() {
		guard self.posterImageView.mask === self.literatureMask else { return }
		self.literatureMask.frame = self.posterImageView.bounds
	}
}
