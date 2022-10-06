//
//  CurrentSession.swift
//  Stay Bet
//
//  Created by PropApp on 08/02/17.
//  Copyright © 2017 Stay Bet. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class CurrentSession {
    //    let Authorization = ""
    //    let KEY_LOCAL_DATA = "local"
    //
    //
    private static var i : CurrentSession!
    //
    //
    //    let dobFormatter = DateFormatter()
    //    var sessionId = "$2y$10$pt7cH/DseV9o5Nw/m3t8c.OWJ1Td2yoNFE1SwOlYOlE5ZCOiZTp3G"
    //
    //    var profile : ProfileData!
    //
    //    var loginData = LoginResponseData()
    var localData = LocalData()
    //
    //    var token = ""
    //    var mobile = ""
    //
    static func getI() -> CurrentSession {
        
        if i == nil {
            i = CurrentSession()
        }
        
        return i
    }
    //
    init() {
        //
        //        if let data = UserDefaults.standard.object(forKey: KEY_PROFILE) as? Data {
        //            let unarc = NSKeyedUnarchiver(forReadingWith: data)
        //            profile = unarc.decodeObject(forKey: "root") as! ProfileData
        //        }
        //
        
        if let data = UserDefaults.standard.string(forKey: "localData"){
            localData = LocalData(JSONString: data) ?? LocalData()
        }
        
        //
        //
        //
        //
        //
        //
        //        dobFormatter.dateFormat = "yyyy-MM-dd"
        
    }
    //
    func saveData() {
        let ud = UserDefaults.standard
        ud.set(localData.toJSONString() ?? "", forKey: "localData")
    }
    //
    //    func isUserLoginIn() -> Bool {
    //        return !sessionId.isEmpty
    //    }
    //
    func onLogout() {
        self.localData = LocalData()
        saveData()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "inital")
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
    }
    
    
    func getAppType() -> App {
        #if User
        
        #elseif Restaurant
        
        #endif
        if Bundle.main.bundleIdentifier == "com.gogo.driver" {
            return App.driver
        }
        if Bundle.main.bundleIdentifier == "com.gogo.userApp" {
            return App.user
        }
        return App.restaurant
    }
}


enum App {
    case user
    case driver
    case restaurant
}


class LocalData: BaseData {
    var profile: ProfileData!
    var cart: CartData = CartData()
    var token: String! = ""
    var fireBaseToken: String!
    override func mapping(map: Map) {
        profile <- map["user"]
        cart <- map["cart"]
        token <- map["token"]
    }
    
    func clearAll() {
        cart = CartData()
    }
}
