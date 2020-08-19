//
//  CharacterCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class CharacterCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var characterID: Int = 0
	var character: Character! {
		didSet {
			_prefersActivityIndicatorHidden = true
			configureDataSource()
		}
	}
	var dataSource: UICollectionViewDiffableDataSource<StudioSection, Int>! = nil

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
	override func viewDidLoad() {
		super.viewDidLoad()

		DispatchQueue.global(qos: .background).async {
			self.fetchCharacter()
		}
	}

	// MARK: - Functions
	func fetchCharacter() {
		KService.getDetails(forCharacterID: characterID, including: ["shows"]) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let characters):
				self.character = characters.first
			case .failure: break
			}
		}
	}
}
