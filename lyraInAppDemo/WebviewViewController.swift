//
//  WebviewViewController.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 09/10/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import UIKit
import WebKit

/// Handle payment process inside webview
class WebviewViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    
    var email: String = ""
    var amount: String = ""
    var mode: String = ""
    var lang: LANG = .ENGLISH
    var type_card: String  = ""
    let progressHUD = ProgressHUD(text: "Loading")
    var webView: WKWebView!
    
    // Constants
    let CALLBACK_URL_PREFIX: String = "webview"
    let EXPIRATION_URL = "http://www.demo.lyra.mobile/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add running spinner
        self.progressHUD.setText(string: Translator.translateLoader(lang: lang))
        self.view.addSubview(self.progressHUD)
        
        let paymentService = PaymentService(email: email, amount: amount, mode: mode, lang: lang, type_card: type_card)
        
        // Call server, and receive call status, and url payment
        // When you get response for your server
        paymentService.getPaymentContext { status, urlPayment in
            
            // If we get an error
            if(!status){
                DispatchQueue.main.async(){
                    // present error screen
                    self.progressHUD.hide()
                    
                    self.goToView(reason: "NETWORK", increaseSize: true)
                }
                // If we get a payment Url
            }else{
                DispatchQueue.main.async(){
                    // urlPayment is the Url given by your payment platform
                    let url = NSURL(string:urlPayment)
                    let req = NSURLRequest(url:url! as URL)
                    
                    // We create and load a webview pointing to this Url
                    self.automaticallyAdjustsScrollViewInsets = false
                    self.navigationController?.isNavigationBarHidden = true;
                    self.webView = WKWebView()
                    
                    // mandatory to detect end of payment
                    self.webView.navigationDelegate = self
                    self.webView!.load(req as URLRequest)
                    self.webView.scrollView.frame = self.webView.frame
                    self.webView.scrollView.contentInset = UIEdgeInsetsMake(20,0,0,0)
                    self.webView.scrollView.delegate = self
                    self.webView.layer.zPosition = 999
                    
                    self.webView.scrollView.bounces = false                    // Things like this should be handled in web code
                    self.webView.allowsBackForwardNavigationGestures = true   // Enable/Disable swiping to navigate
                    
                    
                    self.view = self.webView
                    
                    self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.loading), options: .new, context: nil)
                    self.view.addSubview(self.progressHUD)
                    
                    UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
                }
                
            }
        }
    }
    
    /// Handle spinner stop when page has finished to load
    ///
    /// - Parameters:
    ///   - keyPath: <#keyPath description#>
    ///   - object: <#object description#>
    ///   - change: <#change description#>
    ///   - context: <#context description#>
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard (object as? WKWebView) != nil else {
            return
        }
        guard let keyPath = keyPath else {
            return
        }
        guard let change = change else {
            return
        }
        
        switch keyPath {
        case "loading":
            if let val = change[.newKey] as? Bool {
                if !val {
                    self.progressHUD.hide()
                }
            }
        default:
            break
        }
    }
    
    // Disable zoom in webviews
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Callback when an Url change inside webview
    ///
    /// - Parameters:
    ///   - webView: <#webView description#>
    ///   - navigationAction: <#navigationAction description#>
    ///   - decisionHandler: <#decisionHandler description#>
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        // Cause html link with "target = _blank"
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        // We detect end of payment
        if isCallBackUrl(url: (navigationAction.request.url?.absoluteString)!) {
            decisionHandler(.cancel)
            goToFinalController(navigationAction: navigationAction)
        // We detect a page that should be open in a separate browser
        }else if isUrlToOpenedSeparately(url: (navigationAction.request.url?.absoluteString)!) {
            decisionHandler(.cancel)
            UIApplication.shared.openURL(navigationAction.request.url!)
        // We detect that a link in expiration page have been cliked
        }else if isExpirationUrl(url: (navigationAction.request.url?.absoluteString)!) {
            decisionHandler(.cancel)
            goToView(reason: "EXPIRATION", increaseSize: false)
        }else{
            decisionHandler(.allow)
        }
    }
    
    func isExpirationUrl(url: String) -> Bool {
        return url.contains(EXPIRATION_URL)
    }
    
    func isUrlToOpenedSeparately(url: String) -> Bool {
        return url.contains("payzen.eu/mentions-paiement") || url.contains("%2Fpdf") || url.contains("payzen.eu/paiement-securise") || url.contains("https://www.payzen.eu/")
    }
    
    func goToView(reason: String, increaseSize: Bool){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as! ErrorViewController
        controller.reason = reason
        controller.lang = self.lang
        
        if increaseSize {
            controller.increaseSize = true
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    /// End of payment, find payment status and display right controller
    ///
    /// - Parameter navigationAction: <#navigationAction description#>
    func goToFinalController(navigationAction: WKNavigationAction){
        let WebviewUrlUtil = PaymentService.buildWebviewUrlUtil(navigationAction: navigationAction)
        
        if WebviewUrlUtil.isSuccess() {
            // Great, payment is successul
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
            controller.email = (WebviewUrlUtil.getParameter(name: "vads_cust_email")).replacingOccurrences(of: "%40", with: "@")
            controller.lang = Translator.translateLangFronPayzen(lang: WebviewUrlUtil.getParameter(name: "vads_language"))
            self.present(controller, animated: true, completion: nil)
            
        }else{
            // You will find in the URL what happens
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ErrorViewController") as! ErrorViewController
            
            controller.reason = WebviewUrlUtil.getParameter(name: "vads_trans_status")
            controller.lang = Translator.translateLangFronPayzen(lang: WebviewUrlUtil.getParameter(name: "vads_language"))
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    /// indicate if current url contains CALLBACK_URL_PREFIX
    ///
    /// - Parameter url: <#url description#>
    /// - Returns: <#return value description#>
    func isCallBackUrl(url: String) -> Bool {
        return url.contains(CALLBACK_URL_PREFIX)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    let ExpTime = TimeInterval(60 * 60 * 24 * 365)
    func setCookie(key: String, value: AnyObject) {
        let cookieProps: [HTTPCookiePropertyKey : Any] = [
            HTTPCookiePropertyKey.domain: "demo.payzen.eu",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: key,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: "TRUE",
            HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow: ExpTime)
        ]
        
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        if let cookie = HTTPCookie(properties: cookieProps) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
    }

}
