//
//  KUnderlinedLabel.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/04/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit

/// A custom UILabel that displays text with a stylized underline.
class KUnderlinedLabel: UILabel {
	// MARK: - Properties
	/// The height of the underlines.
	private let underlineHeight: CGFloat = 2.0

	/// The spacing between the underlines.
	private let underlineSpacing: CGFloat = 2.0

	/// The radius of the corner of the underlines.
	private let underlineRadius: CGFloat = 1.0

	/// The width of the second underline.
	private let secondUnderlineWidth: CGFloat = 15.0

	/// The width of the third underline.
	private let thirdUnderlineWidth: CGFloat = 5.0

	/// The diameter of the circles used in the label.
	private let circleDiameter: CGFloat = 2.5

	/// The horizontal spacing between the components of the label.
	private let horizontalSpace: CGFloat = 2.0

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

		guard let superview = self.superview else {
			return
		}

		let textRect = self.textRect(forBounds: self.bounds, limitedToNumberOfLines: self.numberOfLines)

		let firstUnderlineFrame = CGRect(
			x: self.frame.origin.x + textRect.origin.x,
			y: self.frame.origin.y + self.bounds.size.height + self.underlineSpacing,
			width: textRect.size.width,
			height: self.underlineHeight
		)

		let secondUnderlineFrame = CGRect(
			x: firstUnderlineFrame.origin.x + firstUnderlineFrame.size.width - self.secondUnderlineWidth,
			y: firstUnderlineFrame.origin.y + self.underlineHeight + self.underlineSpacing,
			width: self.secondUnderlineWidth,
			height: self.underlineHeight
		)

		let thirdUnderlineFrame = CGRect(
			x: secondUnderlineFrame.origin.x + secondUnderlineFrame.size.width + self.horizontalSpace * 2,
			y: firstUnderlineFrame.origin.y + self.underlineHeight + self.underlineSpacing,
			width: self.thirdUnderlineWidth,
			height: self.underlineHeight
		)

		let firstCircleFrame = CGRect(
			x: thirdUnderlineFrame.origin.x + thirdUnderlineFrame.size.width + self.horizontalSpace,
			y: thirdUnderlineFrame.origin.y - (self.circleDiameter - self.underlineHeight) / 2,
			width: self.circleDiameter,
			height: self.circleDiameter
		)

		let secondCircleFrame = CGRect(
			x: firstCircleFrame.origin.x + firstCircleFrame.size.width + self.horizontalSpace,
			y: thirdUnderlineFrame.origin.y - (self.circleDiameter - self.underlineHeight) / 2,
			width: self.circleDiameter,
			height: self.circleDiameter
		)

		for (tag, frame) in [
			(1, firstUnderlineFrame),
			(2, secondUnderlineFrame),
			(3, thirdUnderlineFrame),
			(4, firstCircleFrame),
			(5, secondCircleFrame),
		] {
			if let view = superview.subviews.first(where: { $0.tag == tag }) {
				view.frame = frame
				view.backgroundColor = self.textColor
			} else {
				let view = UIView(frame: frame)
				view.backgroundColor = self.textColor
				view.layerCornerRadius = tag == 4 || tag == 5 ? self.circleDiameter / 2 : self.underlineRadius
				view.tag = tag
				superview.addSubview(view)
			}
		}
	}

	// MARK: - Functions
	/// The shared settings used to initialize the label.
	func sharedInit() {
		self.font = .preferredFont(forTextStyle: .title2).bold
	}
}
