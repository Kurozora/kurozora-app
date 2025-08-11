//
//  KThemeStyle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/02/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import CoreLocation
import Solar
import SwiftTheme

/// List of app-wide theme styles.
///
/// ```
/// case `default` = 0
/// case day = 1
/// case night = 2
/// case other = 3
/// ```
enum KThemeStyle: Int {
	// MARK: - Cases
	/// The default style of the app with purple background.
	case `default` = 0

	/// The day style of the app with white background and bright colors.
	case day = 1

	/// The night style of the app with black background and darker colors.
	case night = 2

	/// The grass style of the app with green background and bright colors.
	case grass = 3

	/// The sky style of the app with blue background and bright colors.
	case sky = 4

	/// The sakura style of the app with pink background and bright colors.
	case sakura = 5

	/// Other styles of the app.
	case other = 6

	// MARK: Variables
	// FileManager variables
	fileprivate static let cachesURL = FileManager.SearchPathDirectory.cachesDirectory
	fileprivate static let libraryURL = FileManager.SearchPathDomainMask.userDomainMask
	fileprivate static let libraryDirectoryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
	fileprivate static let themesDirectoryUrl = libraryDirectoryUrl?.appendingPathComponent("Themes/")

	// Theme variables
	fileprivate static var current: KThemeStyle = .default
	fileprivate static var before: KThemeStyle = .default

	// Timer variables
	fileprivate static var automaticDarkThemeSchedule: Timer?
	fileprivate static let calendar = Calendar.current

	/// The string value of the KThemeStyle type.
	var stringValue: String {
		switch self {
		case .default:
			return "Kurozora"
		case .day:
			return "Day"
		case .night:
			return "Night"
		case .grass:
			return "Grass"
		case .sky:
			return "Sky"
		case .sakura:
			return "Sakura"
		case .other:
			return "Other"
		}
	}

	/// The plist value of the KThemeStyle type.
	var plistValue: String {
		switch self {
		case .default:
			return "Default"
		case .night:
			return UserSettings.trueBlackEnabled ? "Black" : self.stringValue
		default:
			return self.stringValue
		}
	}

	// MARK: - Functions
	/// Initializes the app's global theme.
	static func initAppTheme() {
		if UserSettings.automaticDarkTheme {
			KThemeStyle.startAutomaticDarkThemeSchedule(true)
		} else if !UserSettings.currentTheme.isEmpty {
			let currentTheme = UserSettings.currentTheme

			// If themeID is an integer
			if let themeID = Int(currentTheme) {
				// Use a non default theme if it exists
				if let themeDirectoryURLPath = self.themesDirectoryUrl?.appendingPathComponent("theme-\(themeID).plist").path, FileManager.default.fileExists(atPath: themeDirectoryURLPath) {
					KThemeStyle.switchTo(themeID: themeID.string)
				} else {
					// Fallback to default if theme doesn't exist
					KThemeStyle.switchTo(style: .day)
				}
			} else {
				// Use one of the chosen default themes
				let themeStyle = KThemeStyle.themeValue(from: currentTheme)
				KThemeStyle.switchTo(style: themeStyle)
			}
		} else {
			// Fallback to default if no theme is chosen
			KThemeStyle.switchTo(style: .default)
		}

		UIApplication.shared.theme_setStatusBarStyle(ThemeStatusBarStylePicker(keyPath: KThemePicker.statusBarStyle.stringValue), animated: true)
	}

	/// Return a KThemeStyle value for a given string.
	///
	/// - Parameter string: The string from which a
	///
	/// - Returns: a `KThemeStyle` reflecting the given string.
	static func themeValue(from string: String) -> KThemeStyle {
		switch string {
		case "Kurozora":
			return .default
		case "Day":
			return .day
		case "Night":
			return .night
		case "Grass":
			return .grass
		case "Sky":
			return .sky
		case "Sakura":
			return .sakura
		default: // a.k.a "Other"
			return .other
		}
	}

	/// Starts automatic dark theme scheduel if it hasn't been started before.
	static func startAutomaticDarkThemeSchedule(_ firstTime: Bool = false) {
		if firstTime {
			KThemeStyle.checkAutomaticSchedule()
		}

		if self.automaticDarkThemeSchedule == nil {
			self.automaticDarkThemeSchedule = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
				KThemeStyle.checkAutomaticSchedule()
			}
		}
	}

	/// Returns whether the given theme matches the expected version.
	///
	/// - Parameters:
	///    - themeID: The theme used to compare the version.
	///    - version: The expected version.
	///
	/// - Returns: whether the given theme matches the expected version.
	static func isUpToDate(_ themeID: String, version: String) -> Bool {
		guard let themesDirectoryUrl = themesDirectoryUrl else { return true }
		guard let themeContents = FileManager.default.contents(atPath: themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist").path) else { return true }
		guard let theme = try? PropertyListSerialization.propertyList(from: themeContents, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] else { return true }
		guard let themeVersion = theme["Version"] as? String else { return true }
		return themeVersion == version
	}
}

