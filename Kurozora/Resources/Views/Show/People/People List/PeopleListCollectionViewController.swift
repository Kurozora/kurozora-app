//
//  PeopleListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class PeopleListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var characterID = 0
	var people: [Person] = [] {
		didSet {
			self.configureDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var nextPageURL: String?
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

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
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		if characterID != 0 {
			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchPeople()
			}
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		if characterID != 0 {
			self.nextPageURL = nil
			self.fetchPeople()
		}
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		emptyBackgroundView.configureLabels(title: "No People", detail: "Can't get people list. Please reload the page or restart the app and check your WiFi connection.")

		collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func fetchPeople() {
		KService.getPeople(forCharacterID: self.characterID, next: self.nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let peopleResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.people = []
				}

				// Save next page url and append new data
				self.nextPageURL = peopleResponse.next
				self.people.append(contentsOf: peopleResponse.data)
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.peopleListCollectionViewController.personDetailsSegue.identifier:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.personID = person.id
		default: break
		}
	}
}

// MARK: - KCollectionViewDataSource
extension PeopleListCollectionViewController {
	override func registerCells(for collectionView: UICollectionView) -> [UICollectionViewCell.Type] {
		return [PersonLockupCollectionViewCell.self]
	}

	override func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: collectionView) { [weak self] (collectionView: UICollectionView, indexPath: IndexPath, _) -> UICollectionViewCell? in
			guard let self = self else { return nil }
			let personLockupCollectionViewCell = collectionView.dequeueReusableCell(withClass: PersonLockupCollectionViewCell.self, for: indexPath)
			personLockupCollectionViewCell.configure(using: self.people[indexPath.item])
			return personLockupCollectionViewCell
		}

		var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
		SectionLayoutKind.allCases.forEach {
			snapshot.appendSections([$0])
			snapshot.appendItems(Array(0..<people.count), toSection: $0)
		}
		self.dataSource.apply(snapshot)
	}
}

// MARK: - KCollectionViewDelegateLayout
extension PeopleListCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = (width / 200).rounded().int
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			guard let self = self else { return nil }
			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.peopleSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
		return layout
	}
}

// MARK: - SectionLayoutKind
extension PeopleListCollectionViewController {
	/// List of section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}
}
