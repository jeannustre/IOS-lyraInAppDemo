//
//  WebviewUrlUtil.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 06/09/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import Foundation


/// Helper to store url called in Webview
class WebviewUrlUtil {
    var paymentStatus:String;
    var dataQueryArray = [String:Any]()
    
    init(paymentStatus:String, dataQueryArray:[String:Any]){
        self.paymentStatus = paymentStatus
        self.dataQueryArray = dataQueryArray
    }
    
    
    /// Return parameter include in Url
    ///
    /// - Parameter name: <#name description#>
    /// - Returns: <#return value description#>
    func getParameter(name: String) -> String {
        guard let param = dataQueryArray[name] else {
            return ""
        }
        return param as! String
    }
    
    
    /// Return true if url contains "success" or "return"
    ///
    /// - Returns: <#return value description#>
    func isSuccess() -> Bool {
        return paymentStatus == "success" || paymentStatus == "return"
        // or check vads_trans_status => getParameter("vads_trans_status") == "AUTHORIZED"
    }
}


