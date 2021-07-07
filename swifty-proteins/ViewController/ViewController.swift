//
//  ViewController.swift
//  swifty-proteins
//
//  Created by Amine Mersoul on 7/7/21.
//  Copyright © 2021 Amine Mersoul. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let context = LAContext()
        var error: NSError? = nil
        if (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            print("Biometrics auth supported!")
        } else {
            authButton.isHidden = true
            print("Biometrics auth not supported!")
        }
    }

    @IBAction func auth(_ sender: Any) {
        let context = LAContext()
        var error: NSError? = nil
        if (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please Auth with touch id!") { [weak self]success, error in
                DispatchQueue.main.async {
                     guard success, error == nil else {
                        // failed
                        return
                    }
                    
                    // success
                    
                    self?.performSegue(withIdentifier: "auth", sender: nil)
                    
                }
            }
        } else {
            // can't use
            let alert = UIAlertController(title: "not supported", message: "your phone dont support biometrics", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @IBAction func skip(_ sender: Any) {
        print("skip login")
        performSegue(withIdentifier: "auth", sender: nil)
    }
    
}

