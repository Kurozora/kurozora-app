//
//  FavoriteShowsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class FavoriteShowsTableViewController: UITableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel! {
		didSet {
			primaryLabel.theme_textColor = KThemePicker.tableViewCellTitleTextColor.rawValue
		}
	}
	@IBOutlet weak var secondaryLabel: UILabel! {
		didSet {
			secondaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	// MARK: - Properties
	var shows: [[ShowDetailsElement]]? {
		didSet {
			self.tableView.reloadData()
		}
	}

	// MARK: - Views
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		fetchUserLibrary()
	}

	// MARK: - Functions
	func fetchUserLibrary() {
		self.secondaryLabel.text = "\(69) TV · \(31) Movie · \(5) OVA/ONA/Specials"
	}
}

// MARK: - UITableViewDataSource
extension FavoriteShowsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Library.Section.all.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let showsCount = shows?[section].count else { return 0 }
		return showsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
		return cell
	}
}

// MARK: - UITableViewDelegate
extension FavoriteShowsTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		guard let showSectionItemsCount = shows?[section].count else { return .zero }
		return showSectionItemsCount != 0 ? UITableView.automaticDimension : .zero
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let exploreSectionTitleCell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleCell") as? ExploreSectionTitleCell else { return nil }
		return exploreSectionTitleCell
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let exploreSectionTitleCell = view as? ExploreSectionTitleCell {
			exploreSectionTitleCell.title = Library.Section.all[section].stringValue
		}
	}
}
