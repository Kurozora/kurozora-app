//
//  OnboardingSwiftUIView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//
//
// import SwiftUI
//
// enum SwiftUITheme: String, CaseIterable {
//	case day = "Day"
//	case night = "Night"
//
//	var next: SwiftUITheme {
//		switch self {
//		case .day:
//			return .night
//		case .night:
//			return .day
//		}
//	}
// }
//
// struct Colors: Codable {
//	var global: Global
//
//	struct Global: Codable {
//		var backgroundColor: String = "#FFFFFF"
//		var textColor: String = "#000000"
//		var tintColor: String = "#FF9300"
//	}
// }
//
// func loadColors(for theme: SwiftUITheme) -> Colors {
//	// Load the plist file for the specified theme and decode its contents into an instance of the Colors struct
//	let decoder = PropertyListDecoder()
//
//	do {
//		guard let path = Bundle.main.url(forResource: theme.rawValue, withExtension: "plist") else { return Colors(global: .init(backgroundColor: "#FF0000")) }
//		let data = try Data(contentsOf: path)
//		return try decoder.decode(Colors.self, from: data)
//	} catch {
//		print(error.localizedDescription)
//	}
//
//	return Colors(global: .init())
// }
//
// struct OnboardingView: View {
//	@State private var colors: Colors = Colors(global: .init())
//	@State private var theme: SwiftUITheme = .day
//
//	var body: some View {
//		VStack {
//			Text("Hello, world!")
//				.foregroundColor(Color(hex: colors.global.textColor))
//			Button(action: {
//				self.theme = self.theme.next
//				self.colors = loadColors(for: self.theme)
//			}) {
//				Text("Dark Theme")
//			}
//			.background(Color(hex: colors.global.tintColor))
//			.foregroundColor(Color(hex: colors.global.textColor))
//		}
//		.background(Color(hex: colors.global.backgroundColor))
//	}
// }
//
// struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView()
//    }
// }
//
// extension Color {
//	init(hex: String) {
//		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//		var int: UInt64 = 0
//		Scanner(string: hex).scanHexInt64(&int)
//		let a, r, g, b: UInt64
//		switch hex.count {
//		case 3: // RGB (12-bit)
//			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//		case 6: // RGB (24-bit)
//			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//		case 8: // ARGB (32-bit)
//			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//		default:
//			(a, r, g, b) = (1, 1, 1, 0)
//		}
//
//		self.init(
//			.sRGB,
//			red: Double(r) / 255,
//			green: Double(g) / 255,
//			blue: Double(b) / 255,
//			opacity: Double(a) / 255
//		)
//	}
// }
