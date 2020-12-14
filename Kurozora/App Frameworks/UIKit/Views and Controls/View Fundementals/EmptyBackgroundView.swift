//
//  EmptyBackgroundView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

class EmptyBackgroundView: UIView {
	lazy var contentView: UIView = {
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.backgroundColor = UIColor.clear
		contentView.isUserInteractionEnabled = true
		contentView.alpha = 0
		return contentView
	}()

	lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.backgroundColor = UIColor.clear
		imageView.theme_tintColor = KThemePicker.subTextColor.rawValue
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = false
		imageView.accessibilityIdentifier = "empty set background image"
		self.contentView.addSubview(imageView)
		return imageView
	}()

	lazy var titleLabel: KLabel = {
		let titleLabel = KLabel()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.backgroundColor = UIColor.clear

		titleLabel.font = .preferredFont(forTextStyle: .headline)
		titleLabel.textAlignment = .center
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 0
		titleLabel.accessibilityIdentifier = "empty set title"
		self.contentView.addSubview(titleLabel)
		return titleLabel
	}()

	lazy var detailLabel: KSecondaryLabel = {
		let detailLabel = KSecondaryLabel()
		detailLabel.translatesAutoresizingMaskIntoConstraints = false
		detailLabel.backgroundColor = UIColor.clear

		detailLabel.font = .preferredFont(forTextStyle: .subheadline)
		detailLabel.textAlignment = .center
		detailLabel.lineBreakMode = .byWordWrapping
		detailLabel.numberOfLines = 0
		detailLabel.accessibilityIdentifier = "empty set detail label"
		self.contentView.addSubview(detailLabel)
		return detailLabel
	}()

	lazy var button: KButton = {
		let button = KButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = UIColor.clear
		button.contentHorizontalAlignment = .center
		button.contentVerticalAlignment = .center
		button.accessibilityIdentifier = "empty set button"

		self.contentView.addSubview(button)
		return button
	}()

	let verticalSpace = 8
	var didSetupConstraints = false
	var didTapButtonHandle: (() -> Void)?

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	init(image: UIImage?, titleString: String, detailString: String?, buttonTitle: String?, buttonAction: (() -> Void)?) {
		super.init(frame: .zero)
		setupView()
		if let image = image {
			setupImageView(image: image)
		}
		setupLabels(titleString: titleString, detailString: detailString)
		if let buttonTitle = buttonTitle {
			setupButton(buttonTitle: buttonTitle, buttonHandle: buttonAction)
		}
	}

	override public func didMoveToSuperview() {
		if let superviewBounds = superview?.bounds {
			frame = CGRect(x: 0, y: 0, width: superviewBounds.width, height: superviewBounds.height)
		}

		UIView.animate(withDuration: 0.25) {
			self.contentView.alpha = 1
		}
	}

	internal func removeAllConstraints() {
		removeConstraints(constraints)
		contentView.removeConstraints(contentView.constraints)
	}

	internal func prepareForReuse() {
		titleLabel.text = nil
		detailLabel.text = nil
		imageView.image = nil
		button.setImage(nil, for: .normal)
		button.setImage(nil, for: .highlighted)
		button.setAttributedTitle(nil, for: .normal)
		button.setAttributedTitle(nil, for: .highlighted)
		button.setBackgroundImage(nil, for: .normal)
		button.setBackgroundImage(nil, for: .highlighted)

		removeAllConstraints()
	}

	func setupView() {
		addSubview(contentView)
	}

	func setupImageView(image: UIImage) {
		imageView.image = image
	}

	func setupLabels(titleString: String, detailString: String?) {
		titleLabel.text = titleString
		detailLabel.text = detailString
	}

	func setupButton(buttonTitle: String, buttonHandle: (() -> Void)?) {
		button.setAttributedTitle(.init(string: buttonTitle), for: .normal)
		didTapButtonHandle = buttonHandle
		button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
	}

	@objc func didTapButton(_ sender: UIButton) {
		self.didTapButtonHandle?()
	}

	private var canShowImage: Bool {
		return imageView.image != nil
	}

	private var canShowTitle: Bool {
		if let attributedText = titleLabel.attributedText {
			return attributedText.length > 0
		}
		return false
	}

	private var canShowDetail: Bool {
		if let attributedText = detailLabel.attributedText {
			return attributedText.length > 0
		}
		return false
	}

	private var canShowButton: Bool {
		if let attributedTitle = button.attributedTitle(for: .normal) {
			return attributedTitle.length > 0
		} else if button.image(for: .normal) != nil {
			return true
		}

		return false
	}

	override func updateConstraints() {
		if !didSetupConstraints {
			// First, configure the content view constaints
			// The content view must alway be centered to its superview
			let centerXConstraint = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
			let centerYConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)

			self.addConstraints([centerXConstraint, centerYConstraint])
			self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": contentView]))

			let width = frame.width > 0 ? frame.width : UIScreen.main.bounds.width
			let padding = roundf(Float(width/16.0))

			var subviewStrings: [String] = []
			var views: [String: UIView] = [:]
			let metrics = ["padding": padding]

			// Assign the image view's horizontal constraints
			if canShowImage {
				imageView.isHidden = false

				subviewStrings.append("imageView")
				views[subviewStrings.last!] = imageView

				contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
			} else {
				imageView.isHidden = true
			}

			// Assign the title label's horizontal constraints
			if canShowTitle {
				titleLabel.isHidden = false
				subviewStrings.append("titleLabel")
				views[subviewStrings.last!] = titleLabel

				contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))
			} else {
				titleLabel.isHidden = true
			}

			// Assign the detail label's horizontal constraints
			if canShowDetail {
				detailLabel.isHidden = false
				subviewStrings.append("detailLabel")
				views[subviewStrings.last!] = detailLabel

				contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[detailLabel(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))
			} else {
				detailLabel.isHidden = true
			}

			// Assign the button's horizontal constraints
			if canShowButton {
				button.isHidden = false
				subviewStrings.append("button")
				views[subviewStrings.last!] = button

				contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[button(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))
			} else {
				button.isHidden = true
			}

			var verticalFormat = String()

			// Build a dynamic string format for the vertical constraints, adding a margin between each element. Default is 11 pts.
			for i in 0 ..< subviewStrings.count {
				let string = subviewStrings[i]
				verticalFormat += "[\(string)]"

				if i < subviewStrings.count - 1 {
					verticalFormat += "-(\(verticalSpace))-"
				}
			}

			// Assign the vertical constraints to the content view
			if !verticalFormat.isEmpty {
				contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|\(verticalFormat)|", options: [], metrics: metrics, views: views))
			}

			didSetupConstraints = true
		}

		super.updateConstraints()
	}
}
