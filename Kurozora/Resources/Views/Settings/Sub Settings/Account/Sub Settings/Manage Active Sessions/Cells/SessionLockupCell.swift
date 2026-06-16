//
//  SessionLockupCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SessionLockupCell: KTableViewCell {
	@IBOutlet weak var primaryImageView: KImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Properties
	/// Whether the cell represents the current device.
	private var isCurrentDevice: Bool = false

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.selectionStyle = .default
		self.theme_tintColor = KThemePicker.tintColor.rawValue
		self.backgroundColor = .clear
		self.contentView.backgroundColor = .clear
		self.configureSelectionBackground()
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		self.applySelectionAppearance(selected: selected)
	}

	// MARK: - Functions
	/// Applies a transient highlight appearance for tap interactions outside batch-edit mode.
	///
	/// - Parameter highlighted: A boolean value that indicates whether the cell is highlighted.
	func applyHighlightedAppearance(highlighted: Bool) {
		self.applySelectionAppearance(selected: highlighted)
	}

	func configureCell(using session: Session?) {
		guard let session = session else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.configure(
			platform: session.relationships.platform.data.first?.attributes,
			location: session.relationships.location.data.first?.attributes,
			appSource: session.attributes.appSource,
			ipAddress: session.attributes.ipAddress,
			lastValidatedAt: session.attributes.lastValidatedAt,
			isCurrentDevice: false
		)
	}

	func configureCell(using accessToken: AccessToken?, isCurrentDevice: Bool) {
		guard let accessToken = accessToken else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.configure(
			platform: accessToken.relationships.platform.data.first?.attributes,
			location: accessToken.relationships.location.data.first?.attributes,
			appSource: accessToken.attributes.appSource,
			ipAddress: accessToken.attributes.ipAddress,
			lastValidatedAt: accessToken.attributes.lastValidatedAt,
			isCurrentDevice: isCurrentDevice
		)
	}

	/// Configures the cell with a session's shared platform and location details.
	///
	/// - Parameters:
	///    - platform: The platform the session was created on.
	///    - location: The location the session was created from.
	///    - appSource: The source the session was created from.
	///    - ipAddress: The IP address the session was created from.
	///    - lastValidatedAt: The last time the session was validated.
	///    - isCurrentDevice: Whether the session belongs to the current device.
	private func configure(platform: Platform.Attributes?, location: Location.Attributes?, appSource: String?, ipAddress: String, lastValidatedAt: Date?, isCurrentDevice: Bool) {
		self.isCurrentDevice = isCurrentDevice
		self.backgroundView?.theme_backgroundColor = (isCurrentDevice ? KThemePicker.tintedBackgroundColor : KThemePicker.tableViewCellBackgroundColor).rawValue
		self.primaryImageView.image = platform?.deviceImage
		self.primaryLabel.text = self.deviceDescription(for: platform)
		self.secondaryLabel.text = self.contextDescription(for: location, appSource: appSource, ipAddress: ipAddress, lastValidatedAt: lastValidatedAt, isCurrentDevice: isCurrentDevice)
		self.applySelectionAppearance(selected: self.isSelected)
	}

	/// Configures the selection background.
	private func configureSelectionBackground() {
		let backgroundView = UIView()
		backgroundView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.backgroundView = backgroundView

		let selectedBackgroundView = UIView()
		selectedBackgroundView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		self.selectedBackgroundView = selectedBackgroundView

		let multipleSelectionBackgroundView = UIView()
		multipleSelectionBackgroundView.theme_backgroundColor = KThemePicker.tableViewCellSelectedBackgroundColor.rawValue
		self.multipleSelectionBackgroundView = multipleSelectionBackgroundView
	}

	/// Applies the selected or default appearance to the cell's foreground content.
    ///
    /// - Parameter selected: A boolean value that indicates whether the cell is selected.
	private func applySelectionAppearance(selected: Bool) {
		self.primaryLabel.theme_textColor = selected
			? KThemePicker.tableViewCellSelectedTitleTextColor.rawValue
			: KThemePicker.tableViewCellTitleTextColor.rawValue
		self.secondaryLabel.theme_textColor = selected
			? KThemePicker.tableViewCellSelectedSubTextColor.rawValue
			: KThemePicker.tableViewCellSubTextColor.rawValue
	}

	/// Returns the device model and operating system string.
	///
	/// - Parameter platform: The platform the session was created on.
	///
	/// - Returns: A string such as `iPhone15,2 on iOS 17.5`.
	private func deviceDescription(for platform: Platform.Attributes?) -> String {
		let deviceModel = platform?.deviceModel.flatMap { $0.isEmpty ? nil : $0 }
		let system = [platform?.systemName, platform?.systemVersion]
			.compactMap { $0 }
			.filter { !$0.isEmpty }
			.joined(separator: " ")

		if let deviceModel = deviceModel, !system.isEmpty {
			return "\(deviceModel) on \(system)"
		}
		return deviceModel ?? system
	}

	/// Returns the location, IP address, and last activity string.
	///
	/// - Parameters:
	///    - location: The location the session was created from.
	///    - appSource: The source the session was created from.
	///    - ipAddress: The IP address the session was created from.
	///    - lastValidatedAt: The last time the session was validated.
	///    - isCurrentDevice: Whether the session belongs to the current device.
	///
	/// - Returns: A string such as `Kurozora for iOS · Tokyo, Japan · 1.2.3.4 · 2 hours ago`.
	private func contextDescription(for location: Location.Attributes?, appSource: String?, ipAddress: String, lastValidatedAt: Date?, isCurrentDevice: Bool) -> String {
		var components: [String] = []

		if let appSource = appSource, !appSource.isEmpty {
			components.append(appSource)
		}

		let place = [location?.city, location?.country]
			.compactMap { $0 }
			.filter { !$0.isEmpty && $0 != "Unknown" }
			.joined(separator: ", ")
		if !place.isEmpty {
			components.append(place)
		}

		components.append(ipAddress)

		if isCurrentDevice {
			components.append(L10n.thisDevice)
		} else if let lastValidatedAt = lastValidatedAt {
			components.append(lastValidatedAt.formatted(.relative(presentation: .numeric)))
		}

		return components.joined(separator: " · ")
	}
}
