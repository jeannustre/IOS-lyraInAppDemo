//
//  ErrorViewController.swift
//  lyraInAppDemo
//
//  Created by Nelson Nunes on 05/09/2017.
//  Copyright © 2017 Lyra Network. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    var reason: String = "";
    var lang: LANG = .ENGLISH;
    var increaseSize: Bool = false
    @IBOutlet weak var textContainer: UITextView!
    @IBOutlet weak var successMessage: UITextView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var heightContraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImage(named: "Default.jpg")
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = backgroundImage
        view.insertSubview(backgroundImageView, at: 0)
        
        Translator.translateError(lang: self.lang, successMessage: self.successMessage, reason: self.reason, button: backButton)
        
        if increaseSize {
            heightContraint.constant = 70
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
