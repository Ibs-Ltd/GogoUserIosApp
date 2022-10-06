/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

class CartData : BaseData {
	var user: ProfileData!
    var cartItems: [CartItemData] = []
    var delivery_fee: [DeliveryData]?
    var vat: Double?
    var multiple: Bool = false // false means items is not able to delete becuase it contains different items
    var taxPercent: Double?
    var couponDic: CouponDic?
    var promoApplied : CouponDic?
	override func mapping(map: Map) {

		user <- map["user"]
		cartItems <- map["cart"]
        promoApplied <- map["promo.promocode_id"]

        delivery_fee <- map["delivery"]
        vat <- map["vat"]
        multiple <- map["multiple"]
        taxPercent <- map["tax_percent"]
        couponDic <- map["coupon"]
        
	}
    
    func getSubtotal() -> String {
        let totalPrice = cartItems.compactMap({$0.calculateTotalPrice()}).reduce(0, +)
        if totalPrice != 0.0 {
            return String(format: "$ %.2f", totalPrice)
        }
        return ""
        
    }
    
    func getVat() -> String {
        
        let checkTmpBool = cartItems.compactMap({$0.checkVatApplyOrNot()})
        
        var isCouponApplied:Bool?
        if let _ = self.couponDic?.discount{
            if self.couponDic?.promotionType == "amount" {
                isCouponApplied = true
            }else{
                isCouponApplied = true
            }
            
        }
        
        if checkTmpBool.contains("no"){
            var nonTaxtotal = 0.0
            for (index,value) in checkTmpBool.enumerated(){
                if value == "no"{
                    let dishTotal = cartItems[index].getTotalPrice(isCouponApplied).replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0
                    nonTaxtotal = nonTaxtotal + dishTotal
                }
            }
            
            
            
            var totalPrice = cartItems.compactMap({$0.calculateTotalPrice(isCouponApplied)}).reduce(0, +)
            totalPrice =  totalPrice - nonTaxtotal            
            let totalVat  = (totalPrice * (self.taxPercent ?? 0.0)) / 100
            if totalPrice != 0.0 {
                return String(format: "$ %.2f", totalVat).replacingOccurrences(of: "-", with: "")
            }
        }else{
            let totalPrice = cartItems.compactMap({$0.calculateTotalPrice(isCouponApplied)}).reduce(0, +)
            let totalVat  = (totalPrice * (self.taxPercent ?? 0.0)) / 100
            if totalPrice != 0.0 {
                return String(format: "$ %.2f", totalVat).replacingOccurrences(of: "-", with: "")
            }
        }
        return "$ 0.0"
        
        
    }
    
    func getDeliveryCharges() -> String {
        if  self.delivery_fee != nil{
            let deliveryFee = self.delivery_fee!.compactMap({$0.deliveryCharges}).reduce(0, +)
            let deliveryFeeWithTax = self.delivery_fee!.compactMap({$0.deliveryChargesTax}).reduce(0, +)
            let totalDeliveryCharge  = (deliveryFee) + (deliveryFeeWithTax)
            if totalDeliveryCharge != 0.0 {
                return String(format: "$ %.2f", totalDeliveryCharge)
            }
        }
        return "$ 0.0"
    }
    
    func getPromocodeValue() -> String {
        
        let actualpriceOfAll = cartItems.map({$0.calculateTotalPriceWithAddUp()})
        if let dis = self.couponDic?.discount{
            let percent = (actualpriceOfAll.reduce(0, +) * (dis) / 100)
            return String(format: "$ %.2f", percent)
        }

        
//        let subTotal = cartItems.compactMap({$0.calculateTotalPrice()}).reduce(0, +)
//        let totalPrice = subTotal + (subTotal * (self.taxPercent ?? 0.0)) / 100
//        let deliveryPrice = self.getDeliveryCharges().replacingOccurrences(of: "$ ", with: "").toDouble()
//        let finalPrice = [totalPrice, (deliveryPrice ?? 0.0)].reduce(0, +)
//        if let dis = self.couponDic?.discount{
//            if self.couponDic?.promotionType == "amount" {
//                return String(format: "$ %.2f", dis)
//            }else{
//                return String(format: "$ %.3f", (finalPrice * (dis)) / 100)
//            }
//        }
        return ""
    }
    
