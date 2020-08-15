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

	/// Other styles of the app.
	case other = 3

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

	/// The string value for a given KThemeStyle.
	var stringValue: String {
		switch self {
		case .default:
			return "Default"
		case .day:
			return "Day"
		case .night:
			return "Night"
		case .other:
			return "Other"
		}
	}

	// MARK: - Functions
	/// Initializes the app's global theme.
	static func initAppTheme() {
		if UserSettings.automaticDarkTheme {
			KThemeStyle.startAutomaticDarkThemeSchedule(true)
		} else if !UserSettings.currentTheme.isEmpty {
			let currentThemeID = UserSettings.currentTheme

			// If themeID is an integer
			if let themeID = Int(currentThemeID) {
				// Use a non default theme if it exists
				if let themeDirectoryURLPath = themesDirectoryUrl?.appendingPathComponent("theme-\(themeID).plist").path, FileManager.default.fileExists(atPath: themeDirectoryURLPath) {
					KThemeStyle.switchTo(theme: themeID)
				} else {
					// Fallback to default if theme doesn't exist
					KThemeStyle.switchTo(.day)
				}
			} else {
				// Use one of the chosen default themes
				KThemeStyle.switchTo(theme: currentThemeID)
			}
		} else {
			// Fallback to default if no theme is chosen
			KThemeStyle.switchTo(.default)
		}
	}

	/**
		Return a KThemeStyle value for a given string.

		- Parameter string: The string from which a

		- Returns: a `KThemeStyle` reflecting the given string.
	*/
	static func themeValue(from string: String) -> KThemeStyle {
		switch string {
		case "Default":
			return .default
		case "Day":
			return .day
		case "Night":
			return .night
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
			automaticDarkThemeSchedule = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
				KThemeStyle.checkAutomaticSchedule()
			}
		}
	}
}

// MARK: - Switch Theme
extension KThemeStyle {
	/**
		Switch theme to one of the default styles.

		- Parameter style: The `KThemeStyle` to which to switch to.
	*/
	static func switchTo(_ style: KThemeStyle) {
		before = current
		current = style

		switch style {
		case .default:
			UserSettings.set("Default", forKey: .currentTheme)
			ThemeManager.setTheme(plistName: "Default", path: .mainBundle)
			if #available(iOS 13.0, *) {
				UIApplication.topViewController?.overrideUserInterfaceStyle = .dark
			}
		case .day:
			UserSettings.set("Day", forKey: .currentTheme)
			ThemeManager.setTheme(plistName: "Day", path: .mainBundle)
			if #available(iOS 13.0, *) {
				UIApplication.topViewController?.overrideUserInterfaceStyle = .light
			}
		case .night:
			if UserSettings.trueBlackEnabled {
				UserSettings.set("Black", forKey: .currentTheme)
				ThemeManager.setTheme(plistName: "Black", path: .mainBundle)
			} else {
				UserSettings.set("Night", forKey: .currentTheme)
				ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
			}

			if #available(iOS 13.0, *) {
				UIApplication.topViewController?.overrideUserInterfaceStyle = .dark
			}
		case .other:
			if #available(iOS 13.0, *) {
				UIApplication.topViewController?.overrideUserInterfaceStyle = .unspecified
			}
		}
	}

	/**
		Switch theme based on the passed theme name.

		- Parameter themeName: A string value reflecting the name of the theme.
	*/
	static func switchTo(theme themeName: String) {
		before  = current
		current = themeValue(from: themeName)

		UserSettings.set(themeName, forKey: .currentTheme)
		ThemeManager.setTheme(plistName: themeName, path: .mainBundle)

		if #available(iOS 13.0, *) {
			switch current {
			case .day:
				UIApplication.topViewController?.overrideUserInterfaceStyle = .light
			case .night, .default:
				UIApplication.topViewController?.overrideUserInterfaceStyle = .dark
			default:
				UIApplication.topViewController?.overrideUserInterfaceStyle = .unspecified
			}
		}
	}

	/**
		Switch theme based on the passed theme id.

		- Parameter themeID: An integer value reflecting the ID of the theme.
	*/
	static func switchTo(theme themeID: Int) {
		before  = current
		current = .other

		UserSettings.set("\(themeID)", forKey: .currentTheme)
		guard let themesDirectoryUrl = themesDirectoryUrl else { return }
		ThemeManager.setTheme(plistName: "theme-\(themeID)", path: .sandbox(themesDirectoryUrl))
	}

	/**
		Switch to one of the next default styles while ommiting Night theme.

		- Parameter themeID: An integer value reflecting the ID of the theme.
	*/
	static func switchToNext(theme themeID: Int) {
		var next = current.rawValue + 1
		var max  = 1 // without Night

		if themeExist(for: themeID) { max += 1 }
		if next >= max { next = 0 }

		switchTo(KThemeStyle(rawValue: next)!)
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
		let themeID = theme.id
		guard let themesDirectoryUrl = themesDirectoryUrl else {
			DispatchQueue.main.async {
				successHandler(false)
			}
			return
		}

		do {
			try FileManager.default.removeItem(at: themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist"))

			DispatchQueue.main.async {
				successHandler(!themeExist(for: themeID))
			}
		} catch {
			DispatchQueue.main.async {
				successHandler(themeExist(for: themeID))
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
		let themeID = theme.id
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
							successHandler(themeExist(for: themeID))
						}
					}
				}

				// Move file to Themes folder
				do {
					try FileManager.default.copyItem(at: tempLocalUrl, to: themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist"))
					DispatchQueue.main.async {
						successHandler(themeExist(for: themeID))
					}
				} catch {
					DispatchQueue.main.async {
						successHandler(themeExist(for: themeID))
					}
				}
			} else {
				DispatchQueue.main.async {
					successHandler(themeExist(for: themeID))
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
	static func themeExist(for themeID: Int?) -> Bool {
		guard let themeID = themeID else { return false }
		guard let themesDirectoryUrl = themesDirectoryUrl else { return false }
		let themeFileDirectoryUrl: URL = themesDirectoryUrl.appendingPathComponent("theme-\(themeID).plist")
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
			switchTo(.day)
		} else {
			switchTo(isToNight ? .night : before)
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

				KThemeStyle.switchTo(.night)
				current = .night
				UserSettings.set(1, forKey: .appearanceOption)
				NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["option": 1])
			} else if !isSolarNighttime && darkThemeOption == .automatic && current != .day || !isCustomNighttime && darkThemeOption == .custom  && current != .day {
				before = current

				KThemeStyle.switchTo(.day)
				current = .day
				NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil, userInfo: ["option": 0])
				UserSettings.set(0, forKey: .appearanceOption)
			}
		}
	}
}
