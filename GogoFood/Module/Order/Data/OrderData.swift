/* 
 Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar
 
 */

import Foundation
import ObjectMapper

enum OrderStatus: String {
    case pending = "pending"
    case cancel = "cancelled"
    case accept = "accepted"
    case dispatched = "dispatched"
    case completed = "completed"
    
    case pickedUp = "picked_up"
    case delivered = "delivered"
    case driverAssigned = "driver_assigned"
    case arrivedToRes = "arrived_to_restaurant"
    case started = "started"
    case arrived = "arrived"
    case none
}


class OrdersData: BaseData {
    #if Driver
    var newOrder: [OrderData] = []
    var order: [OrderInfoData] = []
    #else
    var order: [OrderData] = []
    #endif
    
    
    override func mapping(map: Map) {
        #if Driver
        newOrder <- map["new_orders"]
        order <- map["orders"]
        #else
        order <- map["orders"]
        #endif
        
    }
    
}

class CommentRootModel: BaseData {
    
    var commentList : [CommentList]?
    var productData : ProductData?
    
    override func mapping(map: Map) {
        commentList <- map["comments"]
        productData <- map["dish"]
    }
}




class CommentList: BaseData {
  
    

    var v : Int?
    var cid : Int?
    var dishId : Int?
    var filterStatus : String?
    var restaurantId : RestaurantsData?
    
    //
    var restaurant_id2: RestaurantProfileData?

    var status : String?
    var userComment : String?
    var restaurant_comment :String?
    var userCommentDate : String?
    var userId : UserDetail?
    
    final var isUser:Bool?
    var number:Int?
    
        
    required init?(map: Map) {
        super.init(map: map)
    }

    
    override func mapping(map: Map) {
        
        v <- map["__v"]
        cid <- map["_id"]
        dishId <- map["dish_id"]
        restaurant_comment <- map["restaurant_comment"]
        filterStatus <- map["filter_status"]
        restaurantId <- map["restaurant_id"]
        restaurant_id2 <- map["restaurant_id"]

        status <- map["status"]
        userComment <- map["user_comment"]
        userCommentDate <- map["user_comment_date"]
        userId <- map["user_id"]
    }
    
    
  
}

class SuccessMessageRootModel: BaseData {
    
    var message : String?
    var success : Bool?
    
    override func mapping(map: Map) {
        message <- map["message"]
        success <- map["success"]
    }
}

class  OrderDetailData: BaseData {
    var order: OrderData!
    override func mapping(map: Map) {
        order <- map["details"]
    }
    
    
}

class  DeliveryAddres: BaseData {
    
    var v : Int?
    var did : Int?
    var address : String?
    var commune : String?
    var createdAt : String?
    var district : String?
    var isDefault : Int?
    var latitude : Double?
    var longitude : Double?
    var province : String?
    var updatedAt : String?
    var userId : Int?
    var village : String?
    
    override func mapping(map: Map) {
        v <- map["__v"]
        did <- map["_id"]
        address <- map["address"]
        commune <- map["commune"]
        createdAt <- map["created_at"]
        district <- map["district"]
        isDefault <- map["is_default"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        province <- map["province"]
        updatedAt <- map["updated_at"]
        userId <- map["user_id"]
        village <- map["village"]
    }
}


class  RestaurantWise: BaseData {
    
    var v : Int?
    var Rid : Int?
    var cartId : [CartItemData]?
    var restaurantId : RestaurantProfileData?
    var createdAt : String?
    var deliveryCharges : Int?
    var deliveryChargesTax : Float?
    var deliveryType : String?
    var distance : Float?
    var driverId : AnyObject?
    var orderId : Int?
    var status : String?
    var updatedAt : String?
    var userId : Int?
    
    var tax_applicable :String?
    var tax_percent :Int?
    
