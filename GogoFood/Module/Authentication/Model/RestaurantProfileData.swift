/* 
Copyright (c) 2020 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

class RestaurantProfileData : ProfileData {
	
    var add_up_value : Int?
	var address : String?
	var city : String?
	var state : String?
	var member_type : String?
	var billing_plan_id : String?
    var tax_applicable : String?
	private var est_cooking_time : String?
	private var est_delivery_time : String?
    private var total_orders: Int?
	var description : String?
	private var restaurant_status : String?
    var restaurantTime: [RestaurantParticularDayTime] = []
	override func mapping(map: Map) {
        super.mapping(map: map)
        
		name <- map["restaurant_name"]
        tax_applicable <- map["tax_applicable"]

		mobile <- map["mobile"]
		mobile1 <- map["mobile1"]
		email <- map["email"]
		otp <- map["otp"]
		profile_picture <- map["image"]
		device_token <- map["device_token"]
		avg_rating <- map["avg_rating"]
		longitude <- map["longitude"]
		latitude <- map["latitude"]
		address <- map["address"]
        add_up_value <- map["addup_value"]
		city <- map["city"]
		state <- map["state"]
		member_type <- map["member_type"]
		billing_plan_id <- map["billing_plan_id"]
        tax_applicable <- map["tax_applicable"]
		est_cooking_time <- map["est_cooking_time"]
		est_delivery_time <- map["est_delivery_time"]
		description <- map["description"]
		default_language <- map["default_language"]
		restaurant_status <- map["restaurant_status"]
        total_orders <- map["total_orders"]
		
		
        userStatus = UserStatus(rawValue: self.restaurant_status ?? "")
        restaurantTime <- map["restaurantTimings"]
        
        
	}

    
    func getCookingTime() -> String {
        return (self.est_cooking_time ?? "") + " " + "mn".localized()
    }
    
    func getDeliveryTime() -> String {
        return (self.est_delivery_time ?? "") + " " + "mn".localized()
    }
  
    override func getCompleteAddress(secure: Bool) -> String {
         return (self.address ?? "") + " " + (self.city ?? "")
    }
    
   
    
   
    func getTotalSold() -> String {
        if (self.total_orders ?? 0) != 0 {
            return "\("Sold".localized()): \(self.total_orders ?? 0)"
        }
        
        return ""
    }
    
}
