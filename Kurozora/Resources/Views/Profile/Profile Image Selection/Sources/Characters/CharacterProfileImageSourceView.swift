//
//  CharacterProfileImageSourceView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol CharacterProfileImageSourceViewDelegate: AnyObject {
	func characterProfileImageSourceView(_ view: CharacterProfileImageSourceView, didSelectImage image: UIImage)
}

class CharacterProfileImageSourceView: UIView {
	// MARK: - Properties
	let imageKind: ImageKind
	weak var delegate: CharacterProfileImageSourceViewDelegate?

	var previewImageView: UIImageView?

	private var characterIdentities: [CharacterIdentity] = []
	private var characterCache: [IndexPath: Character] = [:]
	private var isFetchingSection = false
	private var nextPageCursor: PageCursor?
	private var isRequestInProgress: Bool = false
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

	// MARK: - Setup
	private func configureViews() {
		self.addSubview(self.collectionView)

		NSLayoutConstraint.activate([
			self.collectionView.topAnchor.constraint(equalTo: self.topAnchor),
			self.collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])

		self.configureDataSource()
		self.fetchCharacters()
	}

	private func configureDataSource() {
		let characterLockupCellRegistration = UICollectionView.CellRegistration<ProfileLockupCollectionViewCell, ItemKind>(cellNib: ProfileLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity:
				let character = self.characterCache[indexPath]

				if character == nil, !self.isFetchingSection {
					Task {
						await self.fetchSectionIfNeeded()
					}
				}

				characterLockupCollectionViewCell.configure(using: character, showsTitle: false, showsSubtitle: false, showsRank: false)
			}
		}

		let avatarCellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, ItemKind> { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			cell.imageKind = self.imageKind

			switch itemKind {
			case .characterIdentity:
				let character = self.characterCache[indexPath]

				if character == nil, !self.isFetchingSection {
					Task {
						await self.fetchSectionIfNeeded()
					}
				}

				cell.configure(with: character)
			}
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { [weak self] collectionView, indexPath, itemKind in
			switch self?.imageKind {
			case .banner:
				return collectionView.dequeueConfiguredReusableCell(using: avatarCellRegistration, for: indexPath, item: itemKind)
			default:
				return collectionView.dequeueConfiguredReusableCell(using: characterLockupCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	// MARK: - Data Source Updates
	private func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		snapshot.appendSections([.main])
		snapshot.appendItems(self.characterIdentities.map { .characterIdentity($0) }, toSection: .main)
		self.dataSource.apply(snapshot)
	}

	private func setSectionNeedsUpdate(_ section: SectionLayoutKind) {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.indexOfSection(section) != nil else { return }
		let itemsInSection = snapshot.itemIdentifiers(inSection: section)
		snapshot.reconfigureItems(itemsInSection)
		self.dataSource.apply(snapshot, animatingDifferences: true)
	}

	private func fetchSectionIfNeeded() async {
		guard !self.isFetchingSection else { return }
		self.isFetchingSection = true

		defer {
			self.isFetchingSection = false
		}

		let uncached: [(index: Int, identity: CharacterIdentity)] = self.characterIdentities.enumerated().compactMap { index, identity in
			let ip = IndexPath(item: index, section: 0)
			return self.characterCache[ip] == nil ? (index, identity) : nil
		}

		guard !uncached.isEmpty else { return }

		let chunks = uncached.chunked(into: 25)

		do {
			for chunk in chunks {
				let identitiesToFetch = chunk.map { $0.identity }
				let response: ResourceCollection<Character> = try await KService.details(identitiesToFetch).response()

				let orderLookup = Dictionary(uniqueKeysWithValues: identitiesToFetch.enumerated().map { ($1.id, $0) })
				let sorted = response.data.sorted {
					guard let lhsIndex = orderLookup[$0.id], let rhsIndex = orderLookup[$1.id] else { return false }
					return lhsIndex < rhsIndex
				}

				for (localIdx, model) in sorted.enumerated() {
					let originalIndex = chunk[localIdx].index
					let ip = IndexPath(item: originalIndex, section: 0)
					self.characterCache[ip] = model
				}
			}

			self.setSectionNeedsUpdate(.main)
		} catch {
			print("----- Fetch error: \(error)")
		}
	}

	// MARK: - Data Loading
	private func fetchCharacters() {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		Task {
			do {
				let searchResponse = try await KService.search(.kurozora, types: [.characters], query: "").cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).filter(nil).response()

				if self.nextPageCursor == nil {
					self.characterIdentities = []
					self.characterCache = [:]
				}

				self.nextPageCursor = searchResponse.data.characters?.nextCursor
				self.characterIdentities.append(contentsOf: searchResponse.data.characters?.data ?? [])
				self.characterIdentities.removeDuplicates()
				self.updateDataSource()
			} catch {
				print("Failed to fetch characters: \(error)")
			}

			self.isRequestInProgress = false
		}
	}

	private func fetchAndSelectCharacter(_ characterIdentity: CharacterIdentity) {
		Task {
			do {
				let characterResponse = try await KService.detail(characterIdentity).response()
				guard let character = characterResponse.data.first, let previewImageView = self.previewImageView else { return }
				character.attributes.profileImage(imageView: previewImageView)
				if let image = previewImageView.image {
					self.delegate?.characterProfileImageSourceView(self, didSelectImage: image)
				}
			} catch {
				print("Failed to fetch character: \(error)")
			}
		}
	}
}

// MARK: - SectionLayoutKind
extension CharacterProfileImageSourceView {
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension CharacterProfileImageSourceView {
	enum ItemKind: Hashable {
		// MARK: - Cases
		case characterIdentity(_: CharacterIdentity)

		func hash(into hasher: inout Hasher) {
			switch self {
			case .characterIdentity(let characterIdentity):
				hasher.combine(characterIdentity)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.characterIdentity(let characterIdentity1), .characterIdentity(let characterIdentity2)):
				return characterIdentity1 == characterIdentity2
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension CharacterProfileImageSourceView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		switch itemKind {
		case .characterIdentity(let characterIdentity):
			self.fetchAndSelectCharacter(characterIdentity)
		}
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let characterIdentitiesCount = self.characterIdentities.count - 1
		var itemsCount = characterIdentitiesCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount
		itemsCount = characterIdentitiesCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount

		if indexPath.item >= itemsCount, self.nextPageCursor != nil {
			self.fetchCharacters()
		}
	}
}
