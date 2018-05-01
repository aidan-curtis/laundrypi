//
//  SuccessController.swift
//  Laundry
//
//  Created by Aidan Curtis on 4/9/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import Foundation
import UIKit


class SuccessController: UIViewController{
    @IBOutlet weak var washerNumber: UILabel!
    @IBOutlet weak var machineText: UILabel!
    
    
    var machineId:Int!
    var user:User!
 
    override func viewDidLoad() {
        washerNumber.text = "\(machineId!)"
        machineText.text = "This machine is being used by \(user.name!)"
    }
    
    var rest = RestClient()
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func sendMessagePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MessageController") as! MessageController
        vc.machineId = self.machineId
        vc.user = self.user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func endSession(_ sender: Any) {
        let _ = rest.emptySession(machineId: machineId, to: user.id!).done { (s) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
