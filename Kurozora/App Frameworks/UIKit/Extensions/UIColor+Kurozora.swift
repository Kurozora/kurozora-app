//
//  UIColor+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

extension UIColor {
	// MARK: - General
	/// Aozora purple color of value `#8C50A3`.
	static let aozora: UIColor = #colorLiteral(red: 0.5490196078, green: 0.3137254902, blue: 0.6392156863, alpha: 1)

	/// Kurozora orange color of value `#FF9300`.
	static let kurozora: UIColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)

	/// Kurozora green color of value `#37D321`.
	static let kGreen: UIColor = #colorLiteral(red: 0.2156862745, green: 0.8274509804, blue: 0.1294117647, alpha: 1)

	/// Kurozora light red color of value `#FF4158`.
	static let kLightRed: UIColor = #colorLiteral(red: 1, green: 0.2549019608, blue: 0.3450980392, alpha: 1)

	/// Kurozora dark red color of value `#D0021B`.
	static let kDarkRed: UIColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)

	/// Kurozora yellow color value `#FDD35E`.
	static let kYellow: UIColor = #colorLiteral(red: 0.9921568627, green: 0.8274509804, blue: 0.368627451, alpha: 1)

	/// Kurozora charcoal color value `#353A50`.
	static let kGrayishNavy: UIColor = #colorLiteral(red: 0.2078431373, green: 0.2274509804, blue: 0.3137254902, alpha: 1)

	// MARK: - External Sites
	/// Anilist color value `#262F3E`.
	static let anilist: UIColor = #colorLiteral(red: 0.1490196078, green: 0.1843137255, blue: 0.2431372549, alpha: 1)

	/// Crunchyroll color value `#F78B2E`.
	static let crunchyroll: UIColor = #colorLiteral(red: 0.968627451, green: 0.5450980392, blue: 0.1803921569, alpha: 1)

	/// Daisuki color value `#111111`.
	static let daisuki: UIColor = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 1)

	/// Funimation color value `#1C1D1D`.
	static let funimation: UIColor = #colorLiteral(red: 0.1098039216, green: 0.1137254902, blue: 0.1137254902, alpha: 1)

	/// Hummingbird color value `#EC8661`.
	static let hummingbird: UIColor = #colorLiteral(red: 0.9254901961, green: 0.5254901961, blue: 0.3803921569, alpha: 1)

	/// MyAnimeList color value `#2E51A2`.
	static let myAnimeList: UIColor = #colorLiteral(red: 0.1803921569, green: 0.3176470588, blue: 0.6352941176, alpha: 1)

	/// Official site color value `#FDD35E`.
	static let officialSite: UIColor = #colorLiteral(red: 0.9907178283, green: 0.8274499178, blue: 0.3669273257, alpha: 1)

	/// Other color value `#77C344`.
	static let other: UIColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)

	// MARK: - Library status
	/// Green color of value `#56FF43`.
	static let watching: UIColor = #colorLiteral(red: 0.337254902, green: 1, blue: 0.262745098, alpha: 1)

	/// Blue color of value `#03A9F4`.
	static let completed: UIColor = #colorLiteral(red: 0.01176470588, green: 0.662745098, blue: 0.9568627451, alpha: 1)

	/// Yellow color of value `#F5B433`.
	static let planning: UIColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)

	/// Red color of value `#FF4158`.
	static let onHold: UIColor = #colorLiteral(red: 1, green: 0.2549019608, blue: 0.3450980392, alpha: 1)

	/// Gray color of value `#646464`.
	static let dropped: UIColor = #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 1)

	// MARK: - Properties
	/// RGB components for a Color (between 0 and 255).
	///
	///     UIColor.red.rgbComponents.red -> 255
	///     NSColor.green.rgbComponents.green -> 255
	///     UIColor.blue.rgbComponents.blue -> 255
	///
	var rgbComponents: (red: Int, green: Int, blue: Int) {
		let components: [CGFloat] = {
			let comps: [CGFloat] = cgColor.components!
			guard comps.count != 4 else { return comps }
			return [comps[0], comps[0], comps[0], comps[1]]
		}()
		let red = components[0]
		let green = components[1]
		let blue = components[2]
		return (red: Int(red * 255.0), green: Int(green * 255.0), blue: Int(blue * 255.0))
	}

	/// Whether the color contrast is light or dark.
	///
	/// This uses the algorithm proposed by [W3](https://www.w3.org/WAI/ER/WD-AERT/#color-contrast)
	///
	/// Returns: a boolean indicating whether the color contrast is light or dark.
	var isLight: Bool {
		let (red, green, blue) = self.rgbComponents
		let colorContrast = ((red * 299) + (green * 587) + (blue * 114)) / 1000
		return colorContrast > 125
	}

	// MARK: - Initializers
	/// Create Color from RGB values with optional transparency.
	///
	/// - Parameters:
	///   - red: red component.
	///   - green: green component.
	///   - blue: blue component.
	///   - transparency: optional transparency value (default is 1).
	convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
		guard red >= 0, red <= 255 else { return nil }
		guard green >= 0, green <= 255 else { return nil }
		guard blue >= 0, blue <= 255 else { return nil }

		var trans = transparency
		if trans < 0 { trans = 0 }
		if trans > 1 { trans = 1 }

		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
	}

	/// Create Color from hexadecimal string with optional transparency (if applicable).
	///
	/// - Parameters:
	///   - hexString: hexadecimal string (examples: EDE7F6, 0xEDE7F6, #EDE7F6, #0ff, 0xF0F, ..).
	///   - transparency: optional transparency value (default is 1).
	convenience init?(hexString: String, transparency: CGFloat = 1) {
		var string = ""
		let lowercaseHexString = hexString.lowercased()
		if lowercaseHexString.hasPrefix("0x") {
			string = lowercaseHexString.replacingOccurrences(of: "0x", with: "")
		} else if hexString.hasPrefix("#") {
			string = hexString.replacingOccurrences(of: "#", with: "")
		} else {
			string = hexString
		}

		if string.count == 3 { // convert hex to 6 digit format if in short format
			var str = ""
			string.forEach { str.append(String(repeating: String($0), count: 2)) }
			string = str
		}

		guard let hexValue = Int(string, radix: 16) else { return nil }

		var trans = transparency
		if trans < 0 { trans = 0 }
		if trans > 1 { trans = 1 }

		let red = (hexValue >> 16) & 0xFF
		let green = (hexValue >> 8) & 0xFF
		let blue = hexValue & 0xFF
		self.init(red: red, green: green, blue: blue, transparency: trans)
	}

	// MARK: - Functions
	/// Lighten a color.
	///
	/// ```swift
	/// let color = UIColor.orange
	/// let lighterColor: Color = color.lighten(by: 0.2)
	/// ```
	///
	/// - Parameter percentage: Percentage by which to lighten the color.
	/// - Returns: A lightened color.
	func lighten(by percentage: CGFloat = 0.2) -> UIColor {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return UIColor(
			red: min(red + percentage, 1.0),
			green: min(green + percentage, 1.0),
			blue: min(blue + percentage, 1.0),
			alpha: alpha
		)
	}

	/// Darken a color.
	///
	/// ```swift
	/// let color = UIColor.orange
	/// let darkerColor: Color = color.darken(by: 0.2)
	/// ```
	///
	/// - Parameter percentage: Percentage by which to darken the color.
	/// - Returns: A darkened color.
	func darken(by percentage: CGFloat = 0.2) -> UIColor {
		var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
		self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return UIColor(
			red: max(red - percentage, 0),
			green: max(green - percentage, 0),
			blue: max(blue - percentage, 0),
			alpha: alpha
		)
	}
}
