//
//  KotodamaHintRowView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol KotodamaHintRowViewDelegate: AnyObject {
	/// Tells the delegate that the subject's thumbnail was pressed.
	func kotodamaHintRowViewDidPressThumbnail(_ hintRowView: KotodamaHintRowView)
}

/// The row carrying the answer's hints, the subject's thumbnail and messages about the current guess.
class KotodamaHintRowView: UIView {
	// MARK: - Views
	private let contentStackView = UIStackView()
	private let thumbnailContainerView = UIView()
	private let textLabel = UILabel()

	// MARK: - Properties
	/// The object that acts as the delegate of the hint row.
	weak var delegate: KotodamaHintRowViewDelegate?

	/// The height of the row at the default text size.
	static let height: CGFloat = 88

	/// The height of the subject's thumbnail.
	static let thumbnailSide: CGFloat = 64

	/// The height of the row at the current text size.
	private var scaledHeight: CGFloat {
		return max(Self.height, UIFontMetrics(forTextStyle: .footnote).scaledValue(for: Self.height))
	}

	/// The subject's thumbnail.
	private var thumbnailImageView: UIImageView?

	/// The themed border drawn around the thumbnail.
	private var thumbnailBorderView: BorderView?

	/// The book-cover mask applied to a literature's poster.
	private var thumbnailMaskView: UIImageView?

	/// The constraints sizing the thumbnail and its border.
	private var thumbnailConstraints: [NSLayoutConstraint] = []

	/// The kind of the thumbnail on screen.
	private var thumbnailKind: KotodamaSubjectKind?

	/// The url of the image the thumbnail holds.
	private var renderedPosterURL: String?

	/// The hint describing the answer's subject.
	private var hint: String?

	/// The second hint describing the answer's subject.
	private var secondaryHint: String?

	/// The url of the subject's image.
	private var posterURL: String?

	/// The kind of the answer's subject.
	private var kind: KotodamaSubjectKind?

	/// The constraint reserving the row's height.
	private var heightConstraint: NSLayoutConstraint?

	/// The message about the current guess.
	private var message: String?

	/// The view holding the subject's thumbnail.
	var thumbnailView: UIImageView? {
		return self.thumbnailImageView
	}

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
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard self.traitCollection.preferredContentSizeCategory
			!= previousTraitCollection?.preferredContentSizeCategory else { return }

		self.heightConstraint?.constant = self.scaledHeight
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.thumbnailContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.thumbnailContainerView.isHidden = true
		self.thumbnailContainerView.addGestureRecognizer(
			UITapGestureRecognizer(target: self, action: #selector(self.thumbnailPressed))
		)

		self.textLabel.translatesAutoresizingMaskIntoConstraints = false
		self.textLabel.textAlignment = .natural
		self.textLabel.numberOfLines = 2
		self.textLabel.font = .preferredFont(forTextStyle: .footnote)
		self.textLabel.adjustsFontForContentSizeCategory = true
		self.textLabel.theme_textColor = KThemePicker.subTextColor.rawValue

		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.axis = .horizontal
		self.contentStackView.alignment = .center
		self.contentStackView.spacing = 10
		self.contentStackView.addArrangedSubview(self.thumbnailContainerView)
		self.contentStackView.addArrangedSubview(self.textLabel)
		self.addSubview(self.contentStackView)

		let heightConstraint = self.heightAnchor.constraint(equalToConstant: self.scaledHeight)
		self.heightConstraint = heightConstraint

		NSLayoutConstraint.activate([
			heightConstraint,
			self.contentStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.contentStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.contentStackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
			self.contentStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
			self.thumbnailContainerView.heightAnchor.constraint(equalToConstant: Self.thumbnailSide)
		])
	}

	/// Configures the row with the hints and the subject's image.
	///
	/// - Parameters:
	///    - hint: The hint describing the answer's subject.
	///    - secondaryHint: The second hint describing the answer's subject.
	///    - posterURL: The url of the subject's image.
	///    - kind: The kind of the answer's subject.
	func configure(hint: String?, secondaryHint: String?, posterURL: String?, kind: KotodamaSubjectKind?) {
		self.hint = hint
		self.secondaryHint = secondaryHint
		self.posterURL = posterURL
		self.kind = kind

		self.render()
	}

	/// Shows a message about the current guess.
	///
	/// - Parameter message: The message to show.
	func show(message: String?) {
		guard self.message != message else { return }

		self.message = message

		self.render()
	}

