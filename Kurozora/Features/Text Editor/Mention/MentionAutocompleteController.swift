//
//  MentionAutocompleteController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol MentionAutocompleteControllerDelegate: AnyObject {
	func mentionAutocompleteController(_ controller: MentionAutocompleteController, didSelectUser user: User, forMentionIn range: NSRange)
	func mentionAutocompleteControllerDidSelectSearch(_ controller: MentionAutocompleteController, query: String, userIdentities: [UserIdentity], cache: [IndexPath: KurozoraItem])
	func mentionAutocompleteController(_ controller: MentionAutocompleteController, didUpdateVisibility isVisible: Bool)
}

class MentionAutocompleteController: NSObject, SectionFetchable {
	// MARK: - Enums
	enum SectionLayoutKind: Int, CaseIterable, Hashable {
		case main = 0
	}

	enum ItemKind: Hashable {
		case userIdentity(_ identity: UserIdentity)
		case findUser

		func hash(into hasher: inout Hasher) {
			switch self {
			case .userIdentity(let identity):
				hasher.combine(identity)
			case .findUser:
				hasher.combine("findUser")
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.userIdentity(let a), .userIdentity(let b)):
				return a == b
			case (.findUser, .findUser):
				return true
			default:
				return false
			}
		}
	}

	// MARK: - Properties
	weak var delegate: MentionAutocompleteControllerDelegate?
	private let collectionView: UICollectionView
	private let collapsedConstraint: NSLayoutConstraint
	private let expandedConstraint: NSLayoutConstraint

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	private var userIdentities: [UserIdentity] = []
	private var currentMentionContext: MentionContext?
	private var searchTask: Task<Void, Never>?

	// MARK: - Initializers
	init(collectionView: UICollectionView, collapsedConstraint: NSLayoutConstraint, expandedConstraint: NSLayoutConstraint) {
		self.collectionView = collectionView
		self.collapsedConstraint = collapsedConstraint
		self.expandedConstraint = expandedConstraint
		super.init()

		self.configureCollectionViewLayout()
		self.configureDataSource()

		self.collectionView.delegate = self
	}

	// MARK: - Functions
	/// Updates the autocomplete suggestions based on the provided mention context.
	///
	/// - Parameter context: The current mention context, or `nil` if there is no active mention.
	func update(for context: MentionContext?) {
		self.currentMentionContext = context

		guard let context = context else {
			self.hide()
			return
		}

		if context.query.isEmpty {
			self.searchTask?.cancel()
			self.userIdentities = []
			self.cache = [:]
			self.updateDataSource()
			self.show()
			return
		}

		self.searchTask?.cancel()
		self.searchTask = Task { [weak self] in
			// Debounce 300ms to avoid excessive API calls while typing
			do {
				try await Task.sleep(nanoseconds: 300_000_000)
			} catch {
				return
			}

			guard let self = self, !Task.isCancelled else { return }

			do {
				let searchResponse = try await KService.search(.kurozora, types: [.users], query: context.query).cursor(nil).limit(10).filter(nil).response()
				guard !Task.isCancelled else { return }

				await MainActor.run {
					self.userIdentities = searchResponse.data.users?.data ?? []
					self.cache = [:]
					self.updateDataSource()
					self.show()
				}
			} catch {
				guard !Task.isCancelled else { return }
				print("-----", error.localizedDescription)
			}
		}
	}

	func extractIdentity<Element: KurozoraItem>(from item: ItemKind) -> Element? {
		switch item {
		case .userIdentity(let identity):
			return identity as? Element
		case .findUser:
			return nil
		}
	}

	private func show() {
		guard self.collectionView.isHidden else { return }
		self.collectionView.isHidden = false
		self.collapsedConstraint.isActive = false
		self.expandedConstraint.isActive = true
		if let editorView = self.collectionView.superview as? KFeedMessageTextEditorView {
			editorView.setMentionSeparatorHidden(false)
		}
		self.collectionView.superview?.layoutIfNeeded()
		self.delegate?.mentionAutocompleteController(self, didUpdateVisibility: true)
	}

	private func hide() {
		self.searchTask?.cancel()
		guard !self.collectionView.isHidden else { return }
		self.expandedConstraint.isActive = false
		self.collapsedConstraint.isActive = true
		self.collectionView.isHidden = true
		if let editorView = self.collectionView.superview as? KFeedMessageTextEditorView {
			editorView.setMentionSeparatorHidden(true)
		}
		self.userIdentities = []
		self.cache = [:]
		self.collectionView.superview?.layoutIfNeeded()
		self.delegate?.mentionAutocompleteController(self, didUpdateVisibility: false)
	}

	private func configureCollectionViewLayout() {
		let layout = UICollectionViewCompositionalLayout { _, environment in
			var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
			configuration.showsSeparators = false
			configuration.backgroundColor = .clear

			let layoutSection = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
			layoutSection.interGroupSpacing = 20.0
			layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)
			return layoutSection
		}
		self.collectionView.collectionViewLayout = layout
	}

	private func configureDataSource() {
		let userCellRegistration = UICollectionView.CellRegistration<UserLockupCollectionViewCell, ItemKind>(cellNib: UserLockupCollectionViewCell.nib) { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .userIdentity:
				let user: User? = self.fetchModel(at: indexPath)

				if user == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<User>.self, UserIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				cell.configureForMention(using: user)
			case .findUser:
				break
			}
		}

		let searchPromptCellRegistration = UICollectionView.CellRegistration<MentionSearchPromptCollectionViewCell, ItemKind> { cell, _, _ in
			cell.hideSkeleton()
		}

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind -> UICollectionViewCell? in
			switch itemKind {
			case .userIdentity:
				return collectionView.dequeueConfiguredReusableCell(using: userCellRegistration, for: indexPath, item: itemKind)
			case .findUser:
				return collectionView.dequeueConfiguredReusableCell(using: searchPromptCellRegistration, for: indexPath, item: itemKind)
			}
		}
	}

	private func updateDataSource() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.main])

		var items: [ItemKind] = self.userIdentities.map { .userIdentity($0) }
		items.append(.findUser)
		self.snapshot.appendItems(items, toSection: .main)

		self.dataSource.apply(self.snapshot, animatingDifferences: false)
	}
}

// MARK: - UICollectionViewDelegate
extension MentionAutocompleteController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)

		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		guard let mentionContext = self.currentMentionContext else { return }

		switch itemKind {
		case .userIdentity:
			guard let user = self.cache[indexPath] as? User else { return }
			self.delegate?.mentionAutocompleteController(self, didSelectUser: user, forMentionIn: mentionContext.range)
		case .findUser:
			self.delegate?.mentionAutocompleteControllerDidSelectSearch(self, query: mentionContext.query, userIdentities: self.userIdentities, cache: self.cache)
		}
	}
}
