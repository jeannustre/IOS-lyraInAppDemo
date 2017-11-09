//
//  Translator.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 07/09/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import UIKit
import WebKit

enum LANG {
    case ENGLISH
    case FRENCH
    case SPANISH
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

class Translator{
    static var payButtonLabels: [LANG:String] = [
        .ENGLISH : "Pay with PayZen",
        .FRENCH : "Payer avec PayZen",
        .SPANISH : "Pagar con PayZen"
    ]
    static var amountFieldLabels: [LANG:String] = [
        .ENGLISH : "Amount",
        .FRENCH : "Montant",
        .SPANISH : "Importe"
    ]
    
    static var emailFieldLabels: [LANG:String] = [
        .ENGLISH : "Email",
        .FRENCH : "Email",
        .SPANISH : "Email"
    ]
    
    static var textContainerSuccessLabelsWithEmail: [LANG:String] = [
        .ENGLISH : "Payment successful, an email confirmation have been sent to EMAIL",
        .FRENCH : "Paiement accepté, une confirmation a été envoyé à EMAIL",
        .SPANISH : "Pago realizado, un email de confirmation ha sido enviado a EMAIL"
    ]

    
    static var successLabels: [LANG:String] = [
        .ENGLISH : "Payment successful",
        .FRENCH : "Paiement accepté",
        .SPANISH : "Pago realizado"
    ]
    
    static var errorLabels: [LANG:String] = [
        .ENGLISH : "Payment failed",
        .FRENCH : "Paiement échoué",
        .SPANISH : "Error de pago"
    ]
    
    static var poweredMessageLabels: [LANG:String] = [
        .ENGLISH : "Powered with love By Lyra",
        .FRENCH : "Propulsé Par Lyra",
        .SPANISH : "Impulsado por Lyra"
    ]
    
    static var errorEmptyFields: [LANG:String] = [
        .ENGLISH : "Invalid input",
        .FRENCH : "Saisie invalide",
        .SPANISH : "Entrada inválida"
    ]
    static var errorInvalidEmailFields: [LANG:String] = [
        .ENGLISH : "Invalid Email",
        .FRENCH : "Email invalide",
        .SPANISH : "Email no válido"
    ]
    
    static var errorEmailSuperiorFields: [LANG:String] = [
        .ENGLISH : "Amount must be lower than 51",
        .FRENCH : "Le montant doit être inférieur à 51 Euros",
        .SPANISH : "Le importe debe ser inferior a 51 Euros"
    ]
    
    static var errorSubmitForm: [LANG:String] = [
        .ENGLISH : "Unavailable operation due to connectivity failure",
        .FRENCH : "Opération impossible faute de connexion",
        .SPANISH : "operación imposible, problema de conectividad"
    ]
    
    static var chooseLang: [LANG:String] = [
        .ENGLISH : "Your language",
        .FRENCH : "Votre langue",
        .SPANISH : "Su lenguaje"
    ]
    
    static var backButton: [LANG:String] = [
        .ENGLISH : "Back to home",
        .FRENCH : "Retour à l'accueil",
        .SPANISH : "Volver al inicio"
    ]
    
    static var abandonedStatus: [LANG:String] = [
        .ENGLISH : "Abandoned payment",
        .FRENCH : "Paiement abandonné",
        .SPANISH : "Pago cancelado"
    ]
    
    static var expirationStatus: [LANG:String] = [
        .ENGLISH : "Expired payment",
        .FRENCH : "Paiement expiré",
        .SPANISH : "Pago expirado"
    ]
    
    static var refusedStatus: [LANG:String] = [
        .ENGLISH : "Refused payment",
        .FRENCH : "Paiement refusé",
        .SPANISH : "Pago rechazado"
    ]
    
    static var loader: [LANG:String] = [
        .ENGLISH : "Loading ...",
        .FRENCH : "Chargement ...",
        .SPANISH : "Cargamento ..."
    ]
    
    static func translateStatus(lang :LANG, reason : String) -> String {
        if reason == "ABANDONED" {
            return abandonedStatus[lang]!
        } else if reason == "REFUSED" {
            return refusedStatus[lang]!
        }else if reason == "NETWORK" {
            return errorSubmitForm[lang]!
        }else if reason == "EXPIRATION" {
            return abandonedStatus[lang]!
        }
        return ""
    }
    
    static func translateDropDownValue(lang :LANG) -> [String] {
        if lang == .ENGLISH {
            return ["All", "CB", "Visa", "Mastercard"]
        }else if lang == .SPANISH {
            return ["Todas", "CB", "Visa", "Mastercard"]
        }else {
            return ["Toutes", "CB", "Visa", "Mastercard"]
        }
    }
    
    static func translateLoader(lang :LANG) -> String {
        return loader[lang]!
    }
    
    static func translateChooseLang(lang :LANG) -> String {
        return chooseLang[lang]!
    }
    
    static func translateErrorSubmitForm(lang :LANG) -> String {
        return errorSubmitForm[lang]!
    }
    
    static func translateSuperiorFields(lang :LANG) -> String {
        return errorEmailSuperiorFields[lang]!
    }
    
    static func translateEmptyFields(lang :LANG) -> String {
        return errorEmptyFields[lang]!
    }
    
    static func translateInvalidEmailFields(lang :LANG) -> String {
        return errorInvalidEmailFields[lang]!
    }
    
    static func translate(lang :LANG, payButton: UIButton, amountField: UITextField, emailField: UITextField, poweredMessage : UITextView){
        payButton.setTitle(payButtonLabels[lang], for: UIControlState.normal)
        amountField.placeholder = amountFieldLabels[lang]
        emailField.placeholder = emailFieldLabels[lang]
        poweredMessage.text = poweredMessageLabels[lang]! + " - " + Bundle.main.releaseVersionNumber! + "." + Bundle.main.buildVersionNumber!
    }
    
    static func translateSuccess(lang :LANG, textContainer: UITextView, email: String, button: UIButton, heightContraintTitle: NSLayoutConstraint){
        if email == "" {
            textContainer.text = successLabels[lang]
        }else {
            textContainer.text = textContainerSuccessLabelsWithEmail[lang]
            textContainer.text = textContainer.text.replacingOccurrences(of: "EMAIL", with: email)
            textContainer.font = .systemFont(ofSize: 14)
            heightContraintTitle.constant = 70
        }
        button.setTitle(backButton[lang], for: UIControlState.normal)
    }
    
    static func translateError(lang :LANG, successMessage: UITextView, reason: String, button: UIButton){
        successMessage.text = translateStatus(lang : lang, reason: reason)
        button.setTitle(backButton[lang], for: UIControlState.normal)
    }
    
    static func translateLangFronPayzen(lang: String) -> LANG{
        if lang == "en" {
            return .ENGLISH
        }
        if lang == "fr" {
            return .FRENCH
        }
        if lang == "es" {
            return .SPANISH
        }
        return .ENGLISH
    }
    
}
