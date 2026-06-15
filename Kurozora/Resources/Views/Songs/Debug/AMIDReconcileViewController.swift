//
//  AMIDReconcileViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import Kingfisher
import MusicKit
import UIKit

/// A picker that resolves a Kurozora song to an Apple Music catalog song.
final class AMIDReconcileViewController: UITableViewController {
	// MARK: - Views
	private let searchController = UISearchController(searchResultsController: nil)

	// MARK: - Properties
	/// The search term that seeds the picker.
	private let initialTerm: String

	/// The handler invoked with the maintainer's chosen Apple Music identifier.
	private let completion: (Int?) -> Void

	/// The catalog search results.
	private var results: [MusicKit.Song] = []

	/// A Boolean value that indicates whether the completion handler has already fired.
	private var didComplete = false

	// MARK: - Initializers
	/// Creates a reconcile picker for the given song.
	///
	/// - Parameters:
	///    - songTitle: The Kurozora song title used to seed the search.
	///    - songArtist: The Kurozora song artist used to seed the search.
	///    - completion: The handler invoked with the maintainer's chosen Apple Music identifier.
	init(songTitle: String, songArtist: String, completion: @escaping (Int?) -> Void) {
		self.initialTerm = "\(songTitle) \(songArtist)"
		self.completion = completion
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Match on Apple Music"
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.tableView.keyboardDismissMode = .onDrag

		self.configureSearchController()

		let term = self.initialTerm
		Task { [weak self] in
			await self?.search(for: term)
		}
	}

	// MARK: - Functions
	private func configureSearchController() {
		self.searchController.searchBar.delegate = self
		self.searchController.searchBar.text = self.initialTerm
		self.searchController.searchBar.placeholder = "Title and artist"
		self.searchController.searchBar.autocapitalizationType = .none
		self.searchController.obscuresBackgroundDuringPresentation = false
		self.navigationItem.searchController = self.searchController
		self.navigationItem.hidesSearchBarWhenScrolling = false
	}

	/// Runs the catalog search for the given term and reloads the table.
	///
	/// - Parameter term: The Apple Music catalog search term.
	private func search(for term: String) async {
		let term = term.trimmingCharacters(in: .whitespacesAndNewlines)

		guard !term.isEmpty else {
			self.results = []
			self.updateBackground(message: "Enter a title and artist to search.")
			self.tableView.reloadData()
			return
		}

		self.updateBackground(message: "Searching…")

		do {
			var request = MusicCatalogSearchRequest(term: term, types: [MusicKit.Song.self])
			request.limit = 25
			let response = try await request.response()
			self.results = Array(response.songs)
		} catch {
			print("----- AMIDReconcile: search failed:", error.localizedDescription)
			self.results = []
		}

		self.updateBackground(message: self.results.isEmpty ? "No matches. Edit the search and try again." : nil)
		self.tableView.reloadData()
	}

	/// Shows or clears a centered status message behind the table.
	///
	/// - Parameter message: The message to show, or `nil` to clear it.
	private func updateBackground(message: String?) {
		guard let message = message else {
			self.tableView.backgroundView = nil
			return
		}

		let label = UILabel()
		label.text = message
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.numberOfLines = 0
		self.tableView.backgroundView = label
	}

	/// Invokes the completion handler exactly once.
	///
	/// - Parameter appleMusicID: The chosen Apple Music identifier, or `nil` when cancelled.
	private func finish(with appleMusicID: Int?) {
		guard !self.didComplete else { return }
		self.didComplete = true
		self.completion(appleMusicID)
	}

	/// Dismisses the picker without a selection.
	@objc private func cancel() {
		self.finish(with: nil)
		self.dismiss(animated: true)
	}

	// MARK: - UITableViewDataSource
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.results.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let song = self.results[indexPath.row]

		var content = cell.defaultContentConfiguration()
		content.text = song.title
		content.secondaryText = "\(song.artistName) · \(song.albumTitle ?? "—")  ·  \(song.id.rawValue)"
		content.image = UIImage(systemName: "music.note")

		if let artworkURL = song.artwork?.url(width: 80, height: 80) {
			KingfisherManager.shared.retrieveImage(with: artworkURL) { result in
				guard case .success(let value) = result, tableView.indexPath(for: cell) == indexPath else { return }
				var refreshed = cell.defaultContentConfiguration()
				refreshed.text = content.text
				refreshed.secondaryText = content.secondaryText
				refreshed.image = value.image
				refreshed.imageProperties.maximumSize = CGSize(width: 44, height: 44)
				refreshed.imageProperties.cornerRadius = 6
				cell.contentConfiguration = refreshed
			}
		}

		cell.contentConfiguration = content
		return cell
	}

	// MARK: - UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let appleMusicID = Int(self.results[indexPath.row].id.rawValue) else { return }
		self.finish(with: appleMusicID)
		self.dismiss(animated: true)
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension AMIDReconcileViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		self.finish(with: nil)
	}
}

// MARK: - UISearchBarDelegate
extension AMIDReconcileViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()

		let term = searchBar.text ?? ""
		Task { [weak self] in
			await self?.search(for: term)
		}
	}
}
#endif
