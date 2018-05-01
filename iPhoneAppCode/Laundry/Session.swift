//
//  Session.swift
//  Laundry
//
//  Created by Aidan Curtis on 4/14/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import Foundation


class Session : Decodable{
    
    enum CodingKeys: String, CodingKey {
        case id = "machineId"
        case success = "success"
        case user = "user"
    }
    
    var id: Int?
    var user: User?
    var success: Bool?

    
}

