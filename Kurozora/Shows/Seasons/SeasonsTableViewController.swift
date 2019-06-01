//
//  SeasonsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/10/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import EmptyDataSet_Swift

class SeasonsTableViewController: UITableViewController, EmptyDataSetSource, EmptyDataSetDelegate {
	var showID: Int?
	var heroID: String?
	var seasons: [SeasonsElement]? {
		didSet {
			self.tableView?.reloadData()
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

        tableView?.emptyDataSetSource = self
        tableView?.emptyDataSetDelegate = self
        tableView?.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No seasons found!"))
                .image(UIImage(named: ""))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(false)
        }
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		showID = KCommonKit.shared.showID
        fetchSeasons()
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EpisodesSegue", let cell = sender as? SeasonsTableViewCell {
			if let episodesTableViewController = segue.destination as? EpisodesTableViewController, let indexPath = tableView.indexPath(for: cell) {
				episodesTableViewController.seasonID = seasons?[indexPath.item].id
			}
		}
	}

	// MARK: - Functions
    fileprivate func fetchSeasons() {
        Service.shared.getSeasonFor(showID, withSuccess: { (seasons) in
			DispatchQueue.main.async {
				self.seasons = seasons
			}
        })
    }

    // MARK: - IBActions
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		view.hero.id = heroID
		dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SeasonsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let seasonsCount = seasons?.count else { return 0 }
		return seasonsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let seasonsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SeasonsTableViewCell", for: indexPath) as! SeasonsTableViewCell

		seasonsTableViewCell.seasonsElement = seasons?[indexPath.row]

		return seasonsTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension SeasonsTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}
