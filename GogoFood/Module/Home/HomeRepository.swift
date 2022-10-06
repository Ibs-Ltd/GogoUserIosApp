//
//  HomeRepository.swift
//  GogoFood
//
//  Created by MAC on 01/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import Foundation
import Alamofire
import SocketIO


class HomeRepository: BaseRepository {
    func getHomeData(onComplition: @escaping responseObject<HomeData>) {

//        BaseRepository.shared.showLoader(nil)
        Alamofire.request(ServerUrl.homeUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.getLocationHeader()).responseString { (data) in
            
            DispatchQueue.main.async {
            //    BaseRepository.shared.dismiss()
            }
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
//            
            if let data: HomeData = self.getDataFrom(data) {
                onComplition(data)
            }
        }
    }
    
    
    func getStoreInformation(_ id: Int, onComplition: @escaping responseObject<StoreInfomationData>) {
//        showLoader(nil)
        Alamofire.request(ServerUrl.storeInfomationUrl, method: .post, parameters: ["restaurant_id": id], encoding: JSONEncoding.default, headers: self.getLocationHeader()).responseString { (data) in
            DispatchQueue.main.async {
           //     self.dismiss()
            }
            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
            //print(dict)
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
                let str = String(data: data, encoding: .utf8) {
                print(str)
            }
            
            if let d: StoreInfomationData = self.getDataFrom(data) {
                onComplition(d)
            }
        }
//        connectSocket("user_single_restaurant", params: ["group": "user_single_restaurant-\(id)"]) { (data) in
//            if let d: StoreInfomationData = self.getDataFromSocketData(data) {
//                onComplition(d)
//            }
//        }
    
    }
    
    func getFavoriteList(_ stringKeyword: String, onComplition: @escaping responseObject<StoreInfomationData>) {
//        showLoader(nil)
        Alamofire.request(ServerUrl.favoritesUrl, method: .post, parameters: ["keyword": stringKeyword], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: StoreInfomationData = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    
    }
    
    func getallResturants(top: Bool, onComplition: @escaping responseObject<RestaurantsData>) {
        showLoader(nil)
        Alamofire.request(top ? ServerUrl.topRestaurantUrl : ServerUrl.allRestaurantsUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: getLocationHeader()).responseString { (data) in
            
//            guard let dataValue  = data.data else{return}
//            
//            let dict = try? JSONSerialization.jsonObject(with: dataValue, options: []) as?  NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict ?? [:], options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: RestaurantsData = self.getDataFrom(data)  {
                onComplition(d)
            }
        }
    }
    
    func getProductOf(categoryId: String, of restaurantId: Int, limit: Int, page: Int, onComplition: @escaping responseObject<MenuData>) {
    
        BaseRepository.shared.showLoader(nil)
        
        Alamofire.request(ServerUrl.catgeoryWiseProductUrl, method: .post, parameters: ["restaurant_id": restaurantId, "category_id": categoryId], encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: MenuData = self.getDataFrom(data)  {
                onComplition(d)
            }
        }
    }
    
    func getAllRecommendedItem(onComplition: @escaping responseObject<RecommendedMenuData>) {
        showLoader(nil)
//        let headers : HTTPHeaders = ["token": CurrentSession.getI().localData.token ?? "",
//                                     "limit": "10",
//                                     "page": "1"]
        Alamofire.request(ServerUrl.allRecommendedUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: RecommendedMenuData = self.getDataFrom(data)  {
                onComplition(d)
            }
        }
    }
    
    func getAllToopOrder(onComplition: @escaping responseObject<RecommendedMenuData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.allTopUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: RecommendedMenuData = self.getDataFrom(data)  {
                onComplition(d)
            }
        }
    }
    
    func getDetailOf(_ data: ProductData, onComplition: @escaping responseObject<FoodDetailData>) {

        BaseRepository.shared.showLoader(nil)

        Alamofire.request(ServerUrl.singleDishUrl, method: .post, parameters: ["id": data.id, "restaurant_id": data.restaurant_id?.id ?? 0], encoding: JSONEncoding.default, headers: getLocationHeader()).responseString { (item) in
            
            
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: FoodDetailData = self.getDataFrom(item) {
                onComplition(d)
            }
        }
        connectSocket("user_single_dish", params: ["group": "user_single_dish-\(data.id)"]) { (data) in
            if let d: FoodDetailData = self.getDataFromSocketData(data) {
                onComplition(d)
            }
        }
    }
    
    func postDishLike(_ dishID: String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.likeProductUrl, method: .post, parameters: ["dish_id": dishID], encoding: JSONEncoding.default, headers: self.header).responseString { (item) in
            
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }
            
            if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                onComplition(d)
            }
        }
    }
    
    func postDishFavourite(_ dishID: String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        BaseRepository.shared.showLoader(nil)

        Alamofire.request(ServerUrl.favProductUrl, method: .post, parameters: ["dish_id": dishID], encoding: JSONEncoding.default, headers: self.header).responseString { (item) in
            
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
        }
    }
    
    func notificationListAPI(onComplition: @escaping responseObject<NotificationListRootData>) {

        BaseRepository.shared.showLoader(nil)
        

        Alamofire.request(ServerUrl.notificationsURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (data) in
            
            DispatchQueue.main.async {
                BaseRepository.shared.dismiss()
            }
            
            
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }

            if let d: NotificationListRootData = self.getDataFrom(data) {
                onComplition(d)
            }
        }
    }
    
    func searchDishAPI(_ params: [String:Any], onComplition: @escaping responseObject<FoodDetailData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.searchItemUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getLocationHeader()).responseString { (item) in
            
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: FoodDetailData = self.getDataFrom(item) {
                onComplition(d)
            }
        }
    }
}
