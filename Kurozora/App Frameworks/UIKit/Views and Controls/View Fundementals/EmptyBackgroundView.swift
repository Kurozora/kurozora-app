//
//  EmptyBackgroundView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	An object that manages the content for an empty view such as a table view or a collection view.
*/
class EmptyBackgroundView: UIView {
	// MARK: - Properties
	/// The property managing the content view.
	lazy var contentView: UIView = {
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.backgroundColor = UIColor.clear
		contentView.isUserInteractionEnabled = true
		return contentView
	}()

	/// The property managing the image view.
	lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.accessibilityIdentifier = "empty view image"
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.backgroundColor = UIColor.clear
		imageView.theme_tintColor = KThemePicker.subTextColor.rawValue
		imageView.contentMode = .scaleAspectFit
		imageView.isUserInteractionEnabled = false
		self.contentView.addSubview(imageView)
		return imageView
	}()

	/// The property managing the title label.
	lazy var titleLabel: KLabel = {
		let titleLabel = KLabel()
		titleLabel.accessibilityIdentifier = "empty view title"
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.backgroundColor = UIColor.clear
		titleLabel.font = .preferredFont(forTextStyle: .headline)
		titleLabel.textAlignment = .center
		titleLabel.lineBreakMode = .byWordWrapping
		titleLabel.numberOfLines = 0
		self.contentView.addSubview(titleLabel)
		return titleLabel
	}()

	/// The property managing the detail label.
	lazy var detailLabel: KSecondaryLabel = {
		let detailLabel = KSecondaryLabel()
		detailLabel.accessibilityIdentifier = "empty view detail"
		detailLabel.translatesAutoresizingMaskIntoConstraints = false
		detailLabel.backgroundColor = UIColor.clear
		detailLabel.font = .preferredFont(forTextStyle: .subheadline)
		detailLabel.textAlignment = .center
		detailLabel.lineBreakMode = .byWordWrapping
		detailLabel.numberOfLines = 0
		self.contentView.addSubview(detailLabel)
		return detailLabel
	}()

	/// The property managing the button.
	lazy var button: KButton = {
		let button = KButton()
		button.accessibilityIdentifier = "empty view button"
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .center
		button.contentVerticalAlignment = .center
		button.isHidden = true
		button.backgroundColor = UIColor.clear
		button.highlightBackgroundColorEnabled = true
		self.contentView.addSubview(button)
		return button
	}()

	/// Whether the image can be shown.
	fileprivate var canShowImage: Bool {
		return self.imageView.image != nil
	}

	/// Whether the title label can be shown.
	fileprivate var canShowTitle: Bool {
		if let attributedText = self.titleLabel.attributedText {
			return attributedText.length > 0
		}
		return false
	}

	/// Whether the detail label can be shown.
	fileprivate var canShowDetail: Bool {
		if let attributedText = self.detailLabel.attributedText {
			return attributedText.length > 0
		}
		return false
	}

	/// Whether the button can be shown.
	fileprivate var canShowButton: Bool {
		if let attributedTitle = self.button.attributedTitle(for: .normal) {
			return attributedTitle.length > 0
		} else if self.button.image(for: .normal) != nil {
			return true
		}

		return false
	}

	/// The vertical spacing between the image, label and button views.
	let verticalSpace = 8

	/// Whetehr the constraints are configured.
	var didConfigureConstraints = false

	/// The method to call when the button is tapped.
	var didTapButtonHandle: (() -> Void)?

	// MARK: - Initializers
	/**
		Initializes and returns a newly allocated view object with the specified data.

		The new view object must be inserted into the view hierarchy of a window before it can be used. If you create a view object programmatically, this method is the designated initializer for the `EmptyBackgroundView` class. Subclasses can override this method to perform any custom initialization but must call super at the beginning of their implementation.

		If you use Interface Builder to design your interface, this method is not called when your view objects are subsequently loaded from the nib file. Objects in a nib file are reconstituted and then initialized using their [init(coder:)](apple-reference-documentation://ls%2Fdocumentation%2Ffoundation%2Fnscoding%2F1416145-init) method, which modifies the attributes of the view to match the attributes stored in the nib file. For detailed information about how views are loaded from a nib file, see [Resource Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html#//apple_ref/doc/uid/10000051i).

		- Parameter image: An object that contains the image data you want to display.
		- Parameter title: The string you want to display as the title.
		- Parameter detail: The string you want to display as the detail.
		- Parameter buttonTitle: The string you want to display as the button's title.
		- Parameter buttonAction: The method you want to be called when the button is tapped.
	*/
	convenience init(image: UIImage?, title: String, detail: String?, buttonTitle: String?, buttonAction: (() -> Void)?) {
		self.init(frame: .zero)
		self.configureInitialView()
		if let image = image {
			self.configureImageView(image: image)
		}
		self.configureLabels(title: title, detail: detail)
		if let buttonTitle = buttonTitle {
			self.configureButton(title: buttonTitle, handler: buttonAction)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureInitialView()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.configureInitialView()
	}

	// MARK: - Functions
	/// Configures the initial view of the empty background view.
	fileprivate func configureInitialView() {
		self.addSubview(self.contentView)
	}

	/**
		Configures the image view with the given image object.

		- Parameter image: The object containing the image data to be displayed.
	*/
	func configureImageView(image: UIImage) {
		self.imageView.image = image

		if self.canShowImage {
			self.imageView.isHidden = false
		} else {
			self.imageView.isHidden = true
		}
	}

	/**
		Configures the labels with the given strings.

		- Parameter title: The string that will be displayed as the title.
		- Parameter detail: The string that will be displayed as the detail.
	*/
	func configureLabels(title: String, detail: String?) {
		self.titleLabel.text = title
		self.detailLabel.text = detail

		if self.canShowTitle {
			self.titleLabel.isHidden = false
		} else {
			self.titleLabel.isHidden = true
		}

		if self.canShowDetail {
			self.detailLabel.isHidden = false
		} else {
			self.detailLabel.isHidden = true
		}
	}

	/**
		Configures the button with the given data.

		- Parameter title: The string that will be displayed as the button's title.
		- Parameter handler: The method to be called when the button is tapped.
	*/
	func configureButton(title: String, handler: (() -> Void)?) {
		self.button.setAttributedTitle(.init(string: title), for: .normal)
		self.didTapButtonHandle = handler
		self.button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)

		if self.canShowButton {
			self.button.isHidden = false
		} else {
			self.button.isHidden = true
		}
	}

	/**
		Handles the method called when a button is pressed.

		- Parameter sender: The `UIButton` object calling the method.
	*/
	@objc func didTapButton(_ sender: UIButton) {
		self.didTapButtonHandle?()
	}

	override func updateConstraints() {
		if !didConfigureConstraints {
			// First, configure the content view constaints
			// The content view must alway be centered to its superview
			let centerXConstraint = NSLayoutConstraint(item: self.contentView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
			let centerYConstraint = NSLayoutConstraint(item: self.contentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)

			self.addConstraints([centerXConstraint, centerYConstraint])
			self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": self.contentView]))

			let width = frame.width > 0 ? frame.width : UIScreen.main.bounds.width
			let padding = roundf(Float(width/16.0))

			var subviewStrings: [String] = []
			var views: [String: UIView] = [:]
			let metrics = ["padding": padding]

			// Assign the image view's horizontal constraints
			subviewStrings.append("imageView")
			views[subviewStrings.last!] = self.imageView
			self.contentView.addConstraint(NSLayoutConstraint.init(item: self.imageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))

			// Assign the title label's horizontal constraints
			subviewStrings.append("titleLabel")
			views[subviewStrings.last!] = self.titleLabel
			self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[titleLabel(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))

			// Assign the detail label's horizontal constraints
			subviewStrings.append("detailLabel")
			views[subviewStrings.last!] = self.detailLabel
			self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[detailLabel(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))

			// Assign the button's horizontal constraints
			subviewStrings.append("button")
			views[subviewStrings.last!] = self.button
			self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[button(>=0)]-(padding)-|", options: [], metrics: metrics, views: views))

			// Build a dynamic string format for the vertical constraints, adding a margin between each element.
			var verticalFormat = String()
			for i in 0 ..< subviewStrings.count {
				let string = subviewStrings[i]
				verticalFormat += "[\(string)]"

				if i < subviewStrings.count - 1 {
					verticalFormat += "-(\(self.verticalSpace))-"
				}
			}

			// Assign the vertical constraints to the content view
			if !verticalFormat.isEmpty {
				self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|\(verticalFormat)|", options: [], metrics: metrics, views: views))
			}

			self.didConfigureConstraints = true
		}

		super.updateConstraints()
	}
}