    func getCartTotal() -> (total:String,subtotal:String,isDisCount:Bool){
        
        let discounttype = cartItems.map({$0.dish_id?.discount_type})
        let discountPercent = cartItems.map({$0.dish_id?.discount_type})
        
        
        let actualpriceOfAll = cartItems.map({$0.calculateTotalPriceWithAddUp()})
        let afterDiscount = cartItems.map({$0.calculateTotalPrice()})
        
        
        
        
        
        
        let actualPrice = cartItems.compactMap({$0.calculateTotalPriceWithAddUp()}).reduce(0, +)
        let subTotal = cartItems.compactMap({$0.calculateTotalPrice()}).reduce(0, +)
        var totalPrice = subTotal
        let checkTmpBool = cartItems.compactMap({$0.checkVatApplyOrNot()}).first
        let tax = self.getVat()
        totalPrice = totalPrice + (tax.replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0)

        let deliveryPrice = self.getDeliveryCharges().replacingOccurrences(of: "$ ", with: "").toDouble()
        var finalPrice = [totalPrice, (deliveryPrice ?? 0.0)].reduce(0, +)
        if let dis = self.couponDic?.discount{
            if self.couponDic?.promotionType == "amount" {
                finalPrice = actualpriceOfAll.reduce(0, +) - dis + (tax.replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0)
                finalPrice = finalPrice + (deliveryPrice  ?? 0.0)
            }else{
                finalPrice = actualpriceOfAll.reduce(0, +) - (actualpriceOfAll.reduce(0, +) * (dis) / 100) + (tax.replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0)
                finalPrice = finalPrice + (deliveryPrice  ?? 0.0)
            }
            let total = String(format: "$ %.2f", finalPrice)
            let subtotal =  String(format: "$ %.2f", actualpriceOfAll.reduce(0, +))
            return (total:total,subtotal:subtotal,isDisCount:true)
        }
        if finalPrice != 0.0 {
           let total =  String(format: "$ %.2f", finalPrice)
            return (total:total,subtotal:"",isDisCount:false)
        }
        return (total:" ",subtotal:"",isDisCount:false)
    }

}

class DeliveryData : BaseData{
    var deliveryChargesTax: Double?
    var deliveryCharges: Double?
    var restauranDic : RestaurantProfileData?
    
    override func mapping(map: Map) {

        deliveryChargesTax <- map["delivery_charges_tax"]
        deliveryCharges <- map["delivery_charges"]
        restauranDic <- map["restaurant_id"]
    }
}

class CouponData : BaseData{
    var couponDic: CouponDic?
    
    override func mapping(map: Map) {
        couponDic <- map["coupon"]
    }
}

class CouponDic : BaseData{
    var v : Int?
    var cid : Int?
    var couponSpecific : String?
    var createdAt : String?
    var discount : Double?
    var expireDate : String?
    var generateCode : String?
    var promotionType : String?
    var restaurantId : String?
    var startDate : String?
    var status : String?
    var type : String?
    var updatedAt : String?
    
    override func mapping(map: Map) {

        v <- map["__v"]
        cid <- map["_id"]
        couponSpecific <- map["coupon_specific"]
        createdAt <- map["created_at"]
        discount <- map["discount"]
        expireDate <- map["expire_date"]
        generateCode <- map["generate_code"]
        promotionType <- map["promotion_type"]
        restaurantId <- map["restaurant_id"]
        startDate <- map["start_date"]
        status <- map["status"]
        type <- map["type"]
        updatedAt <- map["updated_at"]
    }
}

