//
//  CartRepository.swift
//  GogoFood
//
//  Created by Crinoid Mac Mini on 04/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import Foundation
import Alamofire


class CartRepository: BaseRepository {
    
    
    func appToCart(dishId: ProductData, toppings: [Int], onComplition: @escaping responseObject<CartData>) {
        DispatchQueue.main.async {
            BaseRepository.shared.dismiss()
        }
        BaseRepository.shared.showLoader(nil)

//    showLoader(nil)
        var param: Parameters = ["dish_id": dishId.id, "restaurant_id": dishId.restaurant_id?.id ?? 0]
        if !toppings.isEmpty {
            param["toppings"] = toppings
        }
        Alamofire.request(ServerUrl.addToCartUrl, method: .post, parameters: param, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
            if let d: CartData = self.getDataFrom(data) {
                 self.saveCartToCurrentSession(d)
                onComplition(d)
            }
        }
    }
    
    func confirmOrderWithScanQrCode(_ id: String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        BaseRepository.shared.showLoader(nil)
        Alamofire.request(ServerUrl.scanQrCode, method: .post, parameters: ["order_id": id], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                onComplition(d)
            }
        })
    }
    func cancelOrder(_ id: String,url:String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        BaseRepository.shared.showLoader(nil)
        Alamofire.request(url, method: .post, parameters: ["order_id": id], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
            //            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
            //            //print(dict)
            //            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
            //                let str = String(data: data, encoding: .utf8) {
            //                print(str)
            //            }
            
            if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                onComplition(d)
            }
        })
    }
    
    func confirmOrder(_ id: String,url:String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        BaseRepository.shared.showLoader(nil)
        Alamofire.request(url, method: .post, parameters: ["order_id": id], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                onComplition(d)
            }
        })
    }
    
    func modifyQuantity(hasIncrease: Bool, cartId: Int, onComplition: @escaping responseObject<CartData>) {
        
      BaseRepository.shared.showLoader(nil)
        let serverUrl = hasIncrease ? ServerUrl.increaseQuantity : ServerUrl.decreaseQuantity
          Alamofire.request(serverUrl, method: .post, parameters: ["cart_id": cartId], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
            
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
            
              if let d: CartData = self.getDataFrom(data) {
                self.saveCartToCurrentSession(d)
                  onComplition(d)
              }
          }
      }
    
    func updateTopping(cartId: Int, topping: [Int], onComplition: @escaping responseObject<CartData>) {
//        showLoader(nil)
        BaseRepository.shared.showLoader(nil)
        Alamofire.request(ServerUrl.updateTopingUrl, method: .post, parameters: ["cart_id": cartId, "toppings": topping], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
              if let d: CartData = self.getDataFrom(data) {
                self.saveCartToCurrentSession(d)
                  onComplition(d)
              }
          }
    }
    
    func removeDish(_ id: Int, onComplition: @escaping responseObject<CartData>) {
//        showLoader(nil)
        BaseRepository.shared.showLoader(nil)

        Alamofire.request(ServerUrl.decreaseDishUrl, method: .post, parameters: ["dish_id": id.description], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            DispatchQueue.main.async {
                          BaseRepository.shared.dismiss()
                      }
            if let d: CartData = self.getDataFrom(data) {
                self.saveCartToCurrentSession(d)
                onComplition(d)
            }
        }
    }
    
    
    func getCartItems(onComplition: @escaping responseObject<CartData>) {
        BaseRepository.shared.showLoader(nil)
        Alamofire.request(ServerUrl.viewCartUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            DispatchQueue.main.async {
                          BaseRepository.shared.dismiss()
                      }
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }

            if let d: CartData = self.getDataFrom(data) {
                self.saveCartToCurrentSession(d)
                onComplition(d)
            }
        }
        let userId = CurrentSession.getI().localData.profile.id
        connectSocket("cart_data", params: ["group": "cart_data-\(userId)"]) { (data) in
            if let d: CartData = self.getDataFromSocketData(data){
                onComplition(d)
            }
        }
        
    }
    
    
    func placeOrder(paymentMethod: String, onComplition: @escaping responseObject<BaseObjectResponse<BaseData>>) {

            BaseRepository.shared.showLoader(nil)

        Alamofire.request(ServerUrl.checkoutUrl, method: .post, parameters: ["payment_method": paymentMethod], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
                       DispatchQueue.main.async {
                          BaseRepository.shared.dismiss()
                      }
            if let d: BaseObjectResponse = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
    
    func applyCoupnCode(_ codeStr: String, onComplition: @escaping responseObject<CouponData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.applyCoupon, method: .post, parameters: ["promocode": codeStr], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            DispatchQueue.main.async {
                      self.dismiss()
                  }
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }

            if let d: CouponData = self.getDataFrom(data) {
                if d.couponDic == nil{
                    self.showError("Promocode is invalid!")
                }
                onComplition(d)
            }
        }
    }
    
    func removeCoupnCode(onComplition: @escaping responseObject<CouponData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.removeCoupon, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            DispatchQueue.main.async {
                      self.dismiss()
                  }
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }

            if let d: CouponData = self.getDataFrom(data) {
//                if d.couponDic == nil{
//                    self.showError("Promocode is invalid!")
//                }
                onComplition(d)
            }
        }
    }
    
    private func saveCartToCurrentSession(_ data: CartData) {
        CurrentSession.getI().localData.cart = data
        CurrentSession.getI().saveData()
    }
    
    
}