	/// Draws the row's current contents.
	private func render() {
		let showsThumbnail = self.message == nil && self.posterURL != nil
		let hints = [self.hint, self.secondaryHint].compactMap { $0 }
		let text = self.message ?? (hints.isEmpty ? nil : hints.joined(separator: "\n"))

		if showsThumbnail, let posterURL = self.posterURL {
			if self.thumbnailImageView == nil || self.thumbnailKind != self.kind {
				self.rebuildThumbnail(for: self.kind)
				self.thumbnailKind = self.kind
				self.renderedPosterURL = nil
			}

			if self.renderedPosterURL != posterURL {
				self.renderedPosterURL = posterURL
				self.thumbnailImageView?.setImage(
					with: posterURL,
					placeholder: self.kind?.placeholderImage ?? .Placeholders.showPoster
				)
			}
		}

		let didChangeText = self.textLabel.text != text
		let didChangeThumbnail = !self.thumbnailContainerView.isHidden != showsThumbnail

		self.textLabel.numberOfLines = showsThumbnail ? 3 : 4
		self.textLabel.text = text
		self.thumbnailContainerView.isHidden = !showsThumbnail

		guard text != nil, didChangeText || didChangeThumbnail else { return }

		self.contentStackView.alpha = 0
		UIView.animate(withDuration: 0.25) {
			self.contentStackView.alpha = 1
		}
	}

	/// Notifies the delegate that the thumbnail was pressed.
	@objc private func thumbnailPressed() {
		guard !self.thumbnailContainerView.isHidden else { return }

		self.delegate?.kotodamaHintRowViewDidPressThumbnail(self)
	}

	/// Rebuilds the thumbnail for the given kind.
	///
	/// - Parameter kind: The kind of the revealed subject.
	private func rebuildThumbnail(for kind: KotodamaSubjectKind?) {
		NSLayoutConstraint.deactivate(self.thumbnailConstraints)
		self.thumbnailConstraints.removeAll()
		self.thumbnailImageView?.removeFromSuperview()
		self.thumbnailBorderView?.removeFromSuperview()
		self.thumbnailMaskView = nil
		self.thumbnailBorderView = nil

		let side = Self.thumbnailSide
		let imageView: UIImageView
		var borderCornerRadius: CGFloat?
		let width: CGFloat

		switch kind {
		case .shows, nil:
			imageView = PosterImageView()
			width = side * 0.75
			borderCornerRadius = 8
		case .literatures:
			let posterImageView = PosterImageView()
			posterImageView.applyCornerRadius(0)
			imageView = posterImageView
			width = side * 0.75
		case .games:
			let posterImageView = PosterImageView()
			posterImageView.applyCornerRadius(14)
			imageView = posterImageView
			width = side
			borderCornerRadius = 14
		case .characters:
			imageView = CharacterImageView(frame: .zero)
			width = side
			borderCornerRadius = side / 2
		case .people:
			imageView = PersonImageView(frame: .zero)
			width = side
			borderCornerRadius = side / 2
		case .studios:
			imageView = StudioLogoImageView(frame: .zero)
			width = side
			borderCornerRadius = side / 2
		case .songs:
			imageView = AlbumImageView()
			width = side
			borderCornerRadius = 8
		}

		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		self.thumbnailContainerView.addSubview(imageView)
		self.thumbnailImageView = imageView

		self.thumbnailConstraints.append(contentsOf: [
			imageView.centerYAnchor.constraint(equalTo: self.thumbnailContainerView.centerYAnchor),
			imageView.leadingAnchor.constraint(equalTo: self.thumbnailContainerView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: self.thumbnailContainerView.trailingAnchor),
			imageView.widthAnchor.constraint(equalToConstant: width),
			imageView.heightAnchor.constraint(equalToConstant: side)
		])

		if kind == .literatures {
			let maskView = UIImageView(image: .bookMask)
			maskView.frame = CGRect(x: 0, y: 0, width: width, height: side)
			imageView.mask = maskView
			self.thumbnailMaskView = maskView
		}

		if let borderCornerRadius = borderCornerRadius {
			let borderView = BorderView()
			borderView.translatesAutoresizingMaskIntoConstraints = false
			borderView.cornerRadius = borderCornerRadius
			borderView.isUserInteractionEnabled = false
			self.thumbnailContainerView.addSubview(borderView)
			self.thumbnailBorderView = borderView

			self.thumbnailConstraints.append(contentsOf: [
				borderView.topAnchor.constraint(equalTo: imageView.topAnchor),
				borderView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
				borderView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
				borderView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
			])
		}

		NSLayoutConstraint.activate(self.thumbnailConstraints)
	}
}
