//
//  PhoneWidgetLocating.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import UIKit
import WidgetKit

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
