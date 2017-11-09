This repository is intended to demonstrate how mobile payment is working; based on following components :

* View to collect payment information (email, amount) and submit payment (Casual payment & Apple Pay if enabled)
* View to indicate payment result
* Few class utils to perform payment workflow (communication with your backend, detect end of payment, detect expiration)

## Table of contents

* [Quick start](#quick-start)
* [Status](#status)
* [What's included](#whats-included)
* [Bugs and feature requests](#bugs-and-feature-requests)
* [Payment throught webviews](#payment-throught-webviews)

## Quick start 

Several quick start options are available:

* Download [WebviewServices] & [WebviewViewController], and import it your xcode project.
* Clone the repo: `git clone https://github.com/payzen/IOS-lyraInAppDemo.git`, and start hacking.

## Status

Tested in Xcode 8.3.1, written in Swift 3, Demo app require Ios 9.3, or more.

## What's included
```swift
LyraInAppDemo
|---Utils
|   |-- Utils.swift 
|   |-- Translator.swift
|   |-- progressHUD.swift
|---WebviewServices   
|   |-- WebviewUrlUtil.swift
|   |-- PaymentService.swift
|---ViewController.swift
|---SuccessViewController.swift
|---ErrorViewController.swift
|---WebviewViewController.swift
```

We used this app as a demo for our sales; Payment integration is separated from rest of the app.

## Bugs and feature requests

Have a bug or a feature request? [please open a new issue](https://github.com/payzen/IOS-lyraInAppDemo/issues).

## General information

You will find whole documentation in official website : 

## Payment throught webviews
Payment throught webview is realized by the WebviewViewController, and utils classes include in WebviewServices.

**WebviewServices**

*WebviewServices* is a directory containing two helpers classes.

*PaymentService* is responsible to communicate with your backend to get redirected payment url. 
It offer a completion handler, to use in **WebviewViewController**, returning two values :
* Status of the request (Boolean)
* Payment url (nil if status is false)

```swift
/// Build an URLRequest accordind : server url, email passed, amount passed, mode passed, lang passed
///
/// - Returns: URLRequest
func buildRequest() -> URLRequest {
    let myUrl: NSURL = NSURL(string: "\(PaymentService.SERVER_URL)/\(email)/\(amount)/\(mode)/\(lang)/\(type_card)")!
    var request = URLRequest(url:myUrl as URL)
    request.httpMethod = "GET"
    return request
}

/// Call server to get payment url, supply a block completion (callback)
///
/// - Returns: status boolean, payment url
func getPaymentContext(completion: @escaping (Bool, String, [[String : AnyObject]]?) -> ()){
    // Used to store service result and return to completion
    var urlPayment: String = ""

    // Build request
    let request = buildRequest()

    // Call server to obtain a payment Url
    // Completion is a callback, giving call status, and Payment url if success
    let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
        if error != nil{
            completion(false, "", nil )
        }

        if let httpResponse = response as? HTTPURLResponse {
            if(httpResponse.statusCode == 200){
                // Everythings works
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                    if let parseJSON = json {
                        urlPayment = (parseJSON["redirect_url"] as? String)!
                        let cookieData = parseJSON["cookies"] as? [[String : AnyObject]]
                        completion(true, urlPayment, cookieData)
                    }
                } catch {
                    completion(false, "", nil)
                }
            }else{
                completion(false,"", nil)
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
```

> Dont forget to modify SERVER_URL according your backend


*WebviewUrlUtil* is small helper class which stored get params returned by the *payment platform* (payment status, transaction number, authorization status etc.) 

```swift
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
```

**WebviewViewController**

WebviewViewController is a view controller dealing with payment workflow :
* Run a PaymentService, waiting for payment Url

```swift
let paymentService = PaymentService(email: email, amount: amount, mode: mode, lang: lang, type_card: type_card)

// Call server, and receive call status, and url payment
// When you get response for your server
paymentService.getPaymentContext { status, urlPayment, cookies in
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

            // init webview

        }
    }
}
```

*Open up a WKWebview*

```swift
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
self.webView.allowsBackForwardNavigationGestures = true   // Disable swiping to navigate


self.view = self.webView

self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.loading), options: .new, context: nil)
self.view.addSubview(self.progressHUD)

```

*Analyse every Url's running inside the webview to detect payment status*

```swift
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
    }else if isExperationUrl(url: (navigationAction.request.url?.absoluteString)!) {
        decisionHandler(.cancel)
        goToView(reason: "EXPIRATION", increaseSize: false)
    }else{
        decisionHandler(.allow)
    }
}
```

