//
//  CustomLabel.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 06/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

public class CustomLabel: UILabel {
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        super.drawText(in: rect.inset(by: insets))
    }
}
