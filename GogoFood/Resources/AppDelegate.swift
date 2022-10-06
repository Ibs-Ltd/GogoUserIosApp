//
//  AppDelegate.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 07/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import CoreLocation
import Reachability
import IQKeyboardManagerSwift
import GoogleMaps
import UserNotifications
import Firebase
import FacebookCore
import Branch
import Localize_Swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    let reachability = Reachability()
    var locationManager: CLLocationManager = CLLocationManager()
    private let repo = MapRepository()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.updateUserCurrentLocation()
        
        GMSServices.provideAPIKey(AppConstant.googleKey)
        UIBarButtonItem.appearance().tintColor = AppConstant.appGrayColor
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        IQKeyboardManager.shared.enable = true
        getSavedLanguagePreference()
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().delegate = self
        registerForPushNotifications()
        #if User
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        #endif
    
        
        fetchDeepLinkData(launchOptions ?? [:])

        // Override point for customization after application launch.
         
         // When the app launch after user tap on notification (originally was not running / not in background)
         if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
             // your code here
         }
        
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }
    

    func fetchDeepLinkData(_ launchOptions :[UIApplication.LaunchOptionsKey: Any])  {
        let branch: Branch = Branch.getInstance()
        
        let sessionParams = Branch.getInstance().getLatestReferringParams()

        
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            guard let dict = params as? [String:Any] else {return}
            for value in dict.enumerated(){
                if  value.element.key == "referalcode"{
                    let userDefaults = UserDefaults.standard
                    let code  = value.element.value
                    userDefaults.setValue(code, forKey: "referalcode")
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Authentication", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "inital")
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.window?.makeKeyAndVisible()
                }
            }
            
            
            guard let productStr = dict["productID"] as? String ,let productID = Int(productStr),let restuarentStr = dict["restuarentID"] as? String,let restuarentID = Int(restuarentStr) else{return}
            

            let sb = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil)
            let foodDetail = sb.instantiateViewController(withIdentifier: Controller.foodDetail.rawValue) as! FoodDetailViewController
            foodDetail.isFromPush = true
            let p = ProductData()
            p.id = productID
            p.restaurant_id?.id = restuarentID
            foodDetail.data = p
            let rootNC = UINavigationController(rootViewController: foodDetail)
            UIApplication.shared.keyWindow?.rootViewController = rootNC
            self.window?.makeKeyAndVisible()
            
            
        })
    }
    
    
    private func getSavedLanguagePreference(){
        if let lang = UserDefaults.standard.value(forKey: "savedLang") as? String{
            Localize.setCurrentLanguage(lang)
        }else{
            Localize.setCurrentLanguage("en")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("2")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("1")
    }
    
    func setFireBaseDelegate() {
        if let fcmToken = InstanceID.instanceID().token() {
            print("Token : \(fcmToken)");
            CurrentSession.getI().localData.fireBaseToken = fcmToken
        } else {
            print("Error: unable to fetch token");
        }
        Messaging.messaging().shouldEstablishDirectChannel = true
    }
    
    #if User
    func updateUserCurrentLocation() {
        // Location Manager Start
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        // Location Manager End
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation = locations.last! as CLLocation
        print("-----> %.4f",latestLocation.coordinate.latitude)
        print("-----> %.4f",latestLocation.coordinate.longitude)
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(latestLocation.coordinate.latitude, forKey: "current_latitude")
        userDefaults.setValue(latestLocation.coordinate.longitude, forKey: "current_longitude")

        //userDefaults.setValue(11.5793812, forKey: "current_latitude")
        //userDefaults.setValue(104.8875465, forKey: "current_longitude")
        
//        userDefaults.setValue(48.234690, forKey: "current_latitude")
//        userDefaults.setValue(13.606230, forKey: "current_longitude")


//        userDefaults.setValue(30.676910, forKey: "current_latitude")
//        userDefaults.setValue(76.848960, forKey: "current_longitude")

//        userDefaults.setValue(23.1013, forKey: "current_latitude")
//        userDefaults.setValue(72.5407, forKey: "current_longitude")
        
        userDefaults.synchronize()
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
    #endif
    
  
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                granted, error in
                print("Permission granted: \(granted)") // 3
        }
        self.getNotificationSettings()
    }

    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        }
    }

    
    class func sharedAppDelegate() -> AppDelegate?
    {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Process notification content
        let userInfo = notification.request.content.userInfo as? [String:Any]
        if let type = userInfo?["gcm.notification.type"] as? String{
            if type == "comment"{
                NotificationCenter.default.post(name: .dishCommnets, object: nil, userInfo: userInfo)
            }else{
                NotificationCenter.default.post(name: .newOrders, object: nil, userInfo: userInfo)
            }
        }
        completionHandler([.alert, .sound]) // Display notification Banner
    }
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //OnTap Notification
        let userInfo = response.notification.request.content.userInfo as? [String:Any]
        if let type = userInfo?["gcm.notification.type"] as? String,let id = userInfo?["gcm.notification.dish_id"] as? String,let IDInt = Int(id){
            if type == "comment"{
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as? FeedDetailViewController
                vc?.isFromPush = true
                let rootNC = UINavigationController(rootViewController: vc!)
                vc?.noti.isFromNoti = true
                vc?.noti.dishID = IDInt
                window?.rootViewController = rootNC
                self.window?.makeKeyAndVisible()
            }else{
                NotificationCenter.default.post(name: .newOrders, object: nil, userInfo: userInfo)
            }
        }
     
        //        let TestVC = MainStoryboard.instantiateViewController(withIdentifier: "FeedDetailViewController") as! TestVC
        //        TestVC.chapterId = dict["chapter_id"] as? String ?? ""
        //        TestVC.strSubTitle = dict["chapter"] as? String ?? ""
        //        self.navigationC?.isNavigationBarHidden = true
        //        self.navigationC?.pushViewController(TestVC, animated: true)
        completionHandler() // Display notification Banner
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        CurrentSession.getI().localData.fireBaseToken = fcmToken
       
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

extension Notification.Name {
    public static let dishCommnets = Notification.Name(rawValue: "dishComments")
    public static let newOrders = Notification.Name(rawValue: "newOrders")
}