// MARK: - Switch Theme
extension KThemeStyle {
	/// Switch theme to one of the default styles.
	///
	/// - Parameter style: The `KThemeStyle` to which to switch to.
	static func switchTo(style: KThemeStyle) {
		self.before = self.current
		self.current = style

		UserSettings.set(style.stringValue, forKey: .currentTheme)
		ThemeManager.setTheme(plistName: style.plistValue, path: .mainBundle)

		switch style {
		case .default, .night:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .dark
		case .day, .grass, .sky, .sakura:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .light
		case .other:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .unspecified
		}

		NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil)
	}

	/// Switch theme based on the passed theme name.
	///
	/// - Parameter themeName: A string value reflecting the name of the theme.
	static func switchTo(themeName: String) {
		self.before  = self.current
		self.current = themeValue(from: themeName)

		UserSettings.set(themeName, forKey: .currentTheme)
		ThemeManager.setTheme(plistName: themeName, path: .mainBundle)

		switch self.current {
		case .day, .grass, .sky, .sakura:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .light
		case .night, .default:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .dark
		default:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .unspecified
		}

		NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil)
	}

	/// Switch theme based on the passed `AppTheme` object.
	///
	/// - Parameter appTheme: The `AppTheme` object to switch to.
	static func switchTo(appTheme: AppTheme) {
		self.before  = self.current
		self.current = .other

		self.setTheme(themeID: appTheme.id)
	}

	/// Switch theme based on the passed theme id.
	///
	/// - Parameter themeID: An integer value reflecting the ID of the theme.
	static func switchTo(themeID: String) {
		self.before  = self.current
		self.current = .other

		self.setTheme(themeID: themeID)
	}

	/// Sets the theme with the given `Theme` object.
	///
	/// - Parameter theme: The `Theme` object used to set the theme.
	fileprivate static func setTheme(themeID: String) {
		UserSettings.set(themeID, forKey: .currentTheme)
		guard let themesDirectoryUrl = self.themesDirectoryUrl else { return }
		ThemeManager.setTheme(plistName: "theme-\(themeID)", path: .sandbox(themesDirectoryUrl))
		UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = KThemePicker.statusBarStyle.userInterfaceStyleValue
		NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil)
	}
}

// MARK: - Download
extension KThemeStyle {
	/// Remove a theme for a given theme element.
	///
	/// - Parameters:
	///    - appTheme: The app theme element which contains the link.
	///    - successHandler: A closure returning a boolean indicating whether remove is successful.
	///    - isSuccess: A boolean value indicating whether the remove is successful.
	static func removeThemeTask(for appTheme: AppTheme, _ successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		guard let themesDirectoryUrl = self.themesDirectoryUrl else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}

		do {
			try FileManager.default.removeItem(at: themesDirectoryUrl.appendingPathComponent("theme-\(appTheme.id).plist"))

			DispatchQueue.main.async {
				successHandler(!self.themeExist(for: appTheme))
			}
		} catch {
			DispatchQueue.main.async {
				successHandler(self.themeExist(for: appTheme))
			}
		}
	}

	/// Downlaoad a theme for a given theme element.
	///
	/// - Parameters:
	///    - appTheme: The app theme element which contains the link.
	///    - successHandler: A closure returning a boolean indicating whether download is successful.
	///    - isSuccess: A boolean value indicating whether the download is successful.
	static func downloadThemeTask(for appTheme: AppTheme, _ successHandler: @escaping (_ isSuccess: Bool) -> Void) {
		let urlString = appTheme.attributes.downloadLink
		guard let libraryDirectoryUrl = self.libraryDirectoryUrl else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}
		guard let themesDirectoryUrl = self.themesDirectoryUrl else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}

		let sessionConfig = URLSessionConfiguration.default
		sessionConfig.headers = [
			.authorization(bearerToken: KService.authenticationKey),
			.init(name: "X-API-Key", value: KService.apiKey),
			.defaultUserAgent
		]
		let session = URLSession(configuration: sessionConfig)
		guard let request = try? URLRequest(url: urlString, method: .get) else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}

		let task = session.downloadTask(with: request) { tempLocalUrl, response, error in
			if let tempLocalUrl = tempLocalUrl, error == nil {
				// Reponse code
				if let statusCode = (response as? HTTPURLResponse)?.statusCode {
					print("Success: \(statusCode)")
				}

				// Create Themes folder if it doesn't exist
				if !self.directoryExist(atPath: themesDirectoryUrl.path) {
					do {
						try FileManager.default.createDirectory(atPath: libraryDirectoryUrl.appendingPathComponent("Themes/").path, withIntermediateDirectories: true, attributes: nil)
					} catch {
						DispatchQueue.main.async {
							successHandler(self.themeExist(for: appTheme))
						}
					}
				}

				// Move file to Themes folder
				do {
					try FileManager.default.copyItem(at: tempLocalUrl, to: themesDirectoryUrl.appendingPathComponent("theme-\(appTheme.id).plist"))
					DispatchQueue.main.async {
						successHandler(self.themeExist(for: appTheme))
					}
				} catch {
					DispatchQueue.main.async {
						successHandler(self.themeExist(for: appTheme))
					}
				}
			} else {
				DispatchQueue.main.async {
					successHandler(self.themeExist(for: appTheme))
				}
			}
		}
		task.resume()
	}

	/// Check if directory exists at a given path.
	///
	/// - Parameter path: The string of the path which should be checked.
	///
	/// - Returns: a boolean indicating whether a path exists.
	static func directoryExist(atPath path: String) -> Bool {
		var isDirectory = ObjCBool(true)
		let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		return exists && isDirectory.boolValue
	}

	/// Check if theme exists for a given app theme.
	///
	/// - Parameter appTheme: The app theme which should be checked
	///
	/// - Returns: a boolean indicating whether a theme exists.
	static func themeExist(for appTheme: AppTheme) -> Bool {
		guard let themesDirectoryUrl = self.themesDirectoryUrl else { return false }
		let themeFileDirectoryUrl: URL = themesDirectoryUrl.appendingPathComponent("theme-\(appTheme.id).plist")
		return FileManager.default.fileExists(atPath: themeFileDirectoryUrl.path)
	}
}

