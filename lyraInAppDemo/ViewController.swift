//
//  ViewController.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 04/09/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import UIKit
import WebKit
import PassKit

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

enum ApplePaySupport {
    case DoNotSupportApplePay
    case SupportApplePayNoCartUsingNetworks
    case SupportApplePayCardOk
}

extension String{
    
    var doubleValue: Double {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: self) {
            return result.doubleValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
    
    private static let decimalFormatter:NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        return formatter
    }()
    
    private var decimalSeparator:String{
        return String.decimalFormatter.decimalSeparator ?? "."
    }
    
    func isValidDecimal(maximumFractionDigits:Int)->Bool{
        
        // Depends on you if you consider empty string as valid number
        guard self.isEmpty == false else {
            return true
        }
        
        // Check if valid decimal
        if let _ = String.decimalFormatter.number(from: self){
            
            // Get fraction digits part using separator
            let numberComponents = self.components(separatedBy: decimalSeparator)
            let fractionDigits = numberComponents.count == 2 ? numberComponents.last ?? "" : ""
            return fractionDigits.characters.count <= maximumFractionDigits
        }
        
        return false
    }
    
}

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var applePayButtonArea: UIView!
    @IBOutlet weak var radioButtonTest: UIImageView!
    @IBOutlet weak var radioButtonTestLabel: UITextField!
    @IBOutlet weak var radioButtonProd: UIImageView!
    @IBOutlet weak var radioButtonProdLabel: UITextField!
    @IBOutlet weak var poweredMessage: UITextView!
    @IBOutlet weak var TransparentButonTest: UIButton!
    @IBOutlet weak var transparentButonProd: UIButton!
    @IBOutlet weak var dropDownField: UITextField!
    @IBOutlet weak var cardIcon: UIImageView!
    @IBOutlet weak var flagButton: UIButton!
    
    let yourPicker = UIPickerView()
    var currentLang: LANG = .ENGLISH
    var isTappedRadioButtonTest = true
    var isTappedRadioButtonProd = false
    var applePayButton: UIButton!
    let paymentNetworks = [PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
    var applePaymentDidSucceed: Bool = false
    let dropDownValuesImages = ["card", "cb", "visa", "mastercard"]
    let APPLE_PAY_MERCHANT_IDENTIFIER = "YOUR_APPLE_PAY_ID"
    let APPLE_PAY_URL = "YOUR_SERVER_ENDPOINT"
    
    @IBAction func showActionSheet(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: Translator.translateChooseLang(lang: self.currentLang), preferredStyle: .actionSheet)
        let francaisAction = UIAlertAction(title: "Francais", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.currentLang = .FRENCH
            sender.setImage( UIImage.init(named: "france"), for: .normal)
            Translator.translate(lang: self.currentLang, payButton: self.payButton, amountField:self.amountField, emailField: self.emailField, poweredMessage: self.poweredMessage)
            self.dropDownField.text = Translator.translateDropDownValue(lang: self.currentLang)[self.yourPicker.selectedRow(inComponent: 0)]

        })
        let anglaisAction = UIAlertAction(title: "English", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.currentLang = .ENGLISH
            sender.setImage( UIImage.init(named: "unitedkingdom"), for: .normal)
            Translator.translate(lang: self.currentLang, payButton: self.payButton, amountField:self.amountField, emailField: self.emailField, poweredMessage: self.poweredMessage)
            self.dropDownField.text = Translator.translateDropDownValue(lang: self.currentLang)[self.yourPicker.selectedRow(inComponent: 0)]

        })
        let spanishAction = UIAlertAction(title: "Spanish", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.currentLang = .SPANISH
            sender.setImage( UIImage.init(named: "spain"), for: .normal)
            Translator.translate(lang: self.currentLang, payButton: self.payButton, amountField:self.amountField, emailField: self.emailField, poweredMessage: self.poweredMessage)
            self.dropDownField.text = Translator.translateDropDownValue(lang: self.currentLang)[self.yourPicker.selectedRow(inComponent: 0)]

        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        
        optionMenu.addAction(francaisAction)
        optionMenu.addAction(anglaisAction)
        optionMenu.addAction(spanishAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    @IBAction func payAction(_ sender: Any) {
        var anyError = false
        var stringError = ""
        
        Utils.removeRedBorder(field: self.amountField)
        Utils.removeRedBorder(field: self.emailField)
        
        if amountField.text == "" {
            anyError = true
            stringError = Translator.translateEmptyFields(lang: self.currentLang)
            Utils.addRedBorder(field: self.amountField)
        }
        
        if (!anyError){
            if amountField.text!.doubleValue > Double(50.0) || amountField.text?.doubleValue == Double(0.0)  {
                anyError = true
                stringError = Translator.translateSuperiorFields(lang: self.currentLang)
                Utils.addRedBorder(field: self.amountField)
            }
        }
        
        // Check email
        if emailField.text != "" {
            if !Utils.isValidEmailAddress(emailAddressString: emailField.text!){
                anyError = true
                stringError = Translator.translateEmptyFields(lang: self.currentLang)
                Utils.addRedBorder(field: self.emailField)
            }
        }
        
        if (anyError){
            let alert = UIAlertController(title: "", message: stringError, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
        }else{
            Utils.removeRedBorder(field: self.amountField)
            Utils.removeRedBorder(field: self.emailField)
            
            var email: String = "noemail"
            if emailField.text != "" {
                email = emailField.text!
            }
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "WebviewViewController") as! WebviewViewController
            controller.email = email
            controller.lang = self.currentLang
            controller.amount = amountField.text!
            controller.mode = (isTappedRadioButtonProd ? "PRODUCTION" : "TEST")
            controller.type_card = Translator.translateDropDownValue(lang: LANG.ENGLISH)[yourPicker.selectedRow(inComponent: 0)]
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField == self.amountField){
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            if newText == "" {
                return true
            }
            
            // Add red border when value is invalid
            if newText.doubleValue == Double(0) || newText.doubleValue > Double(50.0) {
                Utils.addRedBorder(field: textField)
            }else{
                Utils.removeRedBorder(field: textField)
            }
            
            if !newText.isValidDecimal(maximumFractionDigits: 2){
                return false
            }
        }
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let locale = NSLocale.autoupdatingCurrent
        let code = locale.languageCode!
        let language = locale.localizedString(forLanguageCode: code)!
        
        if language == "français" {
            self.currentLang = .FRENCH
            self.flagButton.setImage( UIImage.init(named: "france"), for: .normal)
            Translator.translate(lang: self.currentLang, payButton: self.payButton, amountField:self.amountField, emailField: self.emailField, poweredMessage: self.poweredMessage)
            self.dropDownField.text = Translator.translateDropDownValue(lang: self.currentLang)[self.yourPicker.selectedRow(inComponent: 0)]
        } else if language == "English" {
            self.currentLang = .ENGLISH
            self.flagButton.setImage( UIImage.init(named: "unitedkingdom"), for: .normal)
            Translator.translate(lang: self.currentLang, payButton: self.payButton, amountField:self.amountField, emailField: self.emailField, poweredMessage: self.poweredMessage)
            self.dropDownField.text = Translator.translateDropDownValue(lang: self.currentLang)[self.yourPicker.selectedRow(inComponent: 0)]
        } else if language == "español" {
            self.currentLang = .SPANISH
            self.flagButton.setImage( UIImage.init(named: "spain"), for: .normal)
            Translator.translate(lang: self.currentLang, payButton: self.payButton, amountField:self.amountField, emailField: self.emailField, poweredMessage: self.poweredMessage)
            self.dropDownField.text = Translator.translateDropDownValue(lang: self.currentLang)[self.yourPicker.selectedRow(inComponent: 0)]
        }
        
        let backgroundImage = UIImage(named: "Default.jpg")
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = backgroundImage
        view.insertSubview(backgroundImageView, at: 0)
        
        emailField.setLeftPaddingPoints(50)
        amountField.setLeftPaddingPoints(50)
                
        // ApplePay button init
        if canMakePaymentsUsingNetworks() == ApplePaySupport.SupportApplePayCardOk {
            self.createApplePayPaymentButton(isHidden: true)
        }
        if canMakePaymentsUsingNetworks() == ApplePaySupport.SupportApplePayNoCartUsingNetworks {
            self.createApplePaySetUpButton(isHidden: true)
        }
        
        // RadioButton
        let tapTest = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapRadioButtonTest))
        radioButtonTest.addGestureRecognizer(tapTest)
        radioButtonTest.isUserInteractionEnabled = true
        
        let tapProd = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapRadioButtonProd))
        radioButtonProd.addGestureRecognizer(tapProd)
        radioButtonProd.isUserInteractionEnabled = true

        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(ViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.TransparentButonTest.addTarget(self, action: #selector(tapRadioButtonLabelTest), for: UIControlEvents.touchUpInside)
        self.transparentButonProd.addTarget(self, action: #selector(tapRadioButtonLabelProd), for: UIControlEvents.touchUpInside)
        
        //textFields
        self.emailField.delegate = self
        self.amountField.delegate = self
        self.emailField.tag = 2
        self.amountField.tag = 1
        
        self.dropDownField.setLeftPaddingPoints(50)
        self.yourPicker.delegate = self
        self.yourPicker.dataSource = self
        self.dropDownField.inputView = self.yourPicker
        self.dropDownField.inputAccessoryView = self.inputThirdToolbar
        
        self.dropDownField.text = (Translator.translateDropDownValue(lang: self.currentLang))[0]
        self.cardIcon.image = UIImage(named: dropDownValuesImages[0])
    }
    
    
    // Dropdown
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (Translator.translateDropDownValue(lang: self.currentLang)).count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return (Translator.translateDropDownValue(lang: self.currentLang))[row]
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.dropDownField.text = Translator.translateDropDownValue(lang: self.currentLang)[row]
        self.cardIcon.image = UIImage(named: dropDownValuesImages[row])
    }
    //////////////////////
    
    lazy var inputFirstToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        var icon = UIImage(named: "chevron-right")
        var iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15))
        let iconNextButton = UIButton(frame: iconSize)
        iconNextButton.setBackgroundImage(icon, for: .normal)
        let nextButton = UIBarButtonItem(customView: iconNextButton)
        iconNextButton.addTarget(self, action: #selector(inputFirstToolbarNextButton), for: .touchUpInside)
        
        icon = UIImage(named: "chevron-left-light")
        iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15))
        let iconPrevButton = UIButton(frame: iconSize)
        iconPrevButton.setBackgroundImage(icon, for: .normal)
        let prevButton = UIBarButtonItem(customView: iconPrevButton)
        
        var doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapView))

        toolbar.setItems([fixedSpaceButton, prevButton, fixedSpaceButton, nextButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var inputSecondToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        var icon = UIImage(named: "chevron-left")
        var iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15))
        let iconPrevButton = UIButton(frame: iconSize)
        iconPrevButton.setBackgroundImage(icon, for: .normal)
        let prevButton = UIBarButtonItem(customView: iconPrevButton)
        iconPrevButton.addTarget(self, action: #selector(inputSecondToolbarPrevButton), for: .touchUpInside)
        
        icon = UIImage(named: "chevron-right")
        iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15))
        let iconNextButton = UIButton(frame: iconSize)
        iconNextButton.setBackgroundImage(icon, for: .normal)
        let nextButton = UIBarButtonItem(customView: iconNextButton)
        iconNextButton.addTarget(self, action: #selector(inputSecondToolbarNextButton), for: .touchUpInside)
        
        var doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapView))
        
        toolbar.setItems([fixedSpaceButton, prevButton, fixedSpaceButton, nextButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    lazy var inputThirdToolbar: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        
        var flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        
        var icon = UIImage(named: "chevron-left")
        var iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15))
        let iconPrevButton = UIButton(frame: iconSize)
        iconPrevButton.setBackgroundImage(icon, for: .normal)
        let prevButton = UIBarButtonItem(customView: iconPrevButton)
        iconPrevButton.addTarget(self, action: #selector(inputThirdToolbarPrevButton), for: .touchUpInside)
        
        icon = UIImage(named: "chevron-right-light")
        iconSize = CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15))
        let iconNextButton = UIButton(frame: iconSize)
        iconNextButton.setBackgroundImage(icon, for: .normal)
        let nextButton = UIBarButtonItem(customView: iconNextButton)
        
        var doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(didTapView))
        
        toolbar.setItems([fixedSpaceButton, prevButton, fixedSpaceButton, nextButton, flexibleSpaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        return toolbar
    }()
    
    func inputFirstToolbarNextButton(){
        self.emailField.becomeFirstResponder()
    }
    
    func inputSecondToolbarPrevButton(){
        self.amountField.becomeFirstResponder()
    }
    
    func inputThirdToolbarPrevButton(){
        self.emailField.becomeFirstResponder()
    }
    
    func inputSecondToolbarNextButton(){
        self.dropDownField.becomeFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            textField.inputAccessoryView = inputFirstToolbar
        }else if textField.tag == 2 {
            textField.inputAccessoryView = inputSecondToolbar
        }
        return true
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }

    //================================================================================
    // Handle return for text fields
    //================================================================================
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //================================================================================
    // Handle radio buttons, to choose between TEST and PRODUCTION
    //================================================================================
    func tapRadioButtonLabelTest(){
        tapRadioButtonTest()
    }
    
    func tapRadioButtonLabelProd(){
        tapRadioButtonProd()
    }
    
    func tapRadioButtonTest(){
        var applePayButtonStatus: Bool = true
        if isTappedRadioButtonTest {
            radioButtonTest.image = UIImage(named: "icons8-Enregistrer-50")
            radioButtonProd.image = UIImage(named: "icons8-Enregistrer Filled-50")
            isTappedRadioButtonTest = false
            isTappedRadioButtonProd = true
            applePayButtonStatus = false
        }else{
            radioButtonTest.image = UIImage(named: "icons8-Enregistrer Filled-50")
            radioButtonProd.image = UIImage(named: "icons8-Enregistrer-50")
            isTappedRadioButtonTest = true
            isTappedRadioButtonProd = false
            applePayButtonStatus = true
        }
        
        if canMakePaymentsUsingNetworks() == ApplePaySupport.SupportApplePayCardOk || canMakePaymentsUsingNetworks() == ApplePaySupport.SupportApplePayNoCartUsingNetworks {
            applePayButton.isHidden = applePayButtonStatus
        }
    }
    
    func tapRadioButtonProd(){
        var applePayButtonStatus: Bool = true

        if isTappedRadioButtonProd {
            radioButtonProd.image = UIImage(named: "icons8-Enregistrer-50")
            radioButtonTest.image = UIImage(named: "icons8-Enregistrer Filled-50")
            isTappedRadioButtonProd = false
            isTappedRadioButtonTest = true
            applePayButtonStatus = true
        }else{
            radioButtonProd.image = UIImage(named: "icons8-Enregistrer Filled-50")
            radioButtonTest.image = UIImage(named: "icons8-Enregistrer-50")
            isTappedRadioButtonProd = true
            isTappedRadioButtonTest = false
            applePayButtonStatus = false
        }
        
       if canMakePaymentsUsingNetworks() == ApplePaySupport.SupportApplePayCardOk || canMakePaymentsUsingNetworks() == ApplePaySupport.SupportApplePayNoCartUsingNetworks {
            applePayButton.isHidden = applePayButtonStatus
        }
    }
    //================================================================================
    
    //================================================================================
    // Handle apple pay stuffs
    //================================================================================
    func canMakePaymentsUsingNetworks() -> ApplePaySupport {
        if !PKPaymentAuthorizationViewController.canMakePayments(){
            return ApplePaySupport.DoNotSupportApplePay
        }
        
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: self.paymentNetworks) {
            return ApplePaySupport.SupportApplePayNoCartUsingNetworks
        }
        return ApplePaySupport.SupportApplePayCardOk
    }
    
    func setupApplePay() {
        PKPassLibrary().openPaymentSetup()
    }
    
    func payApplePay() {
        var anyError = false
        var stringError = ""
        
        Utils.removeRedBorder(field: self.amountField)
        Utils.removeRedBorder(field: self.emailField)
        
        if amountField.text == "" {
            anyError = true
            stringError = Translator.translateEmptyFields(lang: self.currentLang)
            Utils.addRedBorder(field: self.amountField)
        }
        
        // Check email
        if emailField.text != "" {
            if !Utils.isValidEmailAddress(emailAddressString: emailField.text!){
                anyError = true
                stringError = Translator.translateEmptyFields(lang: self.currentLang)
                Utils.addRedBorder(field: self.emailField)
            }
        }
        
        if (!anyError){
            if (amountField.text?.doubleValue)! > Double(50.0) || amountField.text?.doubleValue == Double(0.0)  {
                anyError = true
                stringError = Translator.translateSuperiorFields(lang: self.currentLang)
                Utils.addRedBorder(field: self.amountField)
            }
        }
        
        if (anyError){
            let alert = UIAlertController(title: "", message: stringError, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
        }else{
            Utils.removeRedBorder(field: self.amountField)
            
            // Create Apple Pay request
            let request = PKPaymentRequest()
            request.merchantIdentifier = APPLE_PAY_MERCHANT_IDENTIFIER
            request.countryCode = "FR"
            request.currencyCode = "EUR"
            request.supportedNetworks = paymentNetworks
            request.merchantCapabilities = .capability3DS
            request.paymentSummaryItems = [PKPaymentSummaryItem(label: "demo Apple Pay", amount: NSDecimalNumber(string: amountField.text))]
            
            let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request)
            authorizationViewController.delegate = self
            present(authorizationViewController, animated: true, completion: nil)
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        var email: String = "noemail"
        if emailField.text != "" {
            email = emailField.text!
        }
        let requestURL: String = APPLE_PAY_URL+email
        let myUrl = URL(string: requestURL);
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        request.httpBody = payment.token.paymentData
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                self.applePaymentDidSucceed = false
                completion(.failure)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let responseData = String(data: data!, encoding: String.Encoding.utf8)
                if(httpResponse.statusCode == 200 && responseData == "0"){
                    self.applePaymentDidSucceed = true
                    completion(.success)
                }else{
                    // Something goes wrong
                    self.applePaymentDidSucceed = false
                    completion(.failure)
                }
            }
        }
        task.resume()
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        if self.applePaymentDidSucceed {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
            controller.email = emailField.text!
            controller.lang = self.currentLang
            self.present(controller, animated: true, completion: nil)
        }
    }
    //================================================================================
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default

    }
    
    
    func createApplePayPaymentButton(isHidden: Bool){
        applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.addTarget(self, action: #selector(payApplePay), for: UIControlEvents.touchUpInside)
        applePayButtonArea.insertSubview(applePayButton, at: 0)
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerX, relatedBy: .equal, toItem: applePayButtonArea, attribute: .centerX, multiplier: 1, constant: 0))
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerY, relatedBy: .equal, toItem: applePayButtonArea, attribute: .centerY, multiplier: 1, constant: 0))
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .height, relatedBy: .equal, toItem: applePayButtonArea, attribute: .height, multiplier: 1, constant: 0))
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .width, relatedBy: .equal, toItem: applePayButtonArea, attribute: .width, multiplier: 1, constant: 0))
        applePayButton.isHidden = isHidden
    }
    
    func createApplePaySetUpButton(isHidden: Bool){
        //applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
        applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
        
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.addTarget(self, action: #selector(setupApplePay), for: UIControlEvents.touchUpInside)
        applePayButtonArea.insertSubview(applePayButton, at: 0)
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerX, relatedBy: .equal, toItem: applePayButtonArea, attribute: .centerX, multiplier: 1, constant: 0))
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerY, relatedBy: .equal, toItem: applePayButtonArea, attribute: .centerY, multiplier: 1, constant: 0))
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .height, relatedBy: .equal, toItem: applePayButtonArea, attribute: .height, multiplier: 1, constant: 0))
        applePayButtonArea.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .width, relatedBy: .equal, toItem: applePayButtonArea, attribute: .width, multiplier: 1, constant: 0))
        applePayButton.isHidden = isHidden
    }
}

