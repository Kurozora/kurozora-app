//
//  KotodamaImageHintView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaImageHintView: UIView {
	// MARK: - Properties
	/// The subject's image view, rebuilt to match the revealed kind's display shape.
	private var subjectImageView: UIImageView?

	/// The themed border drawn around the subject image, sized to match its shape.
	private var subjectBorderView: BorderView?

	/// The book-cover mask applied to a literature's poster.
	private var subjectMaskView: UIImageView?

	/// The constraints sizing and positioning the current subject image view and its border.
	private var subjectImageConstraints: [NSLayoutConstraint] = []

	/// The kind of the currently built image view, used to skip rebuilding when unchanged.
	private var subjectKind: KotodamaSubjectKind?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)

		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared init of the view.
	private func sharedInit() {
		self.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			self.heightAnchor.constraint(equalToConstant: 128)
		])
	}

	/// Configures the view with the subject's image and kind, when unlocked.
	///
	/// - Parameters:
	///    - posterURL: The url of the subject's image.
	///    - kind: The kind of the subject, used to pick the image's display shape.
	func configure(using posterURL: String?, kind: KotodamaSubjectKind?) {
		guard let posterURL = posterURL else {
			self.subjectImageView?.isHidden = true
			return
		}

		if self.subjectImageView == nil || self.subjectKind != kind {
			self.rebuildSubjectImageView(for: kind)
			self.subjectKind = kind
		}

		self.subjectImageView?.isHidden = false
		self.subjectImageView?.setImage(with: posterURL, placeholder: kind?.placeholderImage ?? .Placeholders.showPoster)
	}

	/// Rebuilds the subject image view to match the given kind's display shape.
	///
	/// - Parameter kind: The kind of the revealed subject.
	private func rebuildSubjectImageView(for kind: KotodamaSubjectKind?) {
		NSLayoutConstraint.deactivate(self.subjectImageConstraints)
		self.subjectImageConstraints.removeAll()
		self.subjectImageView?.removeFromSuperview()
		self.subjectBorderView?.removeFromSuperview()
		self.subjectMaskView = nil
		self.subjectBorderView = nil

		let imageView: UIImageView
		var borderCornerRadius: CGFloat?
		let width: CGFloat
		let height: CGFloat

		switch kind {
		case .shows, nil:
			imageView = PosterImageView()
			(width, height) = (96, 128)
			borderCornerRadius = 10
		case .literatures:
			let posterImageView = PosterImageView()
			posterImageView.applyCornerRadius(0)
			imageView = posterImageView
			(width, height) = (96, 128)
		case .games:
			let posterImageView = PosterImageView()
			posterImageView.applyCornerRadius(22)
			imageView = posterImageView
			(width, height) = (96, 96)
			borderCornerRadius = 22
		case .characters:
			imageView = CharacterImageView(frame: .zero)
			(width, height) = (96, 96)
			borderCornerRadius = 48
		case .people:
			imageView = PersonImageView(frame: .zero)
			(width, height) = (96, 96)
			borderCornerRadius = 48
		case .studios:
			imageView = StudioLogoImageView(frame: .zero)
			(width, height) = (96, 96)
			borderCornerRadius = 48
		case .songs:
			imageView = AlbumImageView()
			(width, height) = (96, 96)
			borderCornerRadius = 10
		}

		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		self.addSubview(imageView)
		self.subjectImageView = imageView

		self.subjectImageConstraints.append(contentsOf: [
			imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			imageView.widthAnchor.constraint(equalToConstant: width),
			imageView.heightAnchor.constraint(equalToConstant: height)
		])

		if kind == .literatures {
			let maskView = UIImageView(image: .bookMask)
			maskView.frame = CGRect(x: 0, y: 0, width: width, height: height)
			imageView.mask = maskView
			self.subjectMaskView = maskView
		}

		if let borderCornerRadius = borderCornerRadius {
			let borderView = BorderView()
			borderView.translatesAutoresizingMaskIntoConstraints = false
			borderView.cornerRadius = borderCornerRadius
			borderView.isUserInteractionEnabled = false
			self.addSubview(borderView)
			self.subjectBorderView = borderView

			self.subjectImageConstraints.append(contentsOf: [
				borderView.topAnchor.constraint(equalTo: imageView.topAnchor),
				borderView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
				borderView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
				borderView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
			])
		}

		NSLayoutConstraint.activate(self.subjectImageConstraints)
	}
}
