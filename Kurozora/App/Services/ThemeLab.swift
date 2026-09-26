//
//  ThemeLab.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import SwiftTheme
import UIKit

/// Previews the theme files placed in the lab folder.
final class ThemeLab {
	// MARK: - Properties
	/// The shared instance of `ThemeLab`.
	static let shared = ThemeLab()

	/// The folder holding the theme files to preview.
	let directoryURL: URL? = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Themes/Lab", isDirectory: true)

	/// The theme file currently previewed.
	private(set) var appliedThemeURL: URL?

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Returns the theme files in the lab folder sorted by name.
	///
	/// - Returns: the theme files in the lab folder.
	func themeURLs() throws -> [URL] {
		guard let directoryURL = self.directoryURL else {
			throw ThemeStyleError.themeStorageUnavailable
		}

		try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

		return try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
			.filter { $0.pathExtension == "plist" }
			.sorted { self.name(ofThemeAt: $0).localizedStandardCompare(self.name(ofThemeAt: $1)) == .orderedAscending }
	}

	/// Returns the display name of the given theme file.
	///
	/// - Parameter url: The location of the theme file.
	///
	/// - Returns: the display name of the theme file.
	func name(ofThemeAt url: URL) -> String {
		return url.deletingPathExtension().lastPathComponent
	}

	/// Returns the tint color of the given theme file.
	///
	/// - Parameter url: The location of the theme file.
	///
	/// - Returns: the tint color of the theme file.
	func tintColor(ofThemeAt url: URL) -> UIColor? {
		guard let theme = NSDictionary(contentsOf: url) else { return nil }
		guard let global = theme["Global"] as? [String: Any] else { return nil }
		guard let tintColor = global["tintColor"] as? String else { return nil }
		return UIColor(hexString: tintColor)
	}

	/// Applies the given theme file without saving it as the chosen theme.
	///
	/// - Parameter url: The location of the theme file.
	func apply(themeAt url: URL) {
		self.appliedThemeURL = url

		ThemeManager.setTheme(plistName: self.name(ofThemeAt: url), path: .sandbox(url.deletingLastPathComponent()))
		UIApplication.sharedKeyWindow?.overrideUserInterfaceStyle = KThemePicker.statusBarStyle.userInterfaceStyleValue
		NotificationCenter.default.post(name: .KSAppAppearanceDidChange, object: nil)
	}

	/// Applies the theme file the given number of places away from the previewed one.
	///
	/// - Parameter offset: The number of places to move through the lab's theme files.
	func applyTheme(offsetBy offset: Int) {
		do {
			let themeURLs = try self.themeURLs()

			guard !themeURLs.isEmpty else {
				self.showToast("No themes in Library/Themes/Lab", systemImageName: "tray")
				return
			}

			let appliedIndex = self.appliedThemeURL.flatMap { themeURLs.firstIndex(of: $0) }
			let nextIndex: Int

			if let appliedIndex {
				nextIndex = ((appliedIndex + offset) % themeURLs.count + themeURLs.count) % themeURLs.count
			} else {
				nextIndex = offset > 0 ? 0 : themeURLs.count - 1
			}

			let themeURL = themeURLs[nextIndex]
			self.apply(themeAt: themeURL)
			self.showToast("\(self.name(ofThemeAt: themeURL))  \(nextIndex + 1)/\(themeURLs.count)", systemImageName: "swatchpalette.fill")
		} catch {
			self.showToast(error.localizedDescription, systemImageName: "xmark.octagon")
		}
	}

	/// Shows the given message at the top of the key window.
	///
	/// - Parameters:
	///    - message: The message to show.
	///    - systemImageName: The name of the symbol shown beside the message.
	private func showToast(_ message: String, systemImageName: String) {
		guard let window = UIApplication.sharedKeyWindow else { return }
		let toast = ToastButton(message: message, systemImageName: systemImageName)

		window.addSubview(toast)

		NSLayoutConstraint.activate([
			toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
			toast.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
			toast.leadingAnchor.constraint(greaterThanOrEqualTo: window.layoutMarginsGuide.leadingAnchor),
			toast.trailingAnchor.constraint(lessThanOrEqualTo: window.layoutMarginsGuide.trailingAnchor)
		])

		toast.present(feedback: nil)
	}
}
#endif
