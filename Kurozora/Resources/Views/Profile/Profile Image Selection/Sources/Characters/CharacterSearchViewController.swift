//
//  CharacterSearchViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

protocol CharacterSearchViewControllerDelegate: AnyObject {
	func characterSearchViewController(_ viewController: CharacterSearchViewController, didSelectImage image: UIImage)
}

class CharacterSearchViewController: KCollectionViewController {
	// MARK: - Views
	private lazy var searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchBar.placeholder = String(localized: "Search characters")
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.delegate = self
		return searchController
	}()

	// MARK: - Properties
	weak var delegate: CharacterSearchViewControllerDelegate?

	private var characterIdentities: [CharacterIdentity] = []
	private var characterCache: [IndexPath: Character] = [:]
	private var isFetchingSection = false
	private var nextPageURL: String?
	private var isRequestInProgress: Bool = false
	private var currentQuery: String = ""

	private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureView()
	}

	// MARK: - Setup
	private func configureView() {
		self.title = L10n.characters

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		// Add Refresh Control to Collection View
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshCharacters)
		#endif

		self.navigationItem.searchController = self.searchController
		self.navigationItem.hidesSearchBarWhenScrolling = false

		self.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in
			self?.dismiss(animated: true)
		})

		self.view.addSubview(self.collectionView)

		NSLayoutConstraint.activate([
			self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		])

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchCharacters(query: "")
		}
	}

	// MARK: - Functions
	override func configureDataSource() {
		let characterCellRegistration = UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: CharacterLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
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

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: self.collectionView) { collectionView, indexPath, itemKind in
			collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: itemKind)
		}
	}

	override func updateDataSource() {
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
				let response: CharacterResponse = try await KService.getDetails(for: identitiesToFetch)

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

	override func handleRefreshControl() {
		self.nextPageURL = nil
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchCharacters(query: self.currentQuery)
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.cast)
		self.emptyBackgroundView.configureLabels(title: "No Characters", detail: "There are no characters matching your search. Please try a different query or check your WiFi connection.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	private func fetchCharacters(query: String) async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		do {
			let searchResponse = try await KService.search(.kurozora, of: [.characters], for: query, next: self.nextPageURL, limit: self.nextPageURL != nil ? 100 : 25, filter: nil)

			if self.nextPageURL == nil {
				self.characterIdentities = []
				self.characterCache = [:]
			}

			self.nextPageURL = searchResponse.data.characters?.next
			self.characterIdentities.append(contentsOf: searchResponse.data.characters?.data ?? [])
			self.characterIdentities.removeDuplicates()
		} catch {
			print("Failed to fetch characters: \(error)")
		}

		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if DEBUG
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshCharacters)
		#endif
		#endif
	}

	private func fetchAndSelectCharacter(_ characterIdentity: CharacterIdentity) {
		Task {
			do {
				let characterResponse = try await KService.getDetails(forCharacter: characterIdentity)
				guard let character = characterResponse.data.first else { return }

				let imageView = UIImageView()
				character.attributes.profileImage(imageView: imageView)

				if let image = imageView.image {
					self.delegate?.characterSearchViewController(self, didSelectImage: image)
					self.dismiss(animated: true)
				}
			} catch {
				print("Failed to fetch character: \(error)")
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension CharacterSearchViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int((width / 140.0).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension CharacterSearchViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		switch itemKind {
		case .characterIdentity(let characterIdentity):
			self.fetchAndSelectCharacter(characterIdentity)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let characterIdentitiesCount = self.characterIdentities.count - 1
		var itemsCount = characterIdentitiesCount / 4 / 2
		itemsCount = itemsCount > 15 ? 15 : itemsCount
		itemsCount = characterIdentitiesCount - itemsCount
		itemsCount = itemsCount < 1 ? 1 : itemsCount

		if indexPath.item >= itemsCount, self.nextPageURL != nil {
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchCharacters(query: self.currentQuery)
			}
		}
	}
}

// MARK: - UISearchBarDelegate
extension CharacterSearchViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()

		Task { [weak self] in
			guard let self = self else { return }

			self.nextPageURL = nil
			self.currentQuery = searchBar.text ?? ""
			await self.fetchCharacters(query: self.currentQuery)
		}
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		Task { [weak self] in
			guard let self = self else { return }

			self.nextPageURL = nil
			self.currentQuery = ""
			await self.fetchCharacters(query: "")
		}
	}
}

// MARK: - SectionLayoutKind
extension CharacterSearchViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}

// MARK: - ItemKind
extension CharacterSearchViewController {
	enum ItemKind: Hashable {
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
