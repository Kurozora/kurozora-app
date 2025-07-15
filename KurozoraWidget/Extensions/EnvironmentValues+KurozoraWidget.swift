//
//  EnvironmentValues+KurozoraWidget.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import SwiftUI

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