    override func mapping(map: Map) {
        v <- map["__v"]
        Rid <- map["_id"]
        
        tax_percent <- map["tax_percent"]
        tax_applicable <- map["tax_applicable"]

        
        cartId <- map["cart_id"]
        restaurantId <- map["restaurant_id"]
        createdAt <- map["created_at"]
        deliveryCharges <- map["delivery_charges"]
        deliveryChargesTax <- map["delivery_charges_tax"]
        deliveryType <- map["delivery_type"]
        distance <- map["distance"]
        driverId <- map["driver_id"]
        orderId <- map["order_id"]
        status <- map["status"]
        updatedAt <- map["updated_at"]
        userId <- map["user_id"]
    }
    func getOrderStatus() -> OrderStatus {
           return OrderStatus.init(rawValue: self.status ?? "") ?? .none
       }
}

class  LiveTrackingRootClass: BaseData {
    
    var orderData : OrderData?
    
    override func mapping(map: Map) {
        orderData <- map["order"]
    }
}

class OrderData : BaseData {
    var user_id : ProfileData?
    var driver_id : DriverProfileData?
    #if Driver
    var restaurant_id: RestaurantProfileData?
    #else
    var restaurant_id : Int?
    #endif
    var order_id : OrderInfoData?
    var cart_id : [CartItemData]?
    var distance : Double?
    var delivery_charges : Double?
    var delivery_charges_tax : Double?
    private var status : String?
    var totalItems : Int?
    var orderTotal : Double?
    var delivery_address : DeliveryAddres?
    var rate_driver:Int?
    // For order Hisoty
    var restaurantWise : [RestaurantWise]?
    var totalAmount : Double?
    var OID : Int?
    var discount :Double?
    var coupon_type :String?
    var coupon_discount:Double?
    var coupon_code:String?
    var payment_status:String?
    var payment_method:String?
    override func mapping(map: Map) {
        super.mapping(map: map)
        rate_driver <- map["rate_driver"]
        payment_method <- map["payment_method"]
        payment_status <- map["payment_status"]
        discount <- map["discount"]
        coupon_type <- map["coupon_type"]
        coupon_discount <- map["coupon_discount"]
        coupon_code <- map["coupon_code"]

        user_id <- map["user_id"]
        driver_id <- map["driver_id"]
        restaurant_id <- map["restaurant_id"]
        order_id <- map["order_id"]
        cart_id <- map["cart_id"]
        distance <- map["distance"]
        delivery_charges <- map["delivery_charges"]
        delivery_charges_tax <- map["delivery_charges_tax"]
        status <- map["status"]
        totalItems <- map["total_items"]
        orderTotal <- map["order_total"]
        delivery_address <- map["delivery_address"]
        
        restaurantWise <- map["restaurant_wise"]
        totalAmount <- map["total_amount"]
        OID <- map["_id"]
    }
    
    func getOrderStatus() -> OrderStatus {
        return OrderStatus.init(rawValue: self.status ?? "") ?? .none
    }
    
    func getOrderStatusAsString() -> String {
        
        return " \(self.status ?? "") ".capitalized
    }
    
    func getColorForStatus() -> UIColor {
        switch OrderStatus.init(rawValue: self.status ?? "") ?? .none {
        case .cancel:
            return AppConstant.primaryColor
        case .pending:
            return AppConstant.appYellowColor
        case .accept:
            return AppConstant.appBlueColor
        default:
            break
        }
        
        return UIColor.clear
    }
    
    
    func getAutoCheckInTime() -> String {
        let now = TimeDateUtils.getDateinDateFormat(fromDate: self.getCreatedTime())
        let endDate = Date()
        let formatter = DateComponentsFormatter()
        let interval = Calendar.current.dateComponents([.minute], from: now, to: Date())
        if (interval.minute ?? 0) < 15 {
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .full
            return formatter.string(from: now, to: endDate)!
        }
        return "0m 0s"
    }

}

class DriverLiveTrackingData: BaseData {
    
    var driver_id : DriverProfileData?
    
    override func mapping(map: Map) {
        driver_id <- map["driver"]
    }
}
