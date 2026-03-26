//
//  MonogramProfileImageSourceView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol MonogramProfileImageSourceViewDelegate: AnyObject {
	func monogramProfileImageSourceView(_ view: MonogramProfileImageSourceView, didSelectImage image: UIImage)
}

class MonogramProfileImageSourceView: UIView {
	// MARK: - Properties
	let imageKind: ImageKind
	weak var delegate: MonogramProfileImageSourceViewDelegate?

	var initials: String = "" {
		didSet {
			self.updateCollectionView()
			self.generateAndNotifyMonogramImage()
		}
	}

	var selectedBackgroundColor: UIColor = .kurozora {
		didSet {
			self.generateAndNotifyMonogramImage()
		}
	}

	var selectedFontStyle: MonogramFontStyle = .defaultStyle {
		didSet {
			self.updateCollectionView()
			self.generateAndNotifyMonogramImage()
		}
	}

	var fontWeightValue: CGFloat = UIFont.Weight.bold.rawValue {
		didSet {
			self.updateCollectionView()
			self.generateAndNotifyMonogramImage()
		}
	}

	private var presets: [MonogramPreset] = []

	private let monogramBackgroundColors: [UIColor] = String.placeholderPalette

	private var selectedPresetIndex: Int = 0

	private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

	// MARK: - Views
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let width = layoutEnvironment.container.effectiveContentSize.width
			let columnCount = Int((width / self.imageKind.layoutCellSize).rounded())
			let columns = columnCount > 0 ? columnCount : 1
			return Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .clear
		collectionView.clipsToBounds = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.contentInset.top = 16
		collectionView.delegate = self
		return collectionView
	}()

	// MARK: - Initializers
	init(imageKind: ImageKind = .profile) {
		self.imageKind = imageKind
		super.init(frame: .zero)
		self.configureViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	func configure(with initials: String) {
		self.initials = initials
		self.generatePresets()
		self.updateCollectionView()
		self.selectFirstPreset()
	}

	private func configureViews() {
		self.addSubview(self.collectionView)

		NSLayoutConstraint.activate([
			self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
			self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		self.configureDataSource()
	}

	private func configureDataSource() {
		let presetCellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, ItemKind> { [weak self] cell, _, itemKind in
			guard let self = self else { return }
			cell.imageKind = self.imageKind

			switch itemKind {
			case .preset(let preset):
				let displayInitials = String(self.initials.prefix(3)).uppercased()
				let font = UIFont.monogramFont(style: preset.fontStyle, size: 48, weight: preset.fontWeight)
				cell.configure(with: displayInitials, backgroundColor: preset.backgroundColor, font: font)
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind in
			collectionView.dequeueConfiguredReusableCell(using: presetCellRegistration, for: indexPath, item: itemKind)
		}
	}

	private func generatePresets() {
		let weights: [UIFont.Weight] = [.regular, .medium, .semibold, .bold, .heavy, .black]

		// Build all 36 combinations (4 styles × 9 colors), assign each a random weight
		var allCombinations: [MonogramPreset] = []
		for style in MonogramFontStyle.allCases {
			for color in self.monogramBackgroundColors {
				let weight = weights.randomElement() ?? .bold
				allCombinations.append(MonogramPreset(
					id: 0,
					fontStyle: style,
					fontWeight: weight,
					backgroundColor: color
				))
			}
		}

		// Shuffle and take the first 18, then assign sequential IDs
		self.presets = allCombinations.shuffled().prefix(18).enumerated().map { index, preset in
			MonogramPreset(
				id: index,
				fontStyle: preset.fontStyle,
				fontWeight: preset.fontWeight,
				backgroundColor: preset.backgroundColor
			)
		}
	}

	private func selectFirstPreset() {
		if !self.presets.isEmpty {
			let indexPath = IndexPath(item: 0, section: 0)
			self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
			self.collectionView(self.collectionView, didSelectItemAt: indexPath)
		}
	}

	private func updateCollectionView() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])
		let items = self.presets.map { ItemKind.preset($0) }
		snapshot.appendItems(items, toSection: .main)
		snapshot.reconfigureItems(items)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	private func generateAndNotifyMonogramImage() {
		let image = self.generateMonogramImage()
		self.delegate?.monogramProfileImageSourceView(self, didSelectImage: image)
	}

	func generateMonogramImage() -> UIImage {
		let size: CGSize

		switch self.imageKind {
		case .profile:
			size = CGSize(width: 300, height: 300)
		case .banner:
			size = CGSize(width: 900, height: 300)
		}

		let renderer = UIGraphicsImageRenderer(size: size)

		return renderer.image { context in
			self.selectedBackgroundColor.setFill()
			context.fill(CGRect(origin: .zero, size: size))

			let text = String(self.initials.prefix(3)).uppercased()
			let font = UIFont.monogramFont(style: self.selectedFontStyle, size: 120, weight: UIFont.Weight(rawValue: self.fontWeightValue))

			let attributes: [NSAttributedString.Key: Any] = [
				.font: font,
				.foregroundColor: self.selectedBackgroundColor.isLight ? UIColor.black : UIColor.white
			]

			let textSize = text.size(withAttributes: attributes)
			let textRect = CGRect(
				x: (size.width - textSize.width) / 2,
				y: (size.height - textSize.height) / 2,
				width: textSize.width,
				height: textSize.height
			)

			text.draw(in: textRect, withAttributes: attributes)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension MonogramProfileImageSourceView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		switch itemKind {
		case .preset(let preset):
			self.selectedPresetIndex = indexPath.item
			self.selectedBackgroundColor = preset.backgroundColor
			self.selectedFontStyle = preset.fontStyle
			self.fontWeightValue = preset.fontWeight.rawValue
			self.generateAndNotifyMonogramImage()
		}
	}
}

// MARK: - SectionLayoutKind
extension MonogramProfileImageSourceView {
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension MonogramProfileImageSourceView {
	enum ItemKind: Hashable {
		case preset(_ preset: MonogramPreset)
	}
}
