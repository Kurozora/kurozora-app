//
//  CustomTextField.swift
//  Seedonk
//
//  Created by Paul Chavarria Podoliako on 2/20/15.
//  Copyright (c) 2015 Seedonk. All rights reserved.
//

import UIKit

public class CustomTextField: UITextField {
    
    @IBOutlet var nextField : UITextField?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        let paddingView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: bounds.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
    
}

public extension CustomTextField {
    
    func isEmpty() -> Bool {
        return text!.count == 0
    }
    
    func validEmail() -> Bool {
        let emailRegex = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        let regularExpression = try? NSRegularExpression(pattern: emailRegex, options: NSRegularExpression.Options.caseInsensitive)
        let matches = regularExpression?.numberOfMatches(in: text!, options: [], range: NSMakeRange(0, (text! as NSString).length))
        return (matches == 1)
    }
    
    func hasEqualTextAs(otherTextField:UITextField) -> Bool {
        return (text == otherTextField.text)
    }
    
    func validPassword() -> Bool {
        return text!.count >= 6
    }
    
    func trimSpaces() {
        text = text!.replacingOccurrences(of: " ", with: "")
    }
    
}
