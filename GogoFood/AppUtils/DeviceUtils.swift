//
//  DeviceUtils.swift
//  User
//
//  Created by Keo Ratanak on 9/3/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import Foundation

func checkDevice()->DeviceType{
    var deviceType:DeviceType = .unknown
    if UIDevice().userInterfaceIdiom == .phone {
    switch UIScreen.main.nativeBounds.height {
        case 1136,1334:
            deviceType =  DeviceType.small
        case 1920, 2208,2436,2688,1792:
            deviceType =  DeviceType.big
        default:
            deviceType =  DeviceType.unknown
        }
    }
    return deviceType
}

enum DeviceType{
    case unknown
    case  small
    case  big
}
