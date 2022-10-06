//
//  ServerUrl.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 11/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import Foundation

struct ServerUrl {
    
   // static let baseUrl = "https://gogofoodapp.com/api/"
    //static let baseUrl = "http://gogofoodapp.com:4000/"
     static let baseUrl = "https://dev.gogofoodapp.com/devapi/"
    //static let socketBaseUrl = "https://dev.gogofoodapp.com"
        static let socketBaseUrl = "https://admin.gogofoodapp.com"

    
    #if User
    static let appUrl = ServerUrl.baseUrl + "user/"
    #elseif Restaurant
    static let appUrl = ServerUrl.baseUrl + "restaurant/"
    #elseif Driver
    static let appUrl = ServerUrl.baseUrl + "driver/"
    #endif
    
    
    // Authentication
    static let signUpUrl = ServerUrl.appUrl + "signup"
    static let verifyOTPUrl = ServerUrl.appUrl + "verify/otp"
    static let logoutUrl = ServerUrl.appUrl + "logout"
    
    // Home
    
    #if User
    static let userdashboard = ServerUrl.appUrl + "dashboard/"
    static let homeUrl =  ServerUrl.userdashboard + "all/data"
    
    static let storeInfomationUrl = ServerUrl.userdashboard + "single/restaurant"
    static let topRestaurantUrl = ServerUrl.userdashboard + "top/restaurants"
    static let allRestaurantsUrl = ServerUrl.userdashboard + "all/restaurants"
    static let catgeoryWiseProductUrl = ServerUrl.userdashboard + "category/wise/products"
    static let checkoutUrl = ServerUrl.userdashboard + "checkout"
    static let addToCartUrl = ServerUrl.userdashboard + "add/to/cart"
    static let increaseQuantity = ServerUrl.userdashboard + "increase/quantity"
    static let decreaseQuantity = ServerUrl.userdashboard + "decrease/quantity"
    static let updateTopingUrl = ServerUrl.userdashboard + "update/toppings"
    static let viewCartUrl = ServerUrl.userdashboard + "view/cart"
    static let decreaseDishUrl = ServerUrl.userdashboard + "decrease/dish"
    static let singleDishUrl = ServerUrl.userdashboard + "single/dish"
    static let cancelOrder = ServerUrl.userdashboard + "cancel-order"
    static let favProductUrl = ServerUrl.userdashboard + "favourite/product"
    static let likeProductUrl = ServerUrl.userdashboard + "like/product"
    
    static let updateAddressUrl = ServerUrl.userdashboard + "update/address"
    static let applyCoupon = ServerUrl.userdashboard + "apply/coupon"
    static let removeCoupon = ServerUrl.userdashboard + "remove/promocode"
    static let orderHistoryUrl = ServerUrl.userdashboard + "order/history"
    static let rateDriverUrl = ServerUrl.userdashboard + "rate/driver"
    static let confirmRecievedUrl = ServerUrl.userdashboard + "confirm/recieved"
    static let scanQrCode = ServerUrl.userdashboard + "scan/code"

    static let transferBalanceUrl = ServerUrl.userdashboard + "transfer/balance"
    static let referalDetailsUrl = ServerUrl.userdashboard + "referal/income/details"
    static let levelWiseUserUrl = ServerUrl.userdashboard + "level/wise/user"
    static let checkLocationURL = ServerUrl.userdashboard + "check/location"
    static let notificationsURL = ServerUrl.userdashboard + "notifications"
    static let favoritesUrl = ServerUrl.userdashboard + "favorites"
    
    static let getCommentListUrl = ServerUrl.userdashboard + "get/comments"
    static let walletHistoryUrl = ServerUrl.userdashboard + "wallet/history"
    static let addCommentUrl = ServerUrl.userdashboard + "add/comment"
    static let editCommentUrl = ServerUrl.userdashboard + "edit/comment"
    static let removeCommentUrl = ServerUrl.userdashboard + "remove/comment"
    static let rateDishUrl = ServerUrl.userdashboard + "rate/dish"
    static let skipRatingUrl = ServerUrl.userdashboard + "skip/rating"
    static let searchItemUrl = ServerUrl.userdashboard + "search/item"
    
    static let orderDetailUrl = ServerUrl.userdashboard + "order/detail"
    static let allRecommendedUrl = ServerUrl.userdashboard + "all/recommended"
    static let allTopUrl = ServerUrl.userdashboard + "all/top/ordered"
    
    #endif
    
    
    
    // order related
    #if Restaurant
    static let liveOrderUrl = ServerUrl.appUrl + "get/new-order"
    static let removeItemUrl = ServerUrl.appUrl + "remove-item"
    static let confirmPayment = ServerUrl.appUrl + "confirm-payment"
    #endif
    
    
    
    
    //Setting repository
    #if User
    static let updateProfileUrl = ServerUrl.appUrl + "edit/profile"
    #elseif Restaurant
    static let updateProfileUrl = ServerUrl.appUrl + "update/profile"
    #elseif Driver
    static let updateProfileUrl = ServerUrl.appUrl + "edit/profile"
    #endif
    
    #if Restaurant
    static let restaurantTimmingUrl = ServerUrl.appUrl + "add/timing"
    static let getRestaurantTimmingUrl = ServerUrl.appUrl + "get/timing"
    static let updateAddressUrl = ServerUrl.appUrl + "update/address"
    static let addCategoryUrl = ServerUrl.appUrl + "add/category"
    static let updateCategoryUrl = ServerUrl.appUrl + "update/category"
    static let categoryUrl = ServerUrl.appUrl + "category"
    
    static let productUrl = ServerUrl.appUrl + "product"
    static let addProductUrl = ServerUrl.appUrl + "add/product"
    static let updateProductUrl = ServerUrl.appUrl + "update/product"
    static let setProductStatus = ServerUrl.appUrl + "product/update/status"
    static let toppingOptionsUrl = ServerUrl.appUrl + "get/options"
    
    static let rejectOrderUrl = ServerUrl.appUrl + "cancel-order"
    static let orderHistoryUrl = ServerUrl.appUrl + "order-history"
    static let todayOrderUrl = ServerUrl.appUrl + "today-order"
    static let acceptOrderUrl = ServerUrl.appUrl + "accept-order"
    #endif
    
    
    
    #if Driver
    static let acceptOrderUrl = ServerUrl.appUrl + "accept/order"
    static let onGoingOrderUrl = ServerUrl.appUrl + "home/data"
    static let changeStatusUrl = ServerUrl.appUrl + "change/status"
    static let confirmPickupUrl = ServerUrl.appUrl + "confirm/pickup"
    static let restaurantOrderDetailsUrl = ServerUrl.appUrl + "restaurant/order/details"
    static let updateAddressUrl = ServerUrl.appUrl + "update/current/location"
    #endif
    
    
    
    
}

