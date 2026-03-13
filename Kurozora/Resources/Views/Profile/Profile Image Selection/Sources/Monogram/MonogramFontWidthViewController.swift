//
//  MonogramFontWidthViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol MonogramFontWidthViewControllerDelegate: AnyObject {
	func monogramFontWidthViewController(
		_ viewController: MonogramFontWidthViewController,
		didSelectFontStyle fontStyle: MonogramFontStyle,
		weightValue: CGFloat
	)
}

class MonogramFontWidthViewController: KViewController {
	// MARK: - Views
	private var containerView: UIView!
	private var verticalStackView: UIStackView!
	private var gridStackView: UIStackView!
	private var weightSlider: UISlider!
	private var fontStyleViews: [MonogramFontStyle: FontStyleGridItem] = [:]

	// MARK: - Properties
	weak var delegate: MonogramFontWidthViewControllerDelegate?
	var initials: String = "AB"
	var monogramBackgroundColor: UIColor = .kurozora
	var selectedFontStyle: MonogramFontStyle = .defaultStyle
	var selectedWeightValue: CGFloat = UIFont.Weight.bold.rawValue

	override var modalPresentationStyle: UIModalPresentationStyle {
		get {
			return UIDevice.isPhone ? .pageSheet : .popover
		}
		set {
			super.modalPresentationStyle = newValue
		}
	}

	override var preferredContentSize: CGSize {
		get {
			return self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		}
		set {
			super.preferredContentSize = newValue
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.updateSelection()
	}

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

	// MARK: - Configuration
	private func configureViews() {
		self.containerView = UIView()
		self.containerView.translatesAutoresizingMaskIntoConstraints = false

		self.verticalStackView = UIStackView()
		self.verticalStackView.translatesAutoresizingMaskIntoConstraints = false
		self.verticalStackView.axis = .vertical
		self.verticalStackView.spacing = 16.0

		self.configureGrid()
		self.configureSlider()
	}

	private func configureGrid() {
		self.gridStackView = UIStackView()
		self.gridStackView.translatesAutoresizingMaskIntoConstraints = false
		self.gridStackView.axis = .vertical
		self.gridStackView.spacing = 12.0

		let topRow = UIStackView()
		topRow.axis = .horizontal
		topRow.spacing = 12.0
		topRow.distribution = .fillEqually

		let bottomRow = UIStackView()
		bottomRow.axis = .horizontal
		bottomRow.spacing = 12.0
		bottomRow.distribution = .fillEqually

		let styles = MonogramFontStyle.allCases
		for (index, style) in styles.enumerated() {
			let gridItem = FontStyleGridItem(
				style: style,
				initials: self.initials,
				weightValue: self.selectedWeightValue
			)
			gridItem.onTap = { [weak self] tappedStyle in
				self?.handleStyleSelection(tappedStyle)
			}
			self.fontStyleViews[style] = gridItem

			if index < 2 {
				topRow.addArrangedSubview(gridItem)
			} else {
				bottomRow.addArrangedSubview(gridItem)
			}
		}

		self.gridStackView.addArrangedSubview(topRow)
		self.gridStackView.addArrangedSubview(bottomRow)
	}

	private func configureSlider() {
		self.weightSlider = UISlider()
		self.weightSlider.translatesAutoresizingMaskIntoConstraints = false
		self.weightSlider.minimumValue = Float(UIFont.Weight.regular.rawValue)
		self.weightSlider.maximumValue = Float(UIFont.Weight.black.rawValue)
		self.weightSlider.value = Float(self.selectedWeightValue)
		self.weightSlider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
	}

	private func configureViewHierarchy() {
		self.verticalStackView.addArrangedSubview(self.gridStackView)
		self.verticalStackView.addArrangedSubview(self.weightSlider)
		self.containerView.addSubview(self.verticalStackView)
		self.view.addSubview(self.containerView)
	}

	private func configureViewConstraints() {
		let widthConstant: CGFloat = if UIDevice.isPhone {
			self.view.frame.size.width
		} else if UIDevice.isPad {
			360.0
		} else {
			300.0
		}

		NSLayoutConstraint.activate([
			self.view.widthAnchor.constraint(equalToConstant: widthConstant),

			self.containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.containerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
			self.containerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),

			self.verticalStackView.topAnchor.constraint(equalToSystemSpacingBelow: self.containerView.topAnchor, multiplier: 2.0),
			self.containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.verticalStackView.bottomAnchor, multiplier: 1.0),
			self.verticalStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.containerView.leadingAnchor, multiplier: 2.0),
			self.containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.verticalStackView.trailingAnchor, multiplier: 2.0),
		])
	}

	// MARK: - Actions
	private func handleStyleSelection(_ style: MonogramFontStyle) {
		self.selectedFontStyle = style
		self.updateSelection()
		self.delegate?.monogramFontWidthViewController(self, didSelectFontStyle: self.selectedFontStyle, weightValue: self.selectedWeightValue)
	}

	@objc private func sliderValueChanged(_ slider: UISlider) {
		self.selectedWeightValue = CGFloat(slider.value)

		for (_, gridItem) in self.fontStyleViews {
			gridItem.updateWeight(self.selectedWeightValue)
		}

		self.delegate?.monogramFontWidthViewController(self, didSelectFontStyle: self.selectedFontStyle, weightValue: self.selectedWeightValue)
	}

	private func updateSelection() {
		for (style, gridItem) in self.fontStyleViews {
			gridItem.setSelected(style == self.selectedFontStyle)
		}
	}
}

// MARK: - FontStyleGridItem
private class FontStyleGridItem: UIView {
	private let style: MonogramFontStyle
	private let initialsLabel: UILabel
	private let collectionView: UIView
	private var weightValue: CGFloat

	var onTap: ((MonogramFontStyle) -> Void)?

	init(style: MonogramFontStyle, initials: String, weightValue: CGFloat) {
		self.style = style
		self.weightValue = weightValue
		self.initialsLabel = UILabel()
		self.collectionView = UIView()
		super.init(frame: .zero)

		self.configureViews(initials: initials)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureViews(initials: String) {
		self.collectionView.translatesAutoresizingMaskIntoConstraints = false
		self.collectionView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.collectionView.layerCornerRadius = 16
		self.collectionView.clipsToBounds = true

		self.initialsLabel.translatesAutoresizingMaskIntoConstraints = false
		self.initialsLabel.text = String(initials.prefix(3)).uppercased()
		self.initialsLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		self.initialsLabel.textAlignment = .center
		self.initialsLabel.font = UIFont.monogramFont(style: self.style, size: 48, weight: UIFont.Weight(rawValue: self.weightValue))
		self.collectionView.addSubview(self.initialsLabel)

		self.addSubview(self.collectionView)

		NSLayoutConstraint.activate([
			self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

			self.collectionView.heightAnchor.constraint(equalTo: self.collectionView.widthAnchor, multiplier: 0.65),

			self.initialsLabel.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
			self.initialsLabel.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),
		])

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
		self.addGestureRecognizer(tapGesture)
	}

	@objc private func tapped() {
		self.onTap?(self.style)
	}

	func setSelected(_ selected: Bool) {
		self.collectionView.layer.borderWidth = selected ? 3.0 : 0.0
		self.collectionView.layer.borderColor = selected ? UIColor.kurozora.cgColor : nil
	}

	func updateWeight(_ weightValue: CGFloat) {
		self.weightValue = weightValue
		self.initialsLabel.font = UIFont.monogramFont(style: self.style, size: 48, weight: UIFont.Weight(rawValue: weightValue))
	}
}
