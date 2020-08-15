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
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
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

		DispatchQueue.global(qos: .background).async {
			self.fetchGenres()
		}
	}

	// MARK: - Functions
	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Genres", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get genres list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.genres())
				.verticalOffset(-50)
				.verticalSpace(5)
				.isScrollAllowed(true)
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

// MARK: - UITableViewDelegate
extension GenresTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}
