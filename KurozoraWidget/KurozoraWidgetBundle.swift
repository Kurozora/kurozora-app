//
//  KurozoraWidgetBundle.swift
//  KurozoraWidget
//
//  Created by Khoren Katklian on 05/04/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import SwiftUI
import WidgetKit

@main
struct KurozoraWidgetBundle: WidgetBundle {
	var body: some Widget {
		if #available(iOS 18.0, *) {
			return iOS18WidgetBundle().body
		} else {
			return iOS16WidgetBundle().body
		}
	}
}

struct iOS16WidgetBundle: WidgetBundle {
	@WidgetBundleBuilder
	var body: some Widget {
		DateWidget()

		if #available(iOS 17.0, *) {
			LaunchAppAccessory()
		}
	}
}

struct iOS18WidgetBundle: WidgetBundle {
	@WidgetBundleBuilder
	var body: some Widget {
		DateWidget()

		if #available(iOS 17.0, *) {
			LaunchAppAccessory()
		}

		if #available(iOS 18.0, *) {
			LaunchAppControl()
		}
	}
}
