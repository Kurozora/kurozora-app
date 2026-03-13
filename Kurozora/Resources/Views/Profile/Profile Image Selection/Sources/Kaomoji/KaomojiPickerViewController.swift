//
//  KaomojiPickerViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol KaomojiPickerViewControllerDelegate: AnyObject {
	func kaomojiPickerViewController(_ viewController: KaomojiPickerViewController, didSelectKaomoji kaomoji: String)
}

class KaomojiPickerViewController: KViewController {
	// MARK: - Properties
	weak var delegate: KaomojiPickerViewControllerDelegate?

	private var dataSource: UICollectionViewDiffableDataSource<Int, String>!

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
			return CGSize(width: 360, height: 480)
		}
		set {
			super.preferredContentSize = newValue
		}
	}

	// MARK: - Views
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewCompositionalLayout { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
			let width = layoutEnvironment.container.effectiveContentSize.width
			let columnCount = Int((width / 140.0).rounded())
			let columns = columnCount > 0 ? columnCount : 1
			return Layouts.charactersSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = .clear
		collectionView.clipsToBounds = false
		collectionView.delegate = self
		return collectionView
	}()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.addSubview(self.collectionView)

		NSLayoutConstraint.activate([
			self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
		])

		self.configureDataSource()
		self.updateDataSource()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if UIDevice.isPhone {
			self.sheetPresentationController?.detents = [.medium()]
			self.sheetPresentationController?.prefersGrabberVisible = true
		}
	}

	// MARK: - Data Source
	private func configureDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<AvatarCollectionViewCell, String> { cell, _, kaomoji in
			cell.configure(with: kaomoji)
		}

		self.dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: self.collectionView) { collectionView, indexPath, kaomoji in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: kaomoji)
		}
	}

	private func updateDataSource() {
		var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
		snapshot.appendSections([0])
		snapshot.appendItems(KaomojiProfileImageSourceView.allKaomojis, toSection: 0)
		self.dataSource.apply(snapshot)
	}
}

// MARK: - UICollectionViewDelegate
extension KaomojiPickerViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let kaomoji = self.dataSource.itemIdentifier(for: indexPath) else { return }
		self.delegate?.kaomojiPickerViewController(self, didSelectKaomoji: kaomoji)
		self.dismiss(animated: true)
	}
}
