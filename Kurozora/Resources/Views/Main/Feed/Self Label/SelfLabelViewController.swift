//
//  SelfLabelViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/11/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit

enum SelfLabel: String, CaseIterable {
	case spoiler
	case nsfw
	case both

	/// The string value of the self label.
	var stringValue: String {
		switch self {
		case .spoiler:
			return "Spoiler"
		case .nsfw:
			return "NSFW"
		case .both:
			return "Both"
		}
	}
}

protocol SelfLabelViewDelegate: AnyObject {
	func selectedOptionChanged(_ option: SelfLabel?)
}

class SelfLabelViewController: KViewController {
	// MARK: - Views
	private var containerView: UIView!
	private var contentStackView: UIStackView!
	private var titleLabel: KLabel!
	private var subtitleLabel: KLabel!
	private var labelSegmentedControl: DeselectableSegmentedControl!
	private var spacerView: UIView!
	private var primaryButton: KTintedButton!
	private var viewWidthConstraint: NSLayoutConstraint!

	// MARK: - Properties
	let options: [SelfLabel] = SelfLabel.allCases
	var selectedOption: SelfLabel? {
		didSet {
			guard self.isViewLoaded else { return }
			self.updateSelectedOption()
		}
	}

	weak var delegate: SelfLabelViewDelegate?

//	override var modalPresentationStyle: UIModalPresentationStyle {
//		get {
//			return UIDevice.isPhone ? .pageSheet : .popover
//		}
//		set {
//			super.modalPresentationStyle = newValue
//		}
//	}

	override var preferredContentSize: CGSize {
		get {
			return self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		}
		set {
			super.preferredContentSize = newValue
		}
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if UIDevice.isPhone {
			if #available(iOS 16.0, *) {
				self.sheetPresentationController?.detents = [
					.custom { [weak self] _ in
						guard let self = self else { return nil }
						return self.preferredContentSize.height - self.view.safeAreaInsets.bottom
					}
				]
			} else {
				self.sheetPresentationController?.detents = [.medium()]
			}

			self.sheetPresentationController?.prefersGrabberVisible = true
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureView()

		self.titleLabel.text = "Add a content warning"
		self.subtitleLabel.text = "Choose self-labels that are applicable for the media you are posting. If none are selected, this post is suitable for all audiences."
		self.labelSegmentedControl.segmentTitles = self.options.map { selfLabel in
			selfLabel.stringValue
		}

		self.updateSelectedOption()
		self.labelSegmentedControl.theme_tintColor = KThemePicker.tintColor.rawValue

		self.updateWidthConstraint()
	}

	// MARK: Trait
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		self.updateWidthConstraint()
	}

	private func updateWidthConstraint() {
		if let presentingViewController = self.presentingViewController, presentingViewController.view.bounds.width == self.view.bounds.width {
			self.viewWidthConstraint.constant = self.view.bounds.width
		} else {
			// iPad seems to subtract 60 points from the specified width.
			// By adding 60 points before we calculate the width,
			// the total width ends up being 300 points just like on
			// Macs.
			self.viewWidthConstraint.constant = UIDevice.isPad ? 360.0 : 300.0
		}
	}

	// MARK: Functions
	private func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
	}

	private func configureViews() {
		self.presentationController?.delegate = self

		self.configureContentView()
		self.configureContentStackView()
		self.configureTitleLabel()
		self.configureSubtitleLabel()
		self.configureLabelSegmentedControl()
		self.configureSpacerView()
		self.configurePrimaryButton()
	}

	private func configureContentView() {
		self.containerView = UIView()
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
	}

	private func configureContentStackView() {
		self.contentStackView = UIStackView()
		self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
		self.contentStackView.axis = .vertical
		self.contentStackView.spacing = 16.0
	}

	private func configureTitleLabel() {
		self.titleLabel = KLabel()
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.font = .preferredFont(forTextStyle: .headline)
		self.titleLabel.numberOfLines = 0
	}

	private func configureSubtitleLabel() {
		self.subtitleLabel = KLabel()
		self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
		self.subtitleLabel.numberOfLines = 0
	}

	private func configureLabelSegmentedControl() {
		self.labelSegmentedControl = DeselectableSegmentedControl()
		self.labelSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
		self.labelSegmentedControl.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.segmentedControlChanged()
		}, for: .valueChanged)
	}

	private func configureSpacerView() {
		self.spacerView = UIView()
		self.spacerView.translatesAutoresizingMaskIntoConstraints = false
		self.spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)
		self.spacerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
	}

	private func configurePrimaryButton() {
		self.primaryButton = KTintedButton()
		self.primaryButton.translatesAutoresizingMaskIntoConstraints = false
		self.primaryButton.setTitle("Done", for: .normal)
		self.primaryButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
		self.primaryButton.highlightBackgroundColorEnabled = true
		self.primaryButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.primaryButtonPressed()
		}, for: .touchUpInside)
	}

	private func configureViewHierarchy() {
		let infoStackView = UIStackView(arrangedSubviews: [
			self.titleLabel,
			self.subtitleLabel,
			self.labelSegmentedControl
		])
		infoStackView.axis = .vertical
		infoStackView.spacing = 8
		infoStackView.translatesAutoresizingMaskIntoConstraints = false
		infoStackView.setCustomSpacing(16, after: self.subtitleLabel)

		self.contentStackView.addArrangedSubview(infoStackView)
		self.contentStackView.addArrangedSubview(self.spacerView)
		self.contentStackView.addArrangedSubview(self.primaryButton)

		self.containerView.addSubview(self.contentStackView)
		self.view.addSubview(self.containerView)
	}

	private func configureViewConstraints() {
		self.viewWidthConstraint = self.containerView.widthAnchor.constraint(equalToConstant: 300)

		NSLayoutConstraint.activate([
			self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
			self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
			self.viewWidthConstraint,

			self.contentStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

			self.primaryButton.heightAnchor.constraint(equalToConstant: 40)
		])
	}

	private func updateSelectedOption() {
		if let selectedOption = self.selectedOption, let selectedIndex = self.options.firstIndex(of: selectedOption) {
			self.labelSegmentedControl.selectedSegmentIndex = selectedIndex
		} else {
			self.labelSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
		}
	}

	private func segmentedControlChanged() {
		if self.labelSegmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
			self.delegate?.selectedOptionChanged(nil)
		} else {
			guard let selectedOption = self.options[safe: self.labelSegmentedControl.selectedSegmentIndex] else { return }
			self.delegate?.selectedOptionChanged(selectedOption)
		}
	}

	private func primaryButtonPressed() {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SelfLabelViewController: UIAdaptivePresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		if traitCollection.horizontalSizeClass == .compact {
			return .pageSheet
		} else {
			return .popover
		}
	}
}
