//
//  MediaStatsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

/// Lists the technical details of an image in the media viewer.
final class MediaStatsViewController: KTableViewController {
	// MARK: - Properties
	private let mediaItem: MediaItem
	private let image: UIImage?

	private var rows: [Row] = []

	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	// MARK: - Initializers
	/// Creates a screen describing the given item.
	///
	/// - Parameters:
	///    - mediaItem: The item to describe.
	///    - image: The image on display.
	init(mediaItem: MediaItem, image: UIImage?) {
		self.mediaItem = mediaItem
		self.image = image
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.statsForNerds
		self.tableView.cellLayoutMarginsFollowReadableWidth = true

		self.configureCloseBarButtonItem()
		self.rows = self.localRows()
		self.loadRemoteRows()
	}

	// MARK: - Functions
	private func configureCloseBarButtonItem() {
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
			self?.dismiss(animated: true)
		})
	}

	/// Returns the rows derived from the loaded image.
	private func localRows() -> [Row] {
		guard let image = self.image else { return [] }

		let pixelSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
		var rows: [Row] = [
			Row(title: L10n.dimensions, value: "\(Int(pixelSize.width)) × \(Int(pixelSize.height))")
		]

		if let ratio = self.aspectRatio(for: pixelSize) {
			rows.append(Row(title: L10n.aspectRatio, value: ratio))
		}

		if let colorSpaceName = image.cgImage?.colorSpace?.name {
			rows.append(Row(title: L10n.colorSpace, value: self.readableColorSpace(String(colorSpaceName))))
		}

		return rows
	}

	/// Appends the rows derived from the server's response.
	private func loadRemoteRows() {
		Task { [weak self] in
			guard let self = self else { return }

			var request = URLRequest(url: self.mediaItem.url)
			request.httpMethod = "HEAD"

			guard
				let (_, response) = try? await URLSession.shared.data(for: request),
				let httpResponse = response as? HTTPURLResponse
			else {
				return
			}

			var rows: [Row] = []

			if let fileType = self.fileType(from: httpResponse) {
				rows.append(Row(title: L10n.fileType, value: fileType))
			}

			if httpResponse.expectedContentLength > 0 {
				let byteCount = ByteCountFormatter.string(fromByteCount: httpResponse.expectedContentLength, countStyle: .file)
				rows.append(Row(title: L10n.fileSize, value: byteCount))
			}

			guard !rows.isEmpty else { return }
			self.rows.append(contentsOf: rows)
			self.tableView.reloadData()
		}
	}

	/// Returns the image's width to height ratio reduced to its smallest whole terms.
	///
	/// - Parameter size: The image's pixel size.
	/// - Returns: The reduced ratio.
	private func aspectRatio(for size: CGSize) -> String? {
		let width = Int(size.width)
		let height = Int(size.height)
		guard width > 0, height > 0 else { return nil }

		var first = width
		var second = height

		while second != 0 {
			(first, second) = (second, first % second)
		}

		guard first > 0 else { return nil }
		return "\(width / first):\(height / first)"
	}

	/// Returns the image's format.
	///
	/// - Parameter response: The response describing the image.
	/// - Returns: The localized format name alongside its MIME type.
	private func fileType(from response: HTTPURLResponse) -> String? {
		let mimeType = response.mimeType ?? UTType(filenameExtension: self.mediaItem.url.pathExtension)?.preferredMIMEType

		guard let mimeType = mimeType else { return nil }
		guard let type = UTType(mimeType: mimeType), let description = type.localizedDescription else { return mimeType }

		return "\(description) (\(mimeType))"
	}

	/// Returns the display name of the given color space.
	///
	/// - Parameter name: The color space's raw name.
	/// - Returns: The color space's display name.
	private func readableColorSpace(_ name: String) -> String {
		return name.replacingOccurrences(of: "kCGColorSpace", with: "")
	}
}

// MARK: - KTableViewDataSource
extension MediaStatsViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [SettingsCell.self]
	}
}

// MARK: - UITableViewDataSource
extension MediaStatsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.rows.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard
			let row = self.rows[safe: indexPath.row],
			let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.self, for: indexPath)
		else {
			return UITableViewCell()
		}

		cell.configure(title: row.title, detail: row.value)
		cell.chevronImageView?.isHidden = true
		cell.selectionStyle = .none

		return cell
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.mediaItem.url.absoluteString
	}
}

// MARK: - Row
private extension MediaStatsViewController {
	/// A single measurement of the image.
	struct Row {
		let title: String
		let value: String
	}
}
