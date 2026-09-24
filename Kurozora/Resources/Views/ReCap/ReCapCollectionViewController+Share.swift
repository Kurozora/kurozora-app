//
//  ReCapCollectionViewController+Share.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ReCapCollectionViewController {
	// MARK: - Properties
	/// The name of the selected period on share cards.
	var sharePeriodName: String {
		guard
			self.selectedMonth != 0,
			let date = Calendar.current.date(from: DateComponents(year: self.year, month: self.selectedMonth, day: 1))
		else { return String(self.year) }

		let dateFormatter = DateFormatter()
		dateFormatter.locale = LanguageManager.shared.locale
		dateFormatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
		return dateFormatter.string(from: date)
	}

	/// The share card of the selected period's total time and top titles.
	var summaryShareCard: ReCapShareCard? {
		let sectionTypes: [(RecapItemType, String)] = [
			(.shows, L10n.recapTopAnimeComparison),
			(.literatures, L10n.recapTopMangaComparison),
			(.games, L10n.recapShareTopGames),
			(.characters, L10n.recapShareTopCharacters),
			(.voices, L10n.recapShareTopVoices),
			(.creators, L10n.recapShareTopCreators),
		]

		// The first four sections the period has data for.
		let availableSections = sectionTypes.lazy.compactMap { recapItemType, title -> ReCapShareCard.Section? in
			guard let recapItem = self.recapItems.first(where: { $0.attributes.recapItemType == recapItemType }) else { return nil }

			let models = self.recapEntries(of: recapItem).prefix(10).compactMap { self.models.model(for: $0) }
			let names = models.compactMap { self.shareName(of: $0) }

			guard let firstModel = models.first, !names.isEmpty else { return nil }

			return ReCapShareCard.Section(title: title, items: names, artwork: ReCapShareCard.Artwork(model: firstModel))
		}
		let sections = Array(availableSections.prefix(4))

		guard !sections.isEmpty else { return nil }

		let totalMinutes = self.recapItems
			.filter { [.shows, .literatures, .games].contains($0.attributes.recapItemType) }
			.reduce(0) { $0 + $1.attributes.totalPartsDuration }

		return .summary(period: self.sharePeriodName, total: totalMinutes > 0 ? L10n.recapMinutes(totalMinutes) : nil, sections: sections)
	}

	// MARK: - Functions
	/// Returns the share card of the given genre or theme recap.
	///
	/// - Parameter recapItem: The recap of genres or themes.
	///
	/// - Returns: The share card of the recap.
	func genreShareCard(for recapItem: RecapItem) -> ReCapShareCard? {
		let recapItemType = recapItem.attributes.recapItemType
		let items = self.recapEntries(of: recapItem)
			.prefix(ReCapGenreLockupCollectionViewCell.maximumNameCount)
			.compactMap { recapEntry -> ReCapShareCard.RankedItem? in
				guard let model = self.models.model(for: recapEntry), let name = self.shareName(of: model) else { return nil }
				return ReCapShareCard.RankedItem(name: name, detail: self.detail(for: recapEntry, of: recapItemType))
			}

		guard !items.isEmpty else { return nil }

		let title = recapItemType == .themes ? L10n.recapShareTopThemes : L10n.recapShareTopGenres
		return .genres(title: title, subtitle: self.sharePeriodName, items: items)
	}

	/// Returns the share card of the comparison of the given type.
	///
	/// - Parameter recapItemType: The type of the compared titles.
	///
	/// - Returns: The share card of the comparison.
	func comparisonShareCard(for recapItemType: RecapItemType) -> ReCapShareCard? {
		guard let comparison = self.comparisons[recapItemType] else { return nil }

		let entries = comparison.entries.compactMap { entry -> ReCapShareCard.ComparisonEntry? in
			guard let name = self.shareName(of: entry.model) else { return nil }
			return ReCapShareCard.ComparisonEntry(year: String(entry.year), name: name, detail: entry.detail, artwork: ReCapShareCard.Artwork(model: entry.model))
		}

		guard entries.count == 2 else { return nil }

		return .comparison(title: L10n.recapShareCompare, subtitle: comparison.title, entries: entries)
	}

	/// Renders the given card and presents the share sheet for it.
	///
	/// - Parameters:
	///    - card: The card to share.
	///    - button: The card button the share sheet points at.
	///    - barButtonItem: The bar button item the share sheet points at.
	func share(_ card: ReCapShareCard?, button: ReCapShareButton? = nil, barButtonItem: UIBarButtonItem? = nil) {
		guard let card, !self.isRenderingShareCard else { return }

		self.isRenderingShareCard = true
		button?.isLoading = true
		let restoreBarButtonItem = barButtonItem.map { self.showActivityIndicator(replacing: $0) }

		Task { [weak self] in
			let image = await ReCapShareRenderer.render(card, colors: self?.recapColors ?? [])

			button?.isLoading = false
			restoreBarButtonItem?()

			guard let self = self else { return }
			self.isRenderingShareCard = false

			guard let image else { return }

			let shareItem = ReCapShareItem(image: image, title: card.title)
			let activityViewController = UIActivityViewController(activityItems: [shareItem], applicationActivities: nil)
			if let barButtonItem {
				activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
			} else if let button {
				activityViewController.popoverPresentationController?.sourceView = button
				activityViewController.popoverPresentationController?.sourceRect = button.bounds
			}
			self.present(activityViewController, animated: true)
		}
	}

	/// Shows an activity indicator in place of the given bar button item.
	///
	/// - Parameter barButtonItem: The item to replace.
	///
	/// - Returns: The closure that puts the item back.
	private func showActivityIndicator(replacing barButtonItem: UIBarButtonItem) -> () -> Void {
		guard let index = self.navigationItem.rightBarButtonItems?.firstIndex(of: barButtonItem) else { return {} }

		let activityIndicatorView = UIActivityIndicatorView(style: .medium)
		activityIndicatorView.startAnimating()
		let activityBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)

		if #available(iOS 26.0, macCatalyst 26.0, *) {
			activityBarButtonItem.sharesBackground = false
		}

		self.navigationItem.rightBarButtonItems?[index] = activityBarButtonItem

		return { [weak self] in
			guard let self, let index = self.navigationItem.rightBarButtonItems?.firstIndex(of: activityBarButtonItem) else { return }
			self.navigationItem.rightBarButtonItems?[index] = barButtonItem
		}
	}

	/// Returns the name a share card shows for the given model.
	///
	/// - Parameter model: The model to name.
	///
	/// - Returns: The name of the model.
	private func shareName(of model: KurozoraItem) -> String? {
		switch model {
		case let show as Show: return show.attributes.title
		case let literature as Literature: return literature.attributes.title
		case let game as Game: return game.attributes.title
		case let character as Character: return character.attributes.name
		case let person as Person: return person.attributes.fullName
		case let genre as Genre: return genre.attributes.name
		case let theme as Theme: return theme.attributes.name
		default: return nil
		}
	}
}
