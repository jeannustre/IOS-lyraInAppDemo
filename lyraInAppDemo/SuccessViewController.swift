//
//  SuccessViewController.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 04/09/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    var email: String = "";
    var lang: LANG = .ENGLISH;
    @IBOutlet weak var textContainer: UITextView!
    @IBOutlet weak var successMessage: UITextView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var heightContraint: NSLayoutConstraint!
    @IBOutlet weak var heightContraintTitle: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "Default.jpg")
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = backgroundImage
        view.insertSubview(backgroundImageView, at: 0)
        
        Translator.translateSuccess(lang: self.lang, textContainer: self.textContainer, email : self.email, button: backButton, heightContraintTitle: heightContraintTitle)
        
        if textContainer.text == "" {
            textContainer.isHidden = true
            heightContraint.constant = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

