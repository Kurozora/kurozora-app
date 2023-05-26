//
//  AppThemeFilter.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 26/04/2023.
//

public struct AppThemeFilter: Equatable {
	// MARK: - Properties
	public let downloadCount: Int?
	public let uiStatusBarStyle: Int?
	public let version: String?

	// MARK: - Initializers
	public init(downloadCount: Int?, uiStatusBarStyle: Int?, version: String?) {
		self.downloadCount = downloadCount
		self.uiStatusBarStyle = uiStatusBarStyle
		self.version = version
	}
}

// MARK: - Filterable
extension AppThemeFilter: Filterable {
	func toFilterArray() -> [String: Any?] {
		return [
			"download_count": self.downloadCount,
			"ui_status_bar_style": self.uiStatusBarStyle,
			"version": self.version
		]
	}
}
