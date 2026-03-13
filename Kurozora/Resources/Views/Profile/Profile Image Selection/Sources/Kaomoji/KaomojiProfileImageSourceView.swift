//
//  KaomojiProfileImageSourceView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol KaomojiProfileImageSourceViewDelegate: AnyObject {
	func kaomojiProfileImageSourceView(_ view: KaomojiProfileImageSourceView, didSelectImage image: UIImage, previewImage: UIImage?)
}

class KaomojiProfileImageSourceView: UIView {
	// MARK: - Properties
	let imageKind: ImageKind
	weak var delegate: KaomojiProfileImageSourceViewDelegate?
	var imageBackgroundColor: UIColor?
	var selectedKaomoji: String?

	static let allKaomojis: [String] = [
		"(◕‿◕)", "(≧◡≦)", "(◠‿◠)", "ヽ(>∀<☆)ノ", "╰(°▽°)╯", "(✧ω✧)", "ᕕ(ᐛ)ᕗ", "₍₍◝(°꒳°)◜₎₎", "ᐠ(ᐛ)ᐟ", "(⌒‿⌒)",
		"٩(◕‿◕)۶", "(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧", "(✯◡✯)", "\\(★ω★)/", "(≧∇≦)/", "⸜(｡˃ᵕ˂)⸝", "(⑅˃◡˂⑅)", "(ᵔ◡ᵔ)", "ヾ(•ω•)o", "(✦‿✦)",
		"⁽⁽◝(˙▿˙)◜⁾⁾", "(^▽^)", "(o^▽^o)", "(≧▽≦)", "(☆▽☆)", "(。^‿^。)", "(〃＾▽＾〃)", "(ʘ‿ʘ)", "(✿◠‿◠)", "(^人^)",
		"(●'◡'●)", "(^◡^ )", "٩(ˊᗜˋ*)و", "(*＾▽＾)／", "(*≧ω≦*)", "(´∀)", "(o´▽o)", "(＾▽＾)", "（^∀^）",
		"(* ^ ω ^)", "(´｡• ᵕ •｡)", "( ´ ▽ )", "(￣▽￣)", "(⌒∇⌒)", "(๑˃ᴗ˂)ﻭ", "(๑^ں^๑)", "(＾ω＾)人(＾ω＾)", "(･ω･)つ⊂(･ω･)", "(^‿^)",
		"(´▽*)", "(*^ω^*)", "( ´∀)", "( ˙꒳​˙ )", "(´･ᴗ･ )", "(o´∀o)", "(´◡)", "(o^ ^o)", "(´▽ʃƪ)", "(๑ᴖ◡ᴖ๑)",
		"( ´ ω )", "(￣ω￣)", "(o･ω･o)", "(＠´ー)ﾉﾞ", "(´• ω •`)", "(｡◕‿◕｡)",
		"(˘³˘)♥", "(｡♥‿♥｡)", "(◕દ◕)", "(づ￣³￣)づ", "(⊃｡•́‿•̀｡)⊃", "(♡‿♡)", "(｡･ω･｡)ﾉ♡", "(✿ ♡‿♡)", "(´｡• ω •｡) ♡", "( ´ ∀ )ﾉ ♡",
		"(♡ﾟ▽ﾟ♡)", "(♡μ_μ)", "(´ ε )♡", "(ღ˘⌣˘ღ)", "(´ω｀*)♡", "(♡˙︶˙♡)", "(´• ω •) ♡", "(人´∀)", "(*♡∀♡)", "(๑♡⌓♡๑)",
		"(´｡• ᵕ •｡) ♡", "( ´ ▽ ).｡ｏ♡", "(*˘︶˘*).｡.:*♡", "(^⌣^*)", "(♥ω♥)", "(´ε｀ )", "(灬♥ω♥灬)", "(♡-_-♡)", "(─‿─)♡",
		"(◕‿◕)♡", "(っ˘з(˘⌣˘ ) ♡", "(♡°▽°♡)", "(๑•ᴗ•๑)", "(๑•́ ₃ •̀๑)", "(*^.^*)", "(っ˘ڡ˘ς)", "(*˘︶˘*)", "( ´◡‿◡ )",
		"ʕ•ᴥ•ʔ", "ʕ´•ᴥ•ʔ", "ʕ·ᴥ·ʔ", "₍ᐢ._.ᐢ₎", "ᓚᘏᗢ", "(ᵔᴥᵔ)", "(=^･ω･^=)", "(=^･ｪ･^=)", "(=①ω①=)", "(=^‥^=)",
		"(^._.^)= ∫", "(=；ェ；=)", "(ㅇㅅㅇ❀)", "(=^ ◡ ^=)", "(=^-ω-^=)", "(=ω´=)", "(^・ω・^ )", "V●ᴥ●V", "∪･ω･∪", "(U・x・U)",
		"⊂(￣(ｴ)￣)⊃", "ʕ ᵔᴥᵔ ʔ", "ʕ •ᴥ• ʔ", "ʕ •̀ ω •́ ʔ", "ʕ • ₒ • ʔ", "(´・ω・｀)", "(p^ー^)q",
		"(ꈍᴗꈍ)", "(◕ᴗ◕✿)", "(⁄ ⁄•⁄ω⁄•⁄ ⁄)", "(/▽＼)", "(/ω＼)", "(o-_-o)", "(◡‿◡✿)", "(◕‿◕✿)", "(灬º‿º灬)♡", "(⁄ ⁄>⁄ ▽ ⁄<⁄ ⁄)",
		"( ◡‿◡ )ｼ", "(´ω｀)", "(*μ_μ)", "(〃▽〃)", "(^///^)", "(｡・//ε//・｡)", "(#^.^#)", "(^ . ^) ♡", "(っ˘ω˘ς )", "( ◡‿◡ )",
		"(〃 ω 〃)", "(◠‿◠✿)", "(•‿•)", "(´꒳`) ", "(っ˘ω˘ς)", "(๑˘︶˘๑)",
		"(⌐■■)", "(☞ﾟヮﾟ)☞", "✧(>o<)ノ✧", "(•̀ᴗ•́)و", "(¬‿¬)", "(¬¬)", "ᕙ(⇀‸↼‶)ᕗ", "(ง'̀-'́)ง", "(-■)", "(▀̿Ĺ̯▀̿ ̿)",
		"( ͡° ͜ʖ ͡°)", "¯\\(ツ)_/¯", "( ͡° ʖ̯ ͡°)", "( ￣ー￣)b", "(•̀ᴗ•́)و ̑̑", "(๑•̀ㅂ•́)و", "(b ‿ )b", "( ´ ▽ ` )b", "┌(・。・)┘♪", "└( ＾ω＾ )」",
		"ƪ(˘⌣˘)ʃ", "(~˘▽˘)~", "( ˘ ▽ ˘)っ", "(✿ ◕‿◕) ᓄ✂", "( ˙▿˙ )つ", "( ᐛ )و",
		"(⊙⊙)", "(⊙ω⊙)", "＼(◎o◎)／", "(>ω<)", "(─‿‿─)", "(─‿─)", "(˘▽˘)っ", "(ᗒᗣᗕ)՞", "(╯°□°)╯︵┻━┻", "(ノಠ益ಠ)ノ",
		"┬─┬ノ(ಠ_ಠノ)", "(o_O)", "(O_O;)", "Σ(O_O)", "(ﾟдﾟ)", "(O.O)", "(°ロ°)", "Σ(□□)", "(O_O)", "(°ロ°) !",
		"(o_O) !", "w(°ｏ°)w", "(⑉⊙ȏ⊙)", "(´⊙ω⊙)", "∑(O_O;)", "(๑•﹏•)", "(╬ Ò﹏Ó)", "＼(º □ º l|l)/", "(-_-)zzz", "(´～)",
		"(－ω－) zzZ", "(￣ρ￣)..zzZZ", "(－_－) ..zzZ", "(∪｡∪)｡｡｡zzz", "(－.－)...zzz",
		"( ´ ▽ )ﾉ", "(￣▽￣)ノ", "( ° ∀ ° )ﾉﾞ", "( ´ ω )ノﾞ", "(･ω･)ﾉ", "(o´▽o)ﾉ", "(￣ω￣) / ", "(o^ ^o) / ", "(≧▽≦) / ", "(⌒ω⌒)ﾉ",
		"(✧∀✧) / ", "(o´ωo)ﾉ", "( ˙꒳​˙ ) / ", "( ￣ー￣) / ", "(´• ω •)ﾉ", "(^ _ ^)/ ", "( ･ω･)ﾉ", "( ´ ∀ )ﾉ", "(・ω・)ﾉ", "(^▽^)/",
		"ヾ(^ω^)", "(°▽°)/", "(^o^)/", "(￣▽￣)ﾉ",
		"orz", "OTZ", "OTL", "囧rz", "＿冂○", " _|￣|○", " _|7O", " ๐rz", " ๏rz", "Or2",
		"ST0", "JTO", "○|￣|_", "m(_ _)m", "(_ _ )", "m(. .)m",
	]