class CartItemData : BaseData {
    var order_id : Int?
    var user_id : ProfileData?
    var restaurant_id : RestaurantProfileData?
    var dish_id : ProductData?
    var dish_price : Int?
    var topping_price : Int?
    var quantity : Int?
    var item_total : Double?
    var toppings : [Toppings]?
    var status: String?
   
    var discount_type:String?
    var dish_discount:Double?
    // forUiPrespective
    var hasExpanded = false
    var hasRejecetd = false
    
    

    override func mapping(map: Map) {
        super.mapping(map: map)
        discount_type <- map["discount_type"]
        dish_discount <- map["dish_discount"]
        order_id <- map["order_id"]
        user_id <- map["user_id"]
        restaurant_id <- map["restaurant_id"]
        dish_id <- map["dish_id"]
        dish_price <- map["dish_price"]
        topping_price <- map["topping_price"]
        quantity <- map["quantity"]
        item_total <- map["item_total"]
       
        toppings <- map["toppings"]
        status <- map["status"]
        
        
        #if Restaurant
        setToping()
         #endif
        var status: String?
        status <- map["status"]
        //hasRejecetd =  OrderStatus(rawValue: status!) == .cancel
    }
    
    func calculatePRiceWithTopping() -> Double {
        if let dish = self.dish_id {
            let price = Double((self.dish_price ?? 0) + (self.topping_price ?? 0))
            return (price ?? 0.0) * Double(self.quantity ?? 0)
        }
        return 0.0
    }
    
    
    func calculateTotalPriceWithAddUp() -> Double {
        if let dish = self.dish_id {
            let price = self.toppings?.compactMap({$0.price ?? 0.0}).reduce((dish.getFinalPriceAfterAddUpValue()), +)
            return (price ?? 0.0) * Double(self.quantity ?? 0)
        }
        return 0.0
    }
    
    func calculateTotalPrice(_ isCouponApplied:Bool? = false) -> Double {
        if let dish = self.dish_id {
            let price = self.toppings?.compactMap({$0.price ?? 0.0}).reduce((dish.getFinalPriceAfterDiscount(isCouponApplied)), +)
            return (price ?? 0.0) * Double(self.quantity ?? 0)
        }
        return 0.0
    }

    func getTotalPrice(_ isCouponApplied:Bool? = false) -> String {
        let totalPrice = calculateTotalPrice(isCouponApplied)
        if totalPrice != 0.0 {
            return String(format: "$ %.2f", totalPrice)
        }
        return ""
    }
    
    func checkVatApplyOrNot() -> String {
        return self.restaurant_id!.tax_applicable ?? ""
    }
    
    // for UIPrespective
    #if Restaurant
    private func setToping() {
        if !(self.toppings?.isEmpty ?? true) {
            // run loop for each element in topping array
            self.toppings?.forEach({ (t) in
                // run the loop for each availble option
                
                self.dish_id?.productOption?.forEach({ (option) in
                    // if the topping is selcted topping then make it isSelected true
                    option.toppings?.forEach({ (topping) in
                        // detec
                        if !topping.isSelected {
                            topping.isSelected = (t.id == topping.id)
                        }
                    })
                    
                })
            })
        }
    }
    #elseif User
    private func setToping() {
    if !(self.toppings?.isEmpty ?? true) {
        // run loop for each element in topping array
        self.toppings?.forEach({ (t) in
            // run the loop for each availble option
            
            self.dish_id?.options?.forEach({ (option) in
                // if the topping is selcted topping then make it isSelected true
                option.toppings?.forEach({ (topping) in
                    // detec
                    if !topping.isSelected {
                        topping.isSelected = (t.id == topping.id)
                    }
                })
                
            })
        })
    }
    }
    #endif

}

#if User
enum PaymentMethod: String {
    case cod = "cod"
    case wallet = "wallet"
}
#endif
extension String {
    var digits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
