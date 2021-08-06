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

/**
	List of app-wide theme styles.

	```
	case `default` = 0
	case day = 1
	case night = 2
	case other = 3
	```
*/
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
				if let themeDirectoryURLPath = themesDirectoryUrl?.appendingPathComponent("theme-\(themeID).plist").path, FileManager.default.fileExists(atPath: themeDirectoryURLPath) {
					KThemeStyle.switchTo(themeID: themeID)
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

	/**
		Return a KThemeStyle value for a given string.

		- Parameter string: The string from which a

		- Returns: a `KThemeStyle` reflecting the given string.
	*/
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

		if automaticDarkThemeSchedule == nil {
			automaticDarkThemeSchedule = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
				KThemeStyle.checkAutomaticSchedule()
			}
		}
	}

	/**
		Returns whether the given theme matches the expected version.

		- Parameter themeID: The theme used to compare the version.
		- Parameter version: The expected version.

		- Returns: whether the given theme matches the expected version.
	*/
	static func isUpToDate(_ themeID: Int, version: String) -> Bool {
		guard let themesDirectoryUrl = themesDirectoryUrl else { return true }
		guard let themeContents = FileManager.default.contents(atPath: themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist").path) else { return true }
		guard let theme = try? PropertyListSerialization.propertyList(from: themeContents, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] else { return true }
		guard let themeVersion = theme["Version"] as? String else { return true }
		return themeVersion == version
	}
}

// MARK: - Switch Theme
extension KThemeStyle {
	/**
		Switch theme to one of the default styles.

		- Parameter style: The `KThemeStyle` to which to switch to.
	*/
	static func switchTo(style: KThemeStyle) {
		before = current
		current = style

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
	}

	/**
		Switch theme based on the passed theme name.

		- Parameter themeName: A string value reflecting the name of the theme.
	*/
	static func switchTo(themeName: String) {
		before  = current
		current = themeValue(from: themeName)

		UserSettings.set(themeName, forKey: .currentTheme)
		ThemeManager.setTheme(plistName: themeName, path: .mainBundle)

		switch current {
		case .day, .grass, .sky, .sakura:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .light
		case .night, .default:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .dark
		default:
			UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = .unspecified
		}
	}

	/**
		Switch theme based on the passed `Theme` object.

		- Parameter theme: The `Theme` object to switch to.
	*/
	static func switchTo(theme: Theme) {
		before  = current
		current = .other

		self.setTheme(themeID: theme.id)
	}

	/**
		Switch theme based on the passed theme id.

		- Parameter themeID: An integer value reflecting the ID of the theme.
	*/
	static func switchTo(themeID: Int) {
		before  = current
		current = .other

		self.setTheme(themeID: themeID)
	}

	/**
		Sets the theme with the given `Theme` object.

		- Parameter theme: The `Theme` object used to set the theme.
	*/
	fileprivate static func setTheme(themeID: Int) {
		UserSettings.set("\(themeID)", forKey: .currentTheme)
		guard let themesDirectoryUrl = themesDirectoryUrl else { return }
		ThemeManager.setTheme(plistName: "theme-\(themeID)", path: .sandbox(themesDirectoryUrl))
		UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = KThemePicker.statusBarStyle.userInterfaceStyleValue
	}
}

// MARK: - Download
extension KThemeStyle {
	/**
		Remove a theme for a given theme element.

		- Parameter theme: The theme element which contains the link.
		- Parameter successHandler: A closure returning a boolean indicating whether remove is successful.
		- Parameter isSuccess: A boolean value indicating whether the remove is successful.
	*/
	static func removeThemeTask(for theme: Theme, _ successHandler:@escaping (_ isSuccess: Bool) -> Void) {
		guard let themesDirectoryUrl = themesDirectoryUrl else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}

