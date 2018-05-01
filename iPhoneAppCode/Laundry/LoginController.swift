//
//  LoginController.swift
//  DigitalGym
//
//  Created by Aidan Curtis on 3/16/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import Foundation
import UIKit





class LoginController:UIViewController, UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func loginPressed(_ sender: Any) {
        let rest = RestClient()
        let _ = rest.login(email: emailInput.text!, password: passwordInput.text!).done { (user) in
            if(user.success)!{
                global_user = user
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ScanController")
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                self.alert(message: "BAD")
            }
        }
 
    }
    @IBOutlet weak var passwordInput: CustomTextField!
    @IBOutlet weak var emailInput: CustomTextField!
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
