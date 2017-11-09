//
//  Utils.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 06/09/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import WebKit
import UIKit

class CustomUITextField: UITextField {
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

class Utils {
    static func addRedBorder(field: UITextField){
        field.layer.borderColor = UIColor.red.cgColor
        field.layer.borderWidth = 3.0
    }
    
    static func removeRedBorder(field: UITextField){
        field.layer.borderWidth = 0.0
    }
    
    static func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
}
