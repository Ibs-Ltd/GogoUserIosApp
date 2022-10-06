//
//  BaseRepository.swift
//  globalCart
//
//  Created by admni on 20/03/19.
//  Copyright © 2019 Crinoid. All rights reserved.
//

import Foundation
import SVProgressHUD
import ObjectMapper
import Alamofire
import MBProgressHUD
import CoreLocation
import SocketIO

class BaseRepository {
    
    private var socket: SocketIOClient!
    private var manager: SocketManager!
    
    
    let header: HTTPHeaders =  ["token": CurrentSession.getI().localData.token ?? ""]

    
    //let header: HTTPHeaders = ["token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7InJlc3RhdXJhbnRfbmFtZSI6Ik5lbmRh4oCZcyBLaXRjaGVuIiwibW9iaWxlIjoiNzA2NTc3NzA3NSIsIm1vYmlsZTEiOiI3MDY1NyA3NzAiLCJlbWFpbCI6Im5hbmRhQGdtYWlsLmNvbSIsIm90cCI6bnVsbCwiaW1hZ2UiOiJodHRwczovL2dvZ28tZm9vZC5zMy5hcC1zb3V0aGVhc3QtMS5hbWF6b25hd3MuY29tLzE1ODQ3MDIzODM1MDktNURDQkVGMEUtQUREOC00N0I1LTkzQ0MtQTAwRDI3OTlDQkY5LmpwZyIsImF2Z19yYXRpbmciOjAsImxvbmdpdHVkZSI6NzYuODU0NDU2NzM3NjM3NTIsImxhdGl0dWRlIjozMC42Nzg5NDg0NDc1ODMzNjYsImFkZHJlc3MiOiIzODMsIFNlY3RvciAxMiBSZCwgUmFpbGxhLCBTZWN0b3IgMTIsIFBhbmNoa3VsYSwgSGFyeWFuYSAxMzQxMTIsIEluZGlhIiwiY2l0eSI6IlBhbmNoa3VsYSIsImFkZHVwX3ZhbHVlIjowLCJzdGF0ZSI6IkhhcnlhbmEiLCJkZWxpdmVyeV90eXBlIjoiZnJlZSIsIm1lbWJlcl90eXBlIjpudWxsLCJiaWxsaW5nX3BsYW4iOm51bGwsImVzdF9jb29raW5nX3RpbWUiOiIxOCIsImVzdF9kZWxpdmVyeV90aW1lIjoiMjgiLCJiaWxsaW5nX2Rlc2NyaXB0aW9uIjpudWxsLCJ0b3RhbF9vcmRlcnMiOjAsImRlZmF1bHRfbGFuZ3VhZ2UiOiJlbiIsInJlc3RhdXJhbnRfc3RhdHVzIjoiNCIsIl9pZCI6NTcsImNyZWF0ZWRfYXQiOiIyMDIwLTAzLTIwVDEwOjM0OjAwLjg2OVoiLCJ1cGRhdGVkX2F0IjoiMjAyMC0wMy0yMFQxMDozNDowMC44NjlaIiwiX192IjowfSwiaWF0IjoxNTg0NzA5MDQ1LCJleHAiOjE2MTYyNDUwNDV9.kMymwarWzD4u18RvOwAimRPJ8yWM4MO835jNK3MJ6Vo"]
    
    let progress = SVProgressHUD()
    var hud: MBProgressHUD!
    
    static let shared = BaseRepository()
    
    
    
    
    typealias responseObject<T: BaseData> =  (_ item: T) -> Void
    typealias responseList<T: BaseData> = (_ item: [T]) -> Void
    typealias emptyResponse = () -> Void
    func showLoader(_ withTitle: String?) {
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            hud = MBProgressHUD.showAdded(to: topController.view, animated: true)
            hud.contentColor = AppConstant.primaryColor
            hud.bezelView.color = UIColor.clear
            hud.bezelView.style = .solidColor
            hud.animationType = .zoomIn
        //    hud.offset = CGPoint(x: 0, y: topController.view.bounds.height)
            hud.sizeThatFits(CGSize(width: 200, height: 200))
            hud.center = topController.view.center
            
            // topController should now be your topmost view controller
        }
        
