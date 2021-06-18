//
//  Tabman+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import Tabman

extension TMBar {
	/**
		Kurozora style bar, very reminiscent of the Photos app bottom tab bar. It consistsof a horizontal layout containing label bar buttons, and a pill shaped tint as the indicator.

		- Tag: KBar
	*/
	typealias KBar = TMBarView<TMHorizontalBarLayout, TMLabelBarButton, KFillBarIndicator>
}
