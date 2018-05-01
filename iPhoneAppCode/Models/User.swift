//
//  User.swift
//  DigitalGym
//
//  Created by Aidan Curtis on 3/17/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import Foundation

class User : Decodable{
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case token = "token"
        case success = "success"
        case name = "name"
        case email = "email"
    }
    
    var id: Int?
    var token: String?
    var name: String?
    var success: Bool?
    var email: String?
}

