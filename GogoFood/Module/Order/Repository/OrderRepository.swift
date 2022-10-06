//
//  OrderRepository.swift
//  Restaurant
//
//  Created by MAC on 28/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import CoreLocation

class OrderRepository: BaseRepository {
    
    #if Restaurant
    func getOrder(onComplition: @escaping responseObject<OrdersData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.liveOrderUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (item) in
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            if let d: OrdersData = self.getDataFrom(item) {
                onComplition(d)
            }
        }
        let id = CurrentSession.getI().localData.profile.id
        connectSocket("restaurant_orders", params: ["group":"restaurant_orders-\(id.description)"]){ data in
            if let d: OrdersData = self.getDataFromSocketData(data){
                onComplition(d)
            }
            
        }
    }
    
    func getTodayOrder(onComplition: @escaping responseObject<OrdersData>) {
        //showLoader(nil)
        Alamofire.request(ServerUrl.todayOrderUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString { (item) in
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            if let d: OrdersData = self.getDataFrom(item) {
                onComplition(d)
            }
        }
        let id = CurrentSession.getI().localData.profile.id
        connectSocket("restaurant_orders", params: ["group":"restaurant_orders-\(id.description)"]){ data in
            if let d: OrdersData = self.getDataFromSocketData(data){
                onComplition(d)
            }
            
        }
    }
    
    func removeItemFromOrder(_ id: [String], becauseOf reason: String, response: @escaping emptyResponse) {
        showLoader(nil)
        Alamofire.request(ServerUrl.removeItemUrl, method: .post, parameters: ["id": id, "reason": reason], encoding: JSONEncoding.default, headers: self.header).responseString { (serverResponse) in
            self.dismiss()
            guard let value = serverResponse.value else{return}
            guard  let responseData = Mapper<BaseObjectResponse<BaseData>>().map(JSONString: value) else {return}
            if responseData.success {
                 response()
            }else{
                self.showError(responseData.message)
            }
           
        }
    }
    
    func rejectOrder(id: Int, response: @escaping emptyResponse) {
        showLoader(nil)
        Alamofire.request(ServerUrl.rejectOrderUrl, method: .post, parameters: ["id":id], encoding: JSONEncoding.default, headers: self.header).responseString{ (item) in
            self.dismiss()
            if let _ : OrderData = self.getDataFrom(item) {
                response()
            }
        }

    }
    
    func orderFinish(_ id: String, response: @escaping emptyResponse) {
        showLoader(nil)
        Alamofire.request(ServerUrl.confirmPayment, method: .post, parameters: ["order_id": id], encoding: JSONEncoding.default, headers: self.header).responseString{ (item) in
            self.dismiss()
            //let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            let tmpStr = dict["message"] as? String
            if tmpStr == "success"{
                response()
            }
        }
    }
    
//    func orderFinish(_ id: String, response: @escaping emptyResponse) {
//        showLoader(nil)
//        Alamofire.request(ServerUrl.confirmPayment, method: .post, parameters: ["order_id": id], encoding: JSONEncoding.default, headers: self.header).responseString{ (item) in
//
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
//
//            if let _ : BaseData = self.getDataFrom(item) {
//                response()
//            }
//        }
//    }
    
    #elseif Driver

    func setAvailaiblityStatus(_ status: String, onDone: @escaping emptyResponse) {
        Alamofire.request(ServerUrl.changeStatusUrl,
                          method: .post,
                          parameters: ["status": status],
                          encoding: JSONEncoding.default,
                          headers: self.header)
            .responseString { (item) in
            if let _ : BaseData = self.getDataFrom(item) {
                onDone()
            }
        }
    }
    
    func getOrderList(onDone: @escaping responseObject<OrdersData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.onGoingOrderUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            if let d: OrdersData = self.getDataFrom(item) {
                onDone(d)
            }
        })
    }
    
    func updateUserLocation(_ location: CLLocationCoordinate2D, onDone: @escaping emptyResponse) {
        showLoader(nil)
        Alamofire.request(ServerUrl.updateAddressUrl,
                          method: .post,
//                          parameters: [ "longitude": location.longitude.description,
//                                        "latitude": location.latitude.description],
                                      parameters: [ "longitude": "76.8463644",
                                                    "latitude": "30.7127433"],
                          encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            if let _ : BaseData = self.getDataFrom(item) {
                onDone()
            }
        })
        
        
    }
    
    
    
    func confirmPickup(order: OrderData, onDone: emptyResponse) {
//        Alamofire.request(ServerUrl.confirmPickupUrl,
//                          method: .post,
//                          parameters: ["restaurant_id": 0,
//                                        "order_id": 1063],
//                          encoding: JSONEncoding.default,
//                          headers: self.header)
//            .responseString(completionHandler: { item in
//                if let _: BaseData = self.getDataFrom(item) {
//
//                }
//
//            })
        onDone()
    }
    
    
    func getOrderDetail(
        _ order: OrderData,
        onDone: @escaping responseObject<OrderDetailData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.restaurantOrderDetailsUrl,
                          method: .post,
                          parameters: ["restaurant_id": order.order_id?.restaurant_wise?.first?.restaurant_id?.id ?? 0,
                                       "order_id": order.order_id?.id ?? 0],
                          encoding: JSONEncoding.default, headers: self.header)
            .responseString(completionHandler: { response in
                if let d: OrderDetailData = self.getDataFrom(response) {
                    onDone(d)
                }
            })
        
    }
    
  
    #endif
    
