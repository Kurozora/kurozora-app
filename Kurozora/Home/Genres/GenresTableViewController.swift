//
//  GenresTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class GenresTableViewController: UITableViewController {
	var genres: [GenreElement]? {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		fetchGenres()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No Genres", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: "Can't get genres list. Please reload the page or restart the app and check your WiFi connection.", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(#imageLiteral(resourceName: "empty_genres"))
				.verticalOffset(-50)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	// MARK: - Functions
	func fetchGenres() {
		Service.shared.getGenres { (genres) in
			DispatchQueue.main.async {
				self.genres = genres
			}
		}
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension GenresTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let genresCount = genres?.count else { return 0 }
		return genresCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let genreTableViewCell = tableView.dequeueReusableCell(withIdentifier: "GenreTableViewCell", for: indexPath) as! GenreTableViewCell

		genreTableViewCell.genreElement = genres?[indexPath.row]

		return genreTableViewCell
	}
}

// MARK - UITableViewDelegate
extension GenresTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}
