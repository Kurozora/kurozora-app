//
//  View+KurozoraWidget.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 29/07/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import SwiftUI
import UIKit
import WidgetKit

// MARK: - View
extension View {
	func widgetBackground(_ backgroundView: some View) -> some View {
		if #available(iOS 17.0, *) {
			return self.containerBackground(for: .widget) {
				backgroundView
			}
		} else {
			return self.background(backgroundView)
		}
	}
}

// MARK: - EnvironmentValues
private struct _WidgetContentMargins: EnvironmentKey {
	static let defaultValue: EdgeInsets = EdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0)
}

extension EnvironmentValues {
	var widgetContentMarginsWithFallback: EdgeInsets {
		if #available(iOSApplicationExtension 17.0, macOSApplicationExtension 14.0, *) {
			self.widgetContentMargins
		} else {
			self[_WidgetContentMargins.self]
		}
	}
}

// MARK: - FontTraitsModifier
/// Applies font weight and width as View modifiers rather than on the `Font` value.
/// Setting weight/width directly on `Font` is unreliable — traits can be silently
/// dropped when combined with design or text style parameters.
struct FontTraitsModifier: ViewModifier {
	let fontStyle: IntentFont
	let fontWeight: IntentFontWeight
	let fontWidth: IntentFontWidth

	func body(content: Content) -> some View {
		if #available(iOS 16.0, *) {
			content
				.fontWeight(self.fontWeight.toFontWeight)
				.fontWidth(self.fontStyle.effectiveWidth(for: self.fontWidth))
		} else {
			content
				.font(nil)
		}
	}
}

// MARK: - Adaptive Capsule Background
/// Swaps `.ultraThinMaterial` for a semi-transparent fill in accented
/// rendering mode so the pill text stays legible.
struct AdaptiveCapsuleBackground: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 16.0, *) {
			content.modifier(AccentAwareCapsule())
		} else {
			content.background(.ultraThinMaterial, in: Capsule())
		}
	}
}

@available(iOS 16.0, *)
struct AccentAwareCapsule: ViewModifier {
	@Environment(\.widgetRenderingMode) var widgetRenderingMode

	func body(content: Content) -> some View {
		content.background {
			if self.widgetRenderingMode == .accented {
				Capsule().fill(Color.white.opacity(0.2))
			} else {
				Capsule().fill(.ultraThinMaterial)
			}
		}
	}
}

// MARK: - LocationAwareWidget
protocol LocationAwareWidget {
	/// The widget family.
	var widgetFamily: WidgetFamily { get }

	/// Whether or not the background of the widget appears.
	var showsWidgetContainerBackground: Bool { get }

	/// The widget's rendering mode, based on where the system is displaying it.
	@available(iOS 16.0, watchOS 9.0, macOS 13.0, *)
	var widgetRenderingMode: WidgetRenderingMode { get }
}

extension LocationAwareWidget {
	/// Whether or not the widget is located on iPhone StandBy mode.
	var isPhoneStandByWidget: Bool {
		return UIDevice.current.userInterfaceIdiom == .phone && self.widgetFamily == .systemSmall && !self.showsWidgetContainerBackground
	}

	/// Whether or not the widget is located on iPhone StandBy mode and is rendered in full color.
	@available(iOS 16.0, watchOS 9.0, macOS 13.0, *)
	var isPhoneStandByFullColorWidget: Bool {
		return self.isPhoneStandByWidget && widgetRenderingMode == .fullColor
	}
}
