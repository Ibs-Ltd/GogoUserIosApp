//
//  VerifyOTPData.swift
//  GogoFood
//
//  Created by MAC on 23/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import Foundation
import ObjectMapper

class OTPData: BaseData {

    var profile: ProfileData!
    var userStatus = ""
    var token: String? = ""
    
    override func mapping(map: Map) {
        token <- map["token"]
        profile <- map["user"]
        userStatus <- map["user_status"]
    }
}