        //        SVProgressHUD.setRingRadius(10)
        //        SVProgressHUD.setRingThickness(3)
        //        SVProgressHUD.setBackgroundColor(UIColor.clear)
        //        SVProgressHUD.setForegroundColor(AppConstant.primaryColor)
        //        SVProgressHUD.show()
        
    }
    
    func getLocationHeader() -> HTTPHeaders {
        if CLLocationManager.locationServicesEnabled() {
            //MARK:- for testing using static location :- 30.3299 , 76.8712
            
//            let latObj = "17.3850"
//            let lngObj =  "78.4867"

        
            let latObj = String(format: "%.10f", UserDefaults.standard.value(forKey: "current_latitude") as? Double ?? "23")
            let lngObj = String(format: "%.10f", UserDefaults.standard.value(forKey: "current_longitude") as? Double ?? "72")
            let Locationheader: HTTPHeaders =  ["latitude": latObj, "longitude": lngObj, "lang": "en", "token": CurrentSession.getI().localData.token ?? ""]
            return Locationheader
        }else{
            let header: HTTPHeaders =  ["token": CurrentSession.getI().localData.token ?? ""]
            return header
        }
    }
    
    func dismiss() {
        if let _ = self.hud {
            hud.hide(animated: true)
        }
    }
    
    
    
    func showError(_ withMessage: String?) {
        let alert  = UIAlertController(title: "Info", message: withMessage ?? "Unable to fetch data this time", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
            // topController should now be your topmost view controller
        }
        
    }
    
    
    
    
    
    func getDataFrom<T>(_ serverResponse: DataResponse<String>) -> T? where T: BaseData{
        DispatchQueue.main.async {
            self.dismiss()
        }
        guard let value = serverResponse.value else{
            //            showError("Something went wrong")
            return nil
        }

        guard  let responseData = Mapper<BaseObjectResponse<T>>().map(JSONString: value) else {
            return nil
        }
        if responseData.success {
            return responseData.data
        }else if responseData.status {
            return responseData.data
        }else{
            showError(responseData.message)
        }
        return nil
    }
    
    
    func getDataFromString<T>(_ serverResponse: String, showSuccess: ((_ message: String) -> Void)?) -> T? where T: BaseData{
        dismiss()
        guard  let responseData = Mapper<BaseObjectResponse<T>>().map(JSONString: serverResponse) else {
            return nil
        }
        if !responseData.success {
            showError(responseData.message)
            return nil
        }
        if responseData.success {
            //            if let c = showSuccess{
            //                c(responseData.message)
            //            }
            
            return responseData.data
        }
        
        return nil
    }
    
    func getDataFromSocketData<T>(_ socketResponse: Any?) -> T? where T: BaseData{
        dismiss()
        guard  let responseData = Mapper<BaseObjectResponse<T>>().map(JSONObject: socketResponse) else {
            return nil
        }
//        if let c = showSuccess{
//            c(responseData.message)
//        }
        return responseData.data
          
    }
    
    
    func connectSocket(_ withKey: String, params: [String: Any], onResponse: @escaping ((_ data: Any)-> Void)){
        manager = SocketManager(socketURL: URL(string: ServerUrl.socketBaseUrl)!,
                                config: [.log(true),
                                         .reconnects(true),
                                         //.path("/user_single_restaurant"),
                                        .reconnectAttempts(-1),
                                        .reconnectWait(1),
                                        .connectParams(params),
            ])
        
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) { (data, ack) in
            print("socket connected")
        }
        socket.on(withKey) { (data, ack) in
            onResponse(data.first as Any)
        }
        socket.connect()
    }
    
    
    func disconnectSocket() {
        if (self.socket != nil){
            self.socket.disconnect()
        }
    }
}





open class Spinner {
    
    internal static var spinner: UIActivityIndicatorView?
    public static var style: UIActivityIndicatorView.Style = .whiteLarge
    public static var baseBackColor = UIColor.black.withAlphaComponent(0.5)
    public static var baseColor = UIColor.red
    
    public static func start(style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        if spinner == nil, let window = UIApplication.shared.keyWindow {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = baseColor
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
    
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
    
    @objc public static func update() {
        if spinner != nil {
            stop()
            start()
        }
    }
}
