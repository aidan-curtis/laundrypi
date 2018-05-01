//
//  File.swift
//  DigitalGym
//
//  Created by Aidan Curtis on 3/17/18.
//  Copyright © 2018 southpawac. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire



class RestClient{

//    let uri = "http://ec2-52-203-182-95.compute-1.amazonaws.com:8000"
    let uri = "http://ec2-52-203-182-95.compute-1.amazonaws.com"

    func login(email: String, password: String) -> Promise<User> {
        let q = DispatchQueue.global()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let pnk = UserDefaults.standard.value(forKey: "pushNotificationKey") as! String
        let parameters: Parameters = ["email": email, "password": password, "pushNotificationKey": pnk]
        
        return firstly {
            Alamofire.request(uri+"/authenticate", method: .post, parameters: parameters).responseData()
            }.map(on: q) { data, rsp in
                try JSONDecoder().decode(User.self, from: data)
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func register(email: String, password: String, name: String) -> Promise<User> {
        
        let q = DispatchQueue.global()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let pnk = UserDefaults.standard.value(forKey: "pushNotificationKey") as! String
        let parameters: Parameters = ["email": email, "password": password, "name": name, "pushNotificationKey": pnk]

        return firstly {
            Alamofire.request(uri+"/setup_account", method: .post, parameters: parameters).responseData()
            }.map(on: q) { data, rsp in

                try JSONDecoder().decode(User.self, from: data)
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

    }
    
    func endSession(machineId: Int) -> Promise<Session>{
        let q = DispatchQueue.global()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let parameters: Parameters = ["machineId": machineId]
        let headers: HTTPHeaders = ["Authorization": global_user.token!]
        
        return firstly {
            Alamofire.request(uri+"/endSession", method: .post, parameters: parameters, headers: headers).responseData()
            }.map(on: q) { data, rsp in
                try JSONDecoder().decode(Session.self, from: data)
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    func emptySession(machineId: Int, to: Int) -> Promise<Session>{
        let q = DispatchQueue.global()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let parameters: Parameters = ["machineId": machineId,
                                      "to": to]
        let headers: HTTPHeaders = ["Authorization": global_user.token!]
        
        return firstly {
            Alamofire.request(uri+"/emptySession", method: .post, parameters: parameters, headers: headers).responseData()
            }.map(on: q) { data, rsp in
                try JSONDecoder().decode(Session.self, from: data)
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    func messageUser(to: Int, message: String) -> Promise<Session>{
        let q = DispatchQueue.global()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let parameters: Parameters = ["to": to,
                                      "message": message]
        let headers: HTTPHeaders = ["Authorization": global_user.token!]
        
        return firstly {
            Alamofire.request(uri+"/messageUser", method: .post, parameters: parameters, headers: headers).responseData()
            }.map(on: q) { data, rsp in
                try JSONDecoder().decode(Session.self, from: data)
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    func getMachineStatus(machineId: Int) -> Promise<Session>{
        let q = DispatchQueue.global()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let parameters: Parameters = ["machineId": machineId]
        let headers: HTTPHeaders = ["Authorization": global_user.token!]
        
        return firstly {
            Alamofire.request(uri+"/getMachineStatus", method: .post, parameters: parameters, headers: headers).responseData()
            }.map(on: q) { data, rsp in
                try JSONDecoder().decode(Session.self, from: data)
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    func requestSession(machineId: Int) -> Promise<User> {
        let q = DispatchQueue.global()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let parameters: Parameters = ["machineId": machineId]
        let headers: HTTPHeaders = ["Authorization": global_user.token!]

        return firstly {
            Alamofire.request(uri+"/requestSession", method: .post, parameters: parameters, headers: headers).responseData()
            }.map(on: q) { data, rsp in
                try JSONDecoder().decode(User.self, from: data)
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }

}
