//
//  MessageController.swift
//  Laundry
//
//  Created by Aidan Curtis on 4/14/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import Foundation
import UIKit


class MessageController: UIViewController{
    var rest = RestClient()
    var machineId:Int!
    var user:User!
    
    @IBOutlet weak var messageEditor: UITextView!
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendMessagePressed(_ sender: Any) {
        let _ = rest.messageUser(to: user.id!, message: messageEditor.text).done { (s) in
            self.navigationController?.popViewController(animated: true)
        }
    }
}