		do {
			try FileManager.default.removeItem(at: themesDirectoryUrl.appendingPathComponent("theme-\(theme.id).plist"))

			DispatchQueue.main.async {
				successHandler(!themeExist(for: theme))
			}
		} catch {
			DispatchQueue.main.async {
				successHandler(themeExist(for: theme))
			}
		}
	}

	/**
		Downlaoad a theme for a given theme element.

		- Parameter theme: The theme element which contains the link.
		- Parameter successHandler: A closure returning a boolean indicating whether download is successful.
		- Parameter isSuccess: A boolean value indicating whether the download is successful.
	*/
	static func downloadThemeTask(for theme: Theme, _ successHandler:@escaping (_ isSuccess: Bool) -> Void) {
		let urlString = theme.attributes.downloadLink
		guard let libraryDirectoryUrl = libraryDirectoryUrl else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}
		guard let themesDirectoryUrl = themesDirectoryUrl else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}

		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig)
		guard let request = try? URLRequest(url: urlString, method: .get) else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}

		let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
			if let tempLocalUrl = tempLocalUrl, error == nil {
				// Reponse code
				if let statusCode = (response as? HTTPURLResponse)?.statusCode {
					print("Success: \(statusCode)")
				}

				// Create Themes folder if it doesn't exist
				if !directoryExist(atPath: themesDirectoryUrl.path) {
					do {
						try FileManager.default.createDirectory(atPath: libraryDirectoryUrl.appendingPathComponent("Themes/").path, withIntermediateDirectories: true, attributes: nil)
					} catch {
						DispatchQueue.main.async {
							successHandler(themeExist(for: theme))
						}
					}
				}

				// Move file to Themes folder
				do {
					try FileManager.default.copyItem(at: tempLocalUrl, to: themesDirectoryUrl.appendingPathComponent("theme-\(theme.id).plist"))
					DispatchQueue.main.async {
						successHandler(themeExist(for: theme))
					}
				} catch {
					DispatchQueue.main.async {
						successHandler(themeExist(for: theme))
					}
				}
			} else {
				DispatchQueue.main.async {
					successHandler(themeExist(for: theme))
				}
			}
		}
		task.resume()
	}

	/**
		Check if directory exists at a given path.

		- Parameter path: The string of the path which should be checked.

		- Returns: a boolean indicating whether a path exists.
	*/
	static func directoryExist(atPath path: String) -> Bool {
		var isDirectory = ObjCBool(true)
		let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		return exists && isDirectory.boolValue
	}

	/**
		Check if theme exists for a given theme ID.

		- Parameter themeID: The theme ID which should be checked

		- Returns: a boolean indicating whether a theme exists.
	*/
	static func themeExist(for theme: Theme) -> Bool {
		guard let themesDirectoryUrl = themesDirectoryUrl else { return false }
		let themeFileDirectoryUrl: URL = themesDirectoryUrl.appendingPathComponent("theme-\(theme.id).plist")
		return FileManager.default.fileExists(atPath: themeFileDirectoryUrl.path)
	}
}

// MARK: - Icon
extension KThemeStyle {
	/**
		Changes the app icon to a given icon name.

		- Parameter iconName: The name of the icon to switch to.
	*/
	static func changeIcon(to iconName: String?) {
		// Check if app supports alternate icons
		guard UIApplication.shared.supportsAlternateIcons else { return }

		// Set alternate icon
		UIApplication.shared.setAlternateIconName(iconName, completionHandler: { (error) in
			if let error = error {
				print("App icon failed to change due to \(error.localizedDescription)")
			} else {
				print("App icon changed successfully")
			}
		})
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
		return !isCustomDaytime
	}

	/**
		Switch between Night them and the theme before.

		- Parameter isToNight: A boolean indicating whether to switch to night theme.
	*/
	static func switchNight(_ isToNight: Bool) {
		if before == .night && current == .night {
			switchTo(style: .day)
		} else {
			switchTo(style: isToNight ? .night : before)
		}
	}

	/**
		Decides whether the current theme is the `Night` theme.

		- Returns: a boolean value indicating if current theme is the Night theme.
	*/
	static func isNightTheme() -> Bool {
		return current == .night
	}

	/// Wheather it's currently night time.
	static var isSolarNighttime: Bool {
		guard let currentUserSession = User.current?.relationships?.sessions?.data.first else { return false }
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
			if isSolarNighttime && darkThemeOption == .automatic && current != .night || isCustomNighttime && darkThemeOption == .custom  && current != .night {
				before = current

				KThemeStyle.switchTo(style: .night)
				current = .night
				UserSettings.set(1, forKey: .appearanceOption)
				NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["option": 1])
			} else if !isSolarNighttime && darkThemeOption == .automatic && current != .day || !isCustomNighttime && darkThemeOption == .custom  && current != .day {
				before = current

				KThemeStyle.switchTo(style: .day)
				current = .day
				NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["option": 0])
				UserSettings.set(0, forKey: .appearanceOption)
			}
		}
	}
}
