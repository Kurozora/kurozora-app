//
//  LanguagesTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A list of the languages a title is available in.
class LanguagesTableViewController: KTableViewController {
	// MARK: - Source
	/// The title whose languages are listed.
	enum Source {
		/// A show and its identity.
		case show(_ identity: ShowIdentity)

		/// A literature and its identity.
		case literature(_ identity: LiteratureIdentity)

		/// A game and its identity.
		case game(_ identity: GameIdentity)
	}

	// MARK: - Row
	/// A language and the ways it is supported.
	private struct Row {
		let name: String
		let code: String
		let types: [LanguageSupportType]
		let isOriginal: Bool
		let isViewerLanguage: Bool
	}

	// MARK: - Properties
	private var source: Source?
	private var rows: [Row] = []

	private let titleLabel: KLabel = {
		let label = KLabel()
		label.font = .preferredFont(forTextStyle: .headline)
		label.textAlignment = .center
		return label
	}()

	private let subtitleLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.font = .preferredFont(forTextStyle: .caption1)
		label.textAlignment = .center
		return label
	}()

	private var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	// MARK: - Initializers
	/// Creates a list for the given title.
	///
	/// - Parameter source: The title whose languages to list.
	convenience init(source: Source) {
		self.init(style: .insetGrouped)
		self.source = source
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureNavigationItem()
		self.tableView.register(LanguageTableViewCell.self, forCellReuseIdentifier: LanguageTableViewCell.reuseID)

		self.fetchLanguages()
	}

	// MARK: - Functions
	/// Lays out the title and the language total.
	private func configureNavigationItem() {
		self.titleLabel.text = L10n.languages

		let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
		stackView.axis = .vertical
		stackView.alignment = .center
		self.navigationItem.titleView = stackView

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
			self?.dismiss(animated: true)
		})
	}

	/// Fetches the languages of the title.
	private func fetchLanguages() {
		guard let source = self.source else { return }

		Task { [weak self] in
			guard let self = self else { return }

			do {
				let languages: [SupportedLanguage]

				switch source {
				case .show(let identity):
					languages = try await KService.languages(for: identity).limit(100).response().data
				case .literature(let identity):
					languages = try await KService.languages(for: identity).limit(100).response().data
				case .game(let identity):
					languages = try await KService.languages(for: identity).limit(100).response().data
				}

				self.rows = Self.makeRows(from: languages)
				self.subtitleLabel.text = self.rows.count == 1
					? L10n.oneLanguageTotal
					: L10n.languagesTotal(self.rows.count)
				self.tableView.reloadData()
			} catch {
				print(error.localizedDescription)
			}

			self._prefersActivityIndicatorHidden = true
		}
	}

	/// Groups the given languages into one row each.
	///
	/// - Parameter languages: The languages to group.
	///
	/// - Returns: One row per language.
	private static func makeRows(from languages: [SupportedLanguage]) -> [Row] {
		let viewerCode = String(LanguageManager.shared.locale.identifier.prefix(2))
		var order: [String] = []
		var grouped: [String: Row] = [:]

		for language in languages {
			let isViewerLanguage = language.code.caseInsensitiveCompare(viewerCode) == .orderedSame

			if let existing = grouped[language.code] {
				grouped[language.code] = Row(name: existing.name, code: existing.code, types: existing.types + [language.type], isOriginal: existing.isOriginal || language.isOriginal, isViewerLanguage: isViewerLanguage)
			} else {
				order.append(language.code)
				grouped[language.code] = Row(name: language.name, code: language.code, types: [language.type], isOriginal: language.isOriginal, isViewerLanguage: isViewerLanguage)
			}
		}

		return order.compactMap { grouped[$0] }
			.sorted { first, second in
				if first.isViewerLanguage != second.isViewerLanguage {
					return first.isViewerLanguage
				}

				if first.isOriginal != second.isOriginal {
					return first.isOriginal
				}

				return first.name.localizedStandardCompare(second.name) == .orderedAscending
			}
	}
}

// MARK: - UITableViewDataSource
extension LanguagesTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: LanguageTableViewCell.reuseID, for: indexPath) as? LanguageTableViewCell else {
			return UITableViewCell()
		}

		let row = self.rows[indexPath.row]
		let marker: String? = row.isViewerLanguage ? L10n.yourLanguage : (row.isOriginal ? L10n.original : nil)
		cell.configure(name: row.name, types: row.types, marker: marker, isViewerLanguage: row.isViewerLanguage)

		return cell
	}
}
