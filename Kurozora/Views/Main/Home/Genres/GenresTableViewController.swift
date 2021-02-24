//
//  GenresTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class GenresTableViewController: KTableViewController {
	// MARK: - Properties
	var genres: [Genre] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
			self.tableView.reloadData {
				self.toggleEmptyDataView()
			}
		}
	}

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
	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		DispatchQueue.global(qos: .background).async {
			self.fetchGenres()
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchGenres()
	}

	override func configureEmptyDataView() {
		emptyBackgroundView.configureImageView(image: R.image.empty.genres()!)
		emptyBackgroundView.configureLabels(title: "No Genres", detail: "Can't get genres list. Please reload the page or restart the app and check your WiFi connection.")

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of .
	func toggleEmptyDataView() {
		if self.tableView.numberOfRows() == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches genres from the server.
	func fetchGenres() {
		KService.getGenres { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let genres):
				DispatchQueue.main.async {
					self.genres = genres
				}
			case .failure: break
			}
		}
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.genresTableViewController.exploreSegue.identifier {
			if let homeCollectionViewController = segue.destination as? HomeCollectionViewController {
				if let selectedCell = sender as? GenreTableViewCell {
					homeCollectionViewController.genre = selectedCell.genre
				}
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension GenresTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return genres.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let genreTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.genreTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.genreTableViewCell.identifier)")
		}
		genreTableViewCell.genre = genres[indexPath.row]
		return genreTableViewCell
	}
}