//    func acceptOrder(_ orderId: Int, done: @escaping emptyResponse) {
//        Alamofire.request(ServerUrl.acceptOrderUrl,
//                          method: .post,
//                          parameters: ["order_id": orderId],
//                          encoding: JSONEncoding.default,
//                          headers: self.header)
//            .responseString { (data) in
//                
//            let dict = try! JSONSerialization.jsonObject(with: data.data!, options: []) as! NSDictionary
//            print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
//                
//            if let _: BaseData = self.getDataFrom(data) {
//                 done()
//            }
//            self.dismiss()
//        }
//    }
    
//    func setAvailaiblityStatus(_ status: String, onDone: @escaping emptyResponse) {
//        Alamofire.request(ServerUrl.changeStatusUrl,
//                          method: .post,
//                          parameters: ["status": status],
//                          encoding: JSONEncoding.default,
//                          headers: self.header)
//            .responseString { (item) in
//            if let _ : BaseData = self.getDataFrom(item) {
//                onDone()
//            }
//        }
//    }
    
    func orderHistory(onComplition: @escaping responseObject<OrdersData>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.orderHistoryUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            self.dismiss()
            
            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
            //print(dict)
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
                let str = String(data: data, encoding: .utf8) {
                print(str)
            }
            
            if let d: OrdersData = self.getDataFrom(item) {
                onComplition(d)
            }
            
        })
    }

    func getOrderStatus(_ orderId: String, onComplition: @escaping responseObject<LiveTrackingRootClass>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.orderDetailUrl, method: .post, parameters: ["order_id":orderId], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            self.dismiss()
            
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
            
            if let d: LiveTrackingRootClass = self.getDataFrom(item) {
                onComplition(d)
            }
        })
        
//        connectSocket("driver_new_order", params: ["group":"driver_new_order-90"]) { (data) in
//            print("--------------------")
//            if let d: LiveTrackingRootClass = self.getDataFromSocketData(data){
//                onComplition(d)
//            }
//        }
    }
    
    func getOrderStatusSocket(_ driverID: String, onComplition: @escaping responseObject<DriverLiveTrackingData>) {
        connectSocket("get_driver_location", params: ["group":"get_driver_location-\(driverID)"]) { (data) in
            print("--------------------")
            if let d: DriverLiveTrackingData = self.getDataFromSocketData(data){
                onComplition(d)
            }
        }
    }
    
    func writeReviewOrder(_ id: String, _ driverid: String, _ ratingStr: String, _ commentsStr: String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.rateDriverUrl, method: .post, parameters: ["order_id": id, "driver_id": driverid, "rating": ratingStr, "comments": commentsStr], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            
            self.dismiss()
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }
            
            if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                onComplition(d)
            }
        })
    }
    
    func GetItemCommentList(_ productID : String, onComplition: @escaping responseObject<CommentRootModel>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.getCommentListUrl + "/" + productID, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            self.dismiss()
            
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                print(str)
//            }
//
            if let d: CommentRootModel = self.getDataFrom(item) {
                onComplition(d)
            }
        })
    }

    func addCommentList(_ productID : String, restID : String, commentStr : String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
        showLoader(nil)
        Alamofire.request(ServerUrl.addCommentUrl, method: .post, parameters: ["dish_id":productID,"restaurant_id":restID,"comment":commentStr], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
            self.dismiss()
            
//            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
//            //print(dict)
//            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
//                let str = String(data: data, encoding: .utf8) {
//                //print(str)
//            }
            
            if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                onComplition(d)
            }
        })
    }
    
    func editCommentList(_ commentID : String, commentStr : String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
            showLoader(nil)
            Alamofire.request(ServerUrl.editCommentUrl, method: .post, parameters: ["id":commentID,"comment":commentStr], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
                self.dismiss()
                
    //            let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
    //            //print(dict)
    //            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
    //                let str = String(data: data, encoding: .utf8) {
    //                //print(str)
    //            }
                
                if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                    onComplition(d)
                }
            })
        }
    
    func deleteCommentList(_ commentID : String, onComplition: @escaping responseObject<SuccessMessageRootModel>) {
            showLoader(nil)
            Alamofire.request(ServerUrl.removeCommentUrl, method: .post, parameters: ["id":commentID], encoding: JSONEncoding.default, headers: self.header).responseString(completionHandler: { item in
                self.dismiss()
                
                let dict = try! JSONSerialization.jsonObject(with: item.data!, options: []) as! NSDictionary
                //print(dict)
                if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
                    let str = String(data: data, encoding: .utf8) {
                    print(str)
                }
                
                if let d: SuccessMessageRootModel = self.getDataFrom(item) {
                    onComplition(d)
                }
            })
        }
}

class GoogleSearchAPI {
    class func getDirectionInfo(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping ([String : AnyObject]) -> Void) {
        
        var url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(AppConstant.googleKey)"
        url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(url)
            .responseJSON { response in
                if let json = response.result.value as? [String: Any] {
//                    print("JSON: \(json)")
                    let mapResponse: [String: AnyObject] = json as [String : AnyObject]
                    completion(mapResponse)
                }
            }
    }
}