	private var presets: [KaomojiPreset] = []

	private let kaomojiBackgroundColors: [UIColor] = [
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
	private lazy var kaomojiCollectionView: UICollectionView = {
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
		self.addSubview(self.kaomojiCollectionView)

		NSLayoutConstraint.activate([
			self.kaomojiCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
			self.kaomojiCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.kaomojiCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.kaomojiCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		self.generatePresets()
		self.configureDataSource()
		self.updateDataSource()
	}

	private func generatePresets() {
		let shuffledColors = self.kaomojiBackgroundColors.shuffled()
		self.presets = Self.allKaomojis.enumerated().map { index, kaomoji in
			KaomojiPreset(
				id: index,
				kaomoji: kaomoji,
				backgroundColor: shuffledColors[index % shuffledColors.count]
			)
		}
	}

	private func configureDataSource() {
		let kaomojiCellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, ItemKind> { [weak self] cell, _, itemKind in
			cell.imageKind = self?.imageKind ?? .profile
			switch itemKind {
			case .kaomoji(let preset):
				cell.configure(with: preset.kaomoji, backgroundColor: preset.backgroundColor, font: .systemFont(ofSize: 20))
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.kaomojiCollectionView) { collectionView, indexPath, itemKind in
			collectionView.dequeueConfiguredReusableCell(using: kaomojiCellRegistration, for: indexPath, item: itemKind)
		}
	}

	// MARK: - Data Source Updates
	private func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.presets.map { .kaomoji($0) }, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	// MARK: - Helpers
	func generateKaomojiImage(_ kaomoji: String) -> UIImage {
		return self.generateKaomojiImage(kaomoji, backgroundColor: self.imageBackgroundColor)
	}

	func generateKaomojiImage(_ kaomoji: String, backgroundColor: UIColor?) -> UIImage {
		let size: CGSize
		let paddedSize: CGSize

		switch self.imageKind {
		case .profile:
			size = CGSize(width: 300, height: 300)
			paddedSize = CGSize(width: 260, height: 260)
		case .banner:
			size = CGSize(width: 900, height: 300)
			paddedSize = CGSize(width: 860, height: 260)
		}

		let renderer = UIGraphicsImageRenderer(size: size)

		return renderer.image { context in
			if let backgroundColor = backgroundColor {
				backgroundColor.setFill()
				context.fill(CGRect(origin: .zero, size: size))
			}

			// Find the largest font size that fits within the padded area
			var fontSize: CGFloat = 80
			let attributes: () -> [NSAttributedString.Key: Any] = {
				[.font: UIFont.systemFont(ofSize: fontSize), .foregroundColor: UIColor.white]
			}
			var textSize = kaomoji.size(withAttributes: attributes())

			while (textSize.width > paddedSize.width || textSize.height > paddedSize.height) && fontSize > 10 {
				fontSize -= 2
				textSize = kaomoji.size(withAttributes: attributes())
			}

			let finalAttributes = attributes()
			let finalSize = kaomoji.size(withAttributes: finalAttributes)
			let drawOrigin = CGPoint(
				x: (size.width - finalSize.width) / 2,
				y: (size.height - finalSize.height) / 2
			)

			kaomoji.draw(at: drawOrigin, withAttributes: finalAttributes)
		}
	}

	func kaomojiPreviewImage(_ kaomoji: String) -> UIImage? {
		let fullImage = self.generateKaomojiImage(kaomoji, backgroundColor: self.imageBackgroundColor)
		let targetSize: CGSize

		switch self.imageKind {
		case .profile:
			targetSize = CGSize(width: 125, height: 125)
		case .banner:
			targetSize = CGSize(width: 250, height: 83)
		}

		let renderer = UIGraphicsImageRenderer(size: targetSize)
		return renderer.image { _ in
			fullImage.draw(in: CGRect(origin: .zero, size: targetSize))
		}
	}
}

// MARK: - SectionLayoutKind
extension KaomojiProfileImageSourceView {
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - KaomojiPreset
extension KaomojiProfileImageSourceView {
	struct KaomojiPreset: Hashable {
		let id: Int
		let kaomoji: String
		let backgroundColor: UIColor

		func hash(into hasher: inout Hasher) {
			hasher.combine(self.id)
		}

		static func == (lhs: KaomojiPreset, rhs: KaomojiPreset) -> Bool {
			return lhs.id == rhs.id
		}
	}
}

// MARK: - ItemKind
extension KaomojiProfileImageSourceView {
	enum ItemKind: Hashable {
		case kaomoji(_ preset: KaomojiPreset)
	}
}

// MARK: - UICollectionViewDelegate
extension KaomojiProfileImageSourceView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		switch itemKind {
		case .kaomoji(let preset):
			self.selectedKaomoji = preset.kaomoji
			self.imageBackgroundColor = preset.backgroundColor
			let generatedImage = self.generateKaomojiImage(preset.kaomoji, backgroundColor: preset.backgroundColor)
			let previewImage = self.kaomojiPreviewImage(preset.kaomoji)
			self.delegate?.kaomojiProfileImageSourceView(self, didSelectImage: generatedImage, previewImage: previewImage)
		}
	}
}
