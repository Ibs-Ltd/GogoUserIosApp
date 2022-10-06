//
//  MapRepository.swift
//  GogoFood
//
//  Created by MAC on 25/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import Foundation
import Alamofire
import GoogleMaps
import ObjectMapper

class MapRepository: BaseRepository {
    
   
    func addUser(_ add: GMSAddress,  onComplition: @escaping responseObject<OTPData>){
        let completeAddress = (add.lines ?? [""] as [String]).joined(separator: ",")
        #if Restaurant
        let params: Parameters = ["address": completeAddress, "state": add.administrativeArea ?? "", "city": add.locality ?? "", "latitude": add.coordinate.latitude,"longitude": add.coordinate.longitude]
        #else
        let params: Parameters = ["address": completeAddress,
                                  "user_id": CurrentSession.getI().localData.profile.default_address?.user_id ?? 0,
                                  "is_default": CurrentSession.getI().localData.profile.default_address?.is_default ?? 0,
                                  "province":add.subLocality ?? "",
                                  "district": add.locality ?? "",
                                  "commune": add.administrativeArea ?? "",
                                  "village": add.administrativeArea ?? "",
                                  "latitude": add.coordinate.latitude,
                                  "longitude": add.coordinate.longitude]
        #endif
        
        Alamofire.request(ServerUrl.updateAddressUrl, method: .post, parameters: params , encoding: JSONEncoding.default, headers: self.header).responseString { (item) in
             #if Restaurant
            if let d: OTPData = self.getDataFrom(item) {
                onComplition(d)
            }
            #else
            CurrentSession.getI().localData.profile.default_address = Mapper<AddressData>().map(JSON: params)
            CurrentSession.getI().saveData()
            
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }
            
            if let d: OTPData = self.getDataFrom(item) {
                onComplition(d)
            }
            
            #endif
        }
        
        
    }
    
    #if Driver
    func uppdateLocation(
        _ location: CLLocationCoordinate2D,
        onDone: @escaping emptyResponse) {
        Alamofire.request(ServerUrl.updateAddressUrl,
                          method: .post,
                          parameters: ["longitude": location.longitude,
                                       "latitude": location.latitude],
                          encoding: JSONEncoding.default,
                          headers: self.header)
            .responseString(completionHandler: { item in
                if let _: BaseData = self.getDataFrom(item) {
                    onDone()
                }
            })
    }
    
    #endif
   
    // Invite & Earn Repository
    func addBalanceToWallet(_ amount: String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        BaseRepository.shared.showLoader(nil)
        
//        showLoader(nil)
        Alamofire.request(ServerUrl.transferBalanceUrl, method: .post, parameters: ["amount" : amount], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
            DispatchQueue.main.async {
                        BaseRepository.shared.dismiss()

            }
            
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }

            if let d: SuccessMessageRootModel = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
    
    func referalDetailsListAPI(onComplition: @escaping responseObject<InviteData>) {

        BaseRepository.shared.showLoader(nil)

        Alamofire.request(ServerUrl.referalDetailsUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            DispatchQueue.main.async {
                                   BaseRepository.shared.dismiss()

                       }
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }

            if let d: InviteData = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
    
    func inviteListAPI(_ levelStrObj: String, onComplition: @escaping responseObject<InviteListRootData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.levelWiseUserUrl, method: .post, parameters: ["level":levelStrObj], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }

            if let d: InviteListRootData = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
    
    func checkServiceAvailableAPI(onComplition: @escaping (_ result: Bool)->()) {
        DispatchQueue.main.async {
            self.showLoader(nil)
        }
        
        Alamofire.request(ServerUrl.checkLocationURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getLocationHeader()).responseString { (data) in
            print(self.getLocationHeader())
            DispatchQueue.main.async {
                self.dismiss()
            }
            guard let data = data.data,data.count > 0 else{return}
            let dict = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            //print(dict)
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
                let str = String(data: data, encoding: .utf8) {
                print(str)
            }

            let tmpStr = dict["success"] as? Bool
            if tmpStr!{
                onComplition(true)
            }else{
                onComplition(false)
            }
        }
    }
    
    func walletHistoryAPI(onComplition: @escaping responseObject<WalletHistoryRootData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.walletHistoryUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }

            if let d: WalletHistoryRootData = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
    
    func singleDishRateWallet(_ dishID: String, ratingStr: Int, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.rateDishUrl, method: .post, parameters: ["dish_id" : dishID, "rating" : ratingStr], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }

            if let d: SuccessMessageRootModel = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
    
    func skipRateWallet(_ dishID: String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.skipRatingUrl, method: .post, parameters: ["dish_id" : dishID], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }

            if let d: SuccessMessageRootModel = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
}
