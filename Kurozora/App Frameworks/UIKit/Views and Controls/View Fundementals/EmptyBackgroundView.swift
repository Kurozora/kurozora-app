//
//  EmptyBackgroundView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/// An object that manages the content for an empty view such as a table view or a collection view.
class EmptyBackgroundView: UIView {
	// MARK: - Properties
	/// The property managing the content view.
	lazy var contentView: UIView = {
		let contentView = UIView()
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.backgroundColor = .clear
		contentView.isUserInteractionEnabled = true
		return contentView
	}()

	/// The property managing the image view.
	lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.accessibilityIdentifier = "empty view image"
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.backgroundColor = .clear
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
		titleLabel.backgroundColor = .clear
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
		detailLabel.backgroundColor = .clear
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
		button.backgroundColor = .clear
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

	/// The point size at which symbol images are drawn, matching the placeholder artwork.
	private let symbolPointSize: CGFloat = 100

	/// The vertical offset applied to the centered content.
	var verticalOffset: CGFloat = 0.0 {
		didSet {
			guard self.verticalOffset != oldValue else { return }
			self.contentViewCenterYConstraint?.constant = self.verticalOffset
		}
	}

	/// The constraint centering the content view vertically.
	private var contentViewCenterYConstraint: NSLayoutConstraint?

	/// Whether the constraints are configured.
	var didConfigureConstraints = false

	/// The method to call when the button is tapped.
	var didTapButtonHandle: (() -> Void)?

	// MARK: - Initializers
	/// Initializes and returns a newly allocated view object with the specified data.
	///
	/// The new view object must be inserted into the view hierarchy of a window before it can be used. If you create a view object programmatically, this method is the designated initializer for the `EmptyBackgroundView` class. Subclasses can override this method to perform any custom initialization but must call super at the beginning of their implementation.
	///
	/// If you use Interface Builder to design your interface, this method is not called when your view objects are subsequently loaded from the nib file. Objects in a nib file are reconstituted and then initialized using their [init(coder:)](apple-reference-documentation://ls%2Fdocumentation%2Ffoundation%2Fnscoding%2F1416145-init) method, which modifies the attributes of the view to match the attributes stored in the nib file. For detailed information about how views are loaded from a nib file, see [Resource Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Introduction/Introduction.html#//apple_ref/doc/uid/10000051i).
	///
	/// - Parameters:
	///    - image: An object that contains the image data you want to display.
	///    - title: The string you want to display as the title.
	///    - detail: The string you want to display as the detail.
	///    - buttonTitle: The string you want to display as the button's title.
	///    - buttonAction: The method you want to be called when the button is tapped.
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

	/// Configures the image view with the given image object.
	///
	/// Symbols are drawn at the placeholder point size, while artwork keeps its own size.
	///
	/// - Parameter image: The object containing the image data to be displayed.
	func configureImageView(image: UIImage) {
		// Symbols arrive sized for body text, which is far too small to carry an empty state.
		self.imageView.preferredSymbolConfiguration = image.isSymbolImage ? UIImage.SymbolConfiguration(pointSize: self.symbolPointSize) : nil
		self.imageView.image = image

		self.imageView.isHidden = !self.canShowImage
	}

	/// Configures the labels with the given strings.
	///
	/// - Parameters:
	///    - title: The string that will be displayed as the title.
	///    - detail: The string that will be displayed as the detail.
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

	/// Configures the button with the given data.
	///
	/// - Parameters:
	///    - title: The string that will be displayed as the button's title.
	///    - handler: The method to be called when the button is tapped.
	func configureButton(title: String, handler: (() -> Void)?) {
		self.button.setAttributedTitle(.init(string: title), for: .normal)
		self.didTapButtonHandle = handler
		self.button.addTarget(self, action: #selector(self.didTapButton(_:)), for: .touchUpInside)

		if self.canShowButton {
			self.button.isHidden = false
		} else {
			self.button.isHidden = true
		}
	}

	/// Handles the method called when a button is pressed.
	///
	/// - Parameter sender: The `UIButton` object calling the method.
	@objc func didTapButton(_ sender: UIButton) {
		self.didTapButtonHandle?()
	}

	override func updateConstraints() {
		if !self.didConfigureConstraints {
			// Center the content to the layout margins guide, so it responds to sidebars and other insets.
			let layoutMarginsGuide = self.layoutMarginsGuide
			self.contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
			self.contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true

			let contentViewCenterYConstraint = self.contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: self.verticalOffset)
			contentViewCenterYConstraint.isActive = true
			self.contentViewCenterYConstraint = contentViewCenterYConstraint

			let width = frame.width > 0 ? frame.width : UIScreen.main.bounds.width
			let padding = (width / 16.0).rounded()

			// Center the image while the text elements inset from the content view's edges.
			self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true

			let insetSubviews: [UIView] = [self.titleLabel, self.detailLabel, self.button]
			for subview in insetSubviews {
				subview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: padding).isActive = true
				subview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -padding).isActive = true
			}

			// Stack the elements top to bottom, separated by the vertical space.
			let stackedSubviews: [UIView] = [self.imageView, self.titleLabel, self.detailLabel, self.button]
			var previousSubview: UIView?

			for subview in stackedSubviews {
				if let previousSubview = previousSubview {
					subview.topAnchor.constraint(equalTo: previousSubview.bottomAnchor, constant: CGFloat(self.verticalSpace)).isActive = true
				} else {
					subview.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
				}

				previousSubview = subview
			}

			previousSubview?.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

			self.didConfigureConstraints = true
		}

		super.updateConstraints()
	}
}
