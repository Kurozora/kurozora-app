//
//  KRichLinkView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 07/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import LinkPresentation
import UIKit

/// A lightweight, themed rich link preview that renders metadata using standard UIKit views
/// instead of `LPLinkView`. Eliminates WebKit overhead for smooth scroll performance.
class KRichLinkView: UIView {
	// MARK: - Properties
	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.layerCornerRadius = 6.0
		imageView.clipsToBounds = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.image = UIImage(systemName: "link")
		imageView.theme_tintColor = KThemePicker.textColor.rawValue
		return imageView
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.theme_textColor = KThemePicker.textColor.rawValue
		label.font = .preferredFont(forTextStyle: .subheadline).bold
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let hostLabel: UILabel = {
		let label = UILabel()
		label.theme_textColor = KThemePicker.subTextColor.rawValue
		label.font = .preferredFont(forTextStyle: .caption1)
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingMiddle
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let contentStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 2
		stack.alignment = .leading
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	// MARK: - Initializers
	init(metadata: LPLinkMetadata) {
		super.init(frame: .zero)
		self.configureLayout()
		self.configure(with: metadata)
	}

	/// Creates a rich link view in a loading state showing only the URL's host.
	/// Call `update(with:)` when metadata becomes available.
	init(url: URL) {
		super.init(frame: .zero)
		self.configureLayout()
		self.titleLabel.text = url.host
		self.hostLabel.text = url.absoluteString
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Updates the view in-place with fetched metadata. No height change.
	func update(with metadata: LPLinkMetadata) {
		self.configure(with: metadata)
	}

	private func configureLayout() {
		self.theme_backgroundColor = KThemePicker.blurBackgroundColor.rawValue
		self.layerCornerRadius = 10.0
		self.clipsToBounds = true

		self.addSubview(self.iconImageView)
		self.contentStack.addArrangedSubview(self.titleLabel)
		self.contentStack.addArrangedSubview(self.hostLabel)
		self.addSubview(self.contentStack)

		NSLayoutConstraint.activate([
			self.iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
			self.iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			self.iconImageView.widthAnchor.constraint(equalToConstant: 32),
			self.iconImageView.heightAnchor.constraint(equalToConstant: 32),

			self.contentStack.leadingAnchor.constraint(equalTo: self.iconImageView.trailingAnchor, constant: 10),
			self.contentStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
			self.contentStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
			self.contentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
		])
	}

	private func configure(with metadata: LPLinkMetadata) {
		self.titleLabel.text = metadata.title ?? metadata.url?.absoluteString
		self.hostLabel.text = metadata.url?.host

		// Load icon asynchronously from the metadata provider
		if let iconProvider = metadata.iconProvider {
			iconProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
				guard let image = image as? UIImage else { return }
				DispatchQueue.main.async {
					self?.iconImageView.image = image
				}
			}
		}
	}
}
