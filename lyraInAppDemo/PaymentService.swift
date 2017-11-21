//
//  PaymentService.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 05/09/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import Foundation
import WebKit

/// Service responsible to call merchant server
class PaymentService {
    var email: String;
    var amount: String;
    var mode: String;
    var lang: LANG;
    var type_card: String;
    static let SERVER_URL = "YOUR_SERVER_ENDPOINT"
    
    init(email:String, amount:String, mode:String, lang: LANG, type_card:String){
        // Warning, here we force EUR currency
        let tmp = amount.doubleValue*100
        self.amount = String(format: "%.0f",tmp)
        self.email = email
        self.mode = mode
        self.lang = lang
        self.type_card = type_card
    }
    
    /// Build an URLRequest accordind : server url, email passed, amount passed, mode passed, lang passed
    ///
    /// - Returns: URLRequest
    func buildRequest() -> URLRequest {
        let myUrl: NSURL = NSURL(string: "\(PaymentService.SERVER_URL)/performInit/\(email)/\(amount)/\(mode)/\(lang)/\(type_card)")!
        var request = URLRequest(url:myUrl as URL)
        request.httpMethod = "GET"
        return request
    }
    
    /// Call server to get payment url, supply a block completion (callback)
    ///
    /// - Returns: status boolean, payment url
    func getPaymentContext(completion: @escaping (Bool, String) -> ()){
        // Used to store service result and return to completion
        var urlPayment: String = ""

        // Build request
        let request = buildRequest()
        
        // Call server to obtain a payment Url
        // Completion is a callback, giving call status, and Payment url if success
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                completion(false, "")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){
                    // Everythings works
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        if let parseJSON = json {
                            urlPayment = (parseJSON["redirect_url"] as? String)!
                            completion(true, urlPayment)
                        }
                    } catch {
                        completion(false, "")
                    }
                    
                }else{
                    completion(false,"")
                }
            }
        }
        task.resume()
    }
    
    static func buildWebviewUrlUtil(navigationAction: WKNavigationAction) -> WebviewUrlUtil{
        let arrayHost = navigationAction.request.url?.host?.components(separatedBy: ".")
        let paymentStatus = arrayHost?[(arrayHost?.count)!-1]
        
        let paramsQueryArray = navigationAction.request.url?.query?.components(separatedBy:"&")
        var dataQueryArray = [String:Any]()
        for row in paramsQueryArray! {
            let pairs = row.components(separatedBy:"=")
            dataQueryArray[pairs[0]] = pairs[1]
        }
        
        let webviewUrlUtil = WebviewUrlUtil(paymentStatus: paymentStatus!, dataQueryArray: dataQueryArray)
        return webviewUrlUtil
    }
}
