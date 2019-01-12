//
//  GenresTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class GenresTableViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	var genres: [GenresElement]?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		fetchGenres()

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "The genres list is empty 😢"))
				.shouldDisplay(true)
				.shouldFadeIn(true)
				.isTouchAllowed(true)
				.isScrollAllowed(false)
		}
	}

	// MARK: - Functions
	func fetchGenres() {
		Service.shared.getGenres { (genres) in
			DispatchQueue.main.async() {
				self.genres = genres
				self.tableView.reloadData()
			}
		}
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension GenresTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let genresCount = genres?.count else { return 0 }
		return genresCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let genreCell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath) as! GenreCell

		if let name = genres?[indexPath.row].name {
			genreCell.nameLabel.text = name
		}

		if let nsfw = genres?[indexPath.row].nsfw, nsfw {
			genreCell.nsfwLabel.isHidden = false
		} else {
			genreCell.nsfwLabel.isHidden = true
		}

		return genreCell
	}
}
