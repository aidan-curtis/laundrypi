//
//  FreeController.swift
//  Laundry
//
//  Created by Aidan Curtis on 4/14/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import Foundation
import UIKit


class FreeController: UIViewController{
    
    @IBOutlet weak var washerNumber: UILabel!
    @IBOutlet weak var machineText: UILabel!
    
    var machineId:Int!
    var user:User!
    
    override func viewDidLoad() {
        washerNumber.text = "\(machineId!)"
    }
    
    let rest = RestClient();
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func endSessionPressed(_ sender: Any) {
        let _ = rest.endSession(machineId: machineId).done { (s) in
            if(s.success)!{
                self.navigationController?.popViewController(animated: true)
            }else{
                self.alert(message: "Cannot empty this machine")
            }
        }
    }
    
}
