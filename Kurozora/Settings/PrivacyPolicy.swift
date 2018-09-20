//
//  PrivacyPolicy.swift
//  Kurozora
//
//  Created by Khoren Katklian on 09/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView

class LegalViewController : UIViewController {
    @IBOutlet weak var privacyPolicyTextView: UITextView!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Service.shared.getPrivacyPolicy(withSuccess: { (privacyPolicy) in
            if let privacyPolicyText = privacyPolicy.text {
                self.privacyPolicyTextView.textColor = .white
                self.privacyPolicyTextView.text = privacyPolicyText
            }
            
            if let lastUpdatedAt = privacyPolicy.lastUpdate {
                self.lastUpdatedLabel.text = "Last updated at: \(lastUpdatedAt)"
            } else {
                self.lastUpdatedLabel.text = ""
            }
        }) { (errorMsg) in
            SCLAlertView().showError("Error retrieving page", subTitle: errorMsg)
        }
    }
}
