//
//  EmojiProfileImageSourceView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol EmojiProfileImageSourceViewDelegate: AnyObject {
	func emojiProfileImageSourceView(_ view: EmojiProfileImageSourceView, didSelectImage image: UIImage, previewImage: UIImage?)
}

class EmojiProfileImageSourceView: UIView {
	// MARK: - Properties
	let imageKind: ImageKind
	weak var delegate: EmojiProfileImageSourceViewDelegate?
	var imageBackgroundColor: UIColor?
	var selectedEmoji: String?

	var firstEmoji: String? {
		return self.emojis.first
	}

	private let emojis: [String] = [
		"😊", "🥰", "😎", "🤩", "🥳", "😈", "🤖", "👾",
		"🦊", "🐱", "🐶", "🐰", "🐼", "🦁", "🐸", "🦋",
		"🌟", "⭐️", "🌙", "☀️", "🌈", "🌸", "💎", "🔥",
		"💜", "🧡", "💚", "💙", "🩵", "🩷", "🤍", "🖤",
		"🎭", "🎨", "🎬", "🎮", "🎵", "🎲", "🏆", "⚔️",
		"🍥", "🍣", "🍜", "🍦", "🧁", "🍩", "🍪", "☕️",
		"⚡️", "💫", "🎯", "🪄", "🧙", "🦄", "🐉", "🎃"
	]

	private var presets: [EmojiPreset] = []

	private let emojiBackgroundColors: [UIColor] = [
		.systemRed,
		.systemOrange,
		.systemYellow,
		.systemGreen,
		.systemTeal,
		.systemBlue,
		.systemIndigo,
		.systemPurple,
		.systemPink
	]

	private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

	// MARK: - Views
	private lazy var emojiCollectionView: UICollectionView = {
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

	// MARK: - Setup
	private func configureViews() {
		self.addSubview(self.emojiCollectionView)

		NSLayoutConstraint.activate([
			self.emojiCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
			self.emojiCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.emojiCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.emojiCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		self.generatePresets()
		self.configureDataSource()
		self.updateDataSource()
	}

	private func generatePresets() {
		let shuffledColors = self.emojiBackgroundColors.shuffled()
		self.presets = self.emojis.enumerated().map { index, emoji in
			EmojiPreset(
				id: index,
				emoji: emoji,
				backgroundColor: shuffledColors[index % shuffledColors.count]
			)
		}
	}

	private func configureDataSource() {
		let emojiCellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, ItemKind> { [weak self] cell, _, itemKind in
			cell.imageKind = self?.imageKind ?? .profile
			switch itemKind {
			case .emoji(let preset):
				cell.configure(with: self?.generateEmojiImage(preset.emoji, backgroundColor: nil), backgroundColor: preset.backgroundColor)
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.emojiCollectionView) { (collectionView, indexPath, itemKind) in
			return collectionView.dequeueConfiguredReusableCell(using: emojiCellRegistration, for: indexPath, item: itemKind)
		}
	}

	// MARK: - Data Source Updates
	private func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.presets.map { .emoji($0) }, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	// MARK: - Helpers
	func generateEmojiImage(_ emoji: String) -> UIImage {
		return self.generateEmojiImage(emoji, backgroundColor: self.imageBackgroundColor)
	}

	func generateEmojiImage(_ emoji: String, backgroundColor: UIColor?) -> UIImage {
		let size: CGSize
		let fontSize: CGFloat

		switch self.imageKind {
		case .profile:
			size = CGSize(width: 300, height: 300)
			fontSize = 140
		case .banner:
			size = CGSize(width: 900, height: 300)
			fontSize = 140
		}

		let renderer = UIGraphicsImageRenderer(size: size)

		return renderer.image { context in
			if let backgroundColor = backgroundColor {
				backgroundColor.setFill()
				context.fill(CGRect(origin: .zero, size: size))
			}

			let attributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: fontSize)
			]
			let textSize = emoji.size(withAttributes: attributes)
			let drawOrigin = CGPoint(
				x: (size.width - textSize.width) / 2,
				y: (size.height - textSize.height) / 2
			)
			emoji.draw(at: drawOrigin, withAttributes: attributes)
		}
	}
}

// MARK: - SectionLayoutKind
extension EmojiProfileImageSourceView {
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - EmojiPreset
extension EmojiProfileImageSourceView {
	struct EmojiPreset: Hashable {
		let id: Int
		let emoji: String
		let backgroundColor: UIColor

		func hash(into hasher: inout Hasher) {
			hasher.combine(self.id)
		}

		static func == (lhs: EmojiPreset, rhs: EmojiPreset) -> Bool {
			return lhs.id == rhs.id
		}
	}
}

// MARK: - ItemKind
extension EmojiProfileImageSourceView {
	enum ItemKind: Hashable {
		case emoji(_ preset: EmojiPreset)
	}
}

// MARK: - UICollectionViewDelegate
extension EmojiProfileImageSourceView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		switch itemKind {
		case .emoji(let preset):
			self.selectedEmoji = preset.emoji
			self.imageBackgroundColor = preset.backgroundColor
			let generatedImage = self.generateEmojiImage(preset.emoji, backgroundColor: preset.backgroundColor)
			let previewImage = self.generateEmojiImage(preset.emoji, backgroundColor: nil)
			self.delegate?.emojiProfileImageSourceView(self, didSelectImage: generatedImage, previewImage: previewImage)
		}
	}
}
