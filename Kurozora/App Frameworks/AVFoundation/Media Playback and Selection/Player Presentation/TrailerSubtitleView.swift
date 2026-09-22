//
//  TrailerSubtitleView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// An overlay drawing a trailer's subtitles along the bottom of its picture.
final class TrailerSubtitleView: UIView {
	// MARK: - Views
	/// The dark plate behind the text.
	private let plateView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		view.layer.cornerRadius = 6.0
		view.layer.cornerCurve = .continuous
		return view
	}()

	/// The subtitle text.
	private let textLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()

	// MARK: - Properties
	/// The aspect ratio of the picture the subtitles sit on.
	private static let pictureAspectRatio: CGFloat = 16.0 / 9.0

	// MARK: - Initializers
	init() {
		super.init(frame: .zero)

		self.isUserInteractionEnabled = false
		self.isHidden = true
		self.addSubview(self.plateView)
		self.plateView.addSubview(self.textLabel)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		let bounds = self.bounds
		guard bounds.width > 0.0, bounds.height > 0.0 else { return }

		let pictureWidth = min(bounds.width, bounds.height * Self.pictureAspectRatio)
		let pictureHeight = pictureWidth / Self.pictureAspectRatio
		let pictureBottom = (bounds.height + pictureHeight) / 2.0

		self.textLabel.font = .systemFont(ofSize: min(max(pictureWidth / 24.0, 11.0), 22.0), weight: .medium)

		let horizontalPadding: CGFloat = 12.0
		let verticalPadding: CGFloat = 6.0
		let textSize = self.textLabel.sizeThatFits(CGSize(width: pictureWidth * 0.9 - horizontalPadding * 2.0, height: pictureHeight))
		let plateSize = CGSize(width: textSize.width + horizontalPadding * 2.0, height: textSize.height + verticalPadding * 2.0)

		self.plateView.frame = CGRect(x: (bounds.width - plateSize.width) / 2.0, y: pictureBottom - plateSize.height - pictureHeight * 0.06, width: plateSize.width, height: plateSize.height)
		self.textLabel.frame = CGRect(x: horizontalPadding, y: verticalPadding, width: textSize.width, height: textSize.height)
	}

	// MARK: - Functions
	/// Shows the given line.
	///
	/// - Parameter text: The line to show.
	func showText(_ text: String?) {
		guard let text = text, !text.isEmpty else {
			self.isHidden = true
			return
		}

		guard self.isHidden || self.textLabel.text != text else { return }

		self.textLabel.text = text
		self.isHidden = false
		self.setNeedsLayout()
	}
}