// MARK: - Icon
extension KThemeStyle {
	/// Changes the app icon to a given icon name.
	///
	/// - Parameter iconName: The name of the icon to switch to.
	static func changeIcon(to iconName: String?) {
		// Check if app supports alternate icons
		guard UIApplication.shared.supportsAlternateIcons else { return }

		// Set alternate icon
		UIApplication.shared.setAlternateIconName(iconName) { error in
			if let error = error {
				print("App icon failed to change due to \(error.localizedDescription)")
			} else {
				print("App icon changed successfully")
			}
		}
	}
}

// MARK: - Night theme
extension KThemeStyle {
	/// Whether the specified custom `start` and `end` time is in daytime on `date`.
	static var isCustomDaytime: Bool {
		let startTime = UserSettings.darkThemeOptionStart
		let startHour = calendar.component(.hour, from: startTime)
		let startMinute = calendar.component(.minute, from: startTime)

		let endTime = UserSettings.darkThemeOptionEnd
		let endHour = calendar.component(.hour, from: endTime)
		let endMinute = calendar.component(.minute, from: endTime)

		guard let calendarStartTime = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: Date()) else { return false }
		guard let calendarEndTime = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: Date()) else { return false }

		let beginningOfDay = calendarStartTime.timeIntervalSince1970
		let endOfDay = calendarEndTime.timeIntervalSince1970
		let currentTime = Date().timeIntervalSince1970

		let isStartOrLater = currentTime >= beginningOfDay
		let isBeforeEnd = currentTime < endOfDay

		return isStartOrLater && isBeforeEnd
	}

	/// Whether the specified custom `start` and `end` time is in nighttime on `date`.
	static var isCustomNighttime: Bool {
		return !self.isCustomDaytime
	}

	/// Switch between Night them and the theme before.
	///
	/// - Parameter isToNight: A boolean indicating whether to switch to night theme.
	static func switchNight(_ isToNight: Bool) {
		if self.before == .night && self.current == .night {
			self.switchTo(style: .day)
		} else {
			self.switchTo(style: isToNight ? .night : self.before)
		}
	}

	/// Decides whether the current theme is the `Night` theme.
	///
	/// - Returns: a boolean value indicating if current theme is the Night theme.
	static func isNightTheme() -> Bool {
		return self.current == .night
	}

	/// Wheather it's currently night time.
	static var isSolarNighttime: Bool {
		guard let currentUserSession = User.current?.relationships?.accessTokens?.data.first else { return false }
		guard let userSessionLocation = currentUserSession.relationships.location.data.first else { return false }
		guard let latitude = userSessionLocation.attributes.latitude else { return false }
		guard let longitude = userSessionLocation.attributes.longitude else { return false }
		guard let solar = Solar(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) else { return false }
		let isNighttime = solar.isNighttime

		return isNighttime
	}

	/// Switch between Light and Dark theme according to `sunrise` and `sunset` or custom `start` and `end` time.
	static func checkAutomaticSchedule() {
		if UserSettings.automaticDarkTheme, let darkThemeOption = DarkThemeOption(rawValue: UserSettings.darkThemeOption) {
			if self.isSolarNighttime && darkThemeOption == .automatic && self.current != .night || self.isCustomNighttime && darkThemeOption == .custom  && self.current != .night {
				self.before = self.current

				KThemeStyle.switchTo(style: .night)
				self.current = .night
				UserSettings.set(1, forKey: .appearanceOption)
				NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["option": 1])
			} else if !self.isSolarNighttime && darkThemeOption == .automatic && self.current != .day || !self.isCustomNighttime && darkThemeOption == .custom  && self.current != .day {
				self.before = self.current

				KThemeStyle.switchTo(style: .day)
				self.current = .day
				NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["option": 0])
				UserSettings.set(0, forKey: .appearanceOption)
			}
		}
	}
}
