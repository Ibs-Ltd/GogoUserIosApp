//
//  OrderTrackingViewController.swift
//  User
//
//  Created by Apple on 06/05/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import GoogleMaps
import SDWebImage
class OrderTrackingViewController: BaseViewController<BaseData>, UIScrollViewDelegate {

    @IBOutlet var notificationImg : UIImageView!
    @IBOutlet var cookingImg : UIImageView!
    @IBOutlet var deliveryImg : UIImageView!
    @IBOutlet var homeImg : UIImageView!
    
    @IBOutlet var collectionViewObj : UICollectionView!{
        didSet{
            collectionViewObj.delegate = self
            collectionViewObj.dataSource  = self
        }
    }
    @IBOutlet weak var mapView: GMSMapView!
    private let repo = OrderRepository()
    
    var orderID : String!
    var orderDicObj = OrderData()
    
    // Live Tracking Animation Obj
    var driverOldPosition : CLLocationCoordinate2D!
    var lastBearingValue : Double = 0.0
    var driver_marker = GMSMarker()
    //var end_marker = GMSMarker()
    var polyline = GMSPolyline()
    var animationPolyline = GMSPolyline()
    var path = GMSPath()
    var animationPath = GMSMutablePath()
    
    var pathObj = GMSMutablePath()
    var polylineObj = GMSPolyline()
    var driverImage  = ""
    var profile = CurrentSession.getI().localData.profile

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createNavigationLeftButton(NavigationTitleString.onCooking)
        self.mapView.settings.myLocationButton = false
        self.mapView.isMyLocationEnabled = false
        
        repo.getOrderStatus(self.orderID) { (data) in
            self.orderDicObj = data.orderData ?? OrderData()
            if let driver  = self.orderDicObj.driver_id{
                if let profile = driver.profile_picture {
                    self.driverImage =  profile
                }
            }
            self.setUpOrderDetails()
        }
    }
    
    func updateDriverLocation(data: DriverLiveTrackingData) {
        if self.driverOldPosition == nil{
            return
        }
        let destination = CLLocationCoordinate2D(latitude: data.driver_id?.latitude ?? 0, longitude: data.driver_id?.longitude ?? 0)
        let destinationUser = CLLocationCoordinate2D(latitude: self.orderDicObj.delivery_address?.latitude ?? 0, longitude: self.orderDicObj.delivery_address?.longitude ?? 0)
        
        if self.driverOldPosition.bearing(to: destination) != 0{
            self.lastBearingValue = self.driverOldPosition.bearing(to: destination)
        }
        self.getPolylineRouteForTracking(from: destination, to: destinationUser)
        
        self.driverOldPosition = CLLocationCoordinate2D(latitude: data.driver_id?.latitude ?? 0, longitude: data.driver_id?.longitude ?? 0)
    }
    
    func getPolylineRouteForTracking(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        GoogleSearchAPI.getDirectionInfo(from: source, to: destination) { response in
            let mapResponse = response
            let routesArray = (mapResponse["routes"] as? Array) ?? []
            let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
            let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
            let polypoints = (overviewPolyline["points"] as? String) ?? ""
            let line  = polypoints
            if polypoints != ""{
                self.addPolyLineForTracking(encodedString: line)
            }
        }
    }
    
    func addPolyLineForTracking(encodedString: String) {
        pathObj = GMSMutablePath(fromEncodedPath: encodedString)!
        let coordinate = pathObj.coordinate(at: 0)
        //let coordinateLast = pathObj.coordinate(at: pathObj.count()-1)
        if coordinate.latitude == 0.0{
            return
        }
        //self.end_marker.position = CLLocationCoordinate2DMake(coordinateLast.latitude, coordinateLast.longitude)

        self.driver_marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.driver_marker.rotation = self.lastBearingValue
        
        CATransaction.begin()
        CATransaction.setValue(3.5, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {
            self.driver_marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            self.driver_marker.rotation = self.lastBearingValue
        }
        self.driver_marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        self.driver_marker.map = self.mapView
        CATransaction.commit()
        
        polylineObj.path = pathObj
        polylineObj.strokeWidth = 3
        polylineObj.strokeColor = AppConstant.primaryColor
        polylineObj.map = self.mapView
    }
    
    func setUpOrderDetails() {
        
        
        let camera = GMSCameraPosition.camera(withLatitude: self.orderDicObj.delivery_address?.latitude ?? 0, longitude: self.orderDicObj.delivery_address?.longitude ?? 0, zoom: 16)
        self.mapView.camera = camera
        let userAddress = GMSMarker()
        userAddress.position = CLLocationCoordinate2D(latitude: self.orderDicObj.delivery_address?.latitude ?? 0, longitude: self.orderDicObj.delivery_address?.longitude ?? 0)
        userAddress.title = ""
        userAddress.snippet = ""
        userAddress.map = mapView
       if let profile = profile{
            let image = load(url:  profile.profile_picture ?? "")
            userAddress.iconView = image
        }


        
        if self.orderDicObj.getOrderStatus() == .arrivedToRes || self.orderDicObj.getOrderStatus() == .dispatched || self.orderDicObj.getOrderStatus() == .started{
            self.deliveryImg.image = UIImage(named: "track_bike.png")
            self.createNavigationLeftButton(NavigationTitleString.onDelivery)
            
            driver_marker.position = CLLocationCoordinate2D(latitude: self.orderDicObj.driver_id?.latitude ?? 0, longitude: self.orderDicObj.driver_id?.longitude ?? 0)
            driver_marker.icon = UIImage(named: "track_bike-white.png")
            driver_marker.map = mapView
            
            self.driverOldPosition = CLLocationCoordinate2D(latitude: self.orderDicObj.driver_id?.latitude ?? 0, longitude: self.orderDicObj.driver_id?.longitude ?? 0)
            self.getPolylineRouteForTracking(from: CLLocationCoordinate2DMake(self.orderDicObj.driver_id?.latitude ?? 0, self.orderDicObj.driver_id?.longitude ?? 0), to: CLLocationCoordinate2DMake(self.orderDicObj.delivery_address?.latitude ?? 0 , self.orderDicObj.delivery_address?.longitude ?? 0))
            
//            self.repo.getOrderStatusSocket(self.orderDicObj.driver_id!.id.toString()) { (data) in
//                self.updateDriverLocation(data: data)
//            }
            
        }else if self.orderDicObj.getOrderStatus() == .completed{
            self.deliveryImg.image = UIImage(named: "track_bike.png")
            self.homeImg.image = UIImage(named: "track_home.png")
            self.createNavigationLeftButton(NavigationTitleString.orderComplete)
            
        }else{
            
            guard let restWise = self.orderDicObj.restaurantWise else{return}
            
            if self.orderDicObj.restaurantWise!.indices.contains(0) {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: self.orderDicObj.restaurantWise![0].restaurantId?.latitude ?? 0, longitude: self.orderDicObj.restaurantWise![0].restaurantId?.longitude ?? 0)
                let image = load(url: self.driverImage)
                marker.iconView = image
                userAddress.title = ""
                userAddress.snippet = ""
                marker.map = mapView
            }
            if self.orderDicObj.restaurantWise!.indices.contains(1) {
                let marker2 = GMSMarker()
                marker2.position = CLLocationCoordinate2D(latitude: 23.104610, longitude: 72.546300)
                let image = load(url:  self.driverImage)
                marker2.iconView = image
                marker2.map = mapView
            }
            if self.orderDicObj.restaurantWise!.indices.contains(2) {
                let marker3 = GMSMarker()
                marker3.position = CLLocationCoordinate2D(latitude: 23.099610, longitude: 72.546300)
                let image = load(url:  self.driverImage)
                marker3.iconView = image
                marker3.map = mapView
            }
            
            mapView.drawPolygon(from: CLLocationCoordinate2DMake(self.orderDicObj.delivery_address?.latitude ?? 0 , self.orderDicObj.delivery_address?.longitude ?? 0), to: CLLocationCoordinate2DMake(self.orderDicObj.restaurantWise![0].restaurantId?.latitude ?? 0, self.orderDicObj.restaurantWise![0].restaurantId?.longitude ?? 0))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionViewObj {
            var currentCellOffset = self.collectionViewObj.contentOffset
            currentCellOffset.x += self.collectionViewObj.frame.width / 2
            if let indexPath = self.collectionViewObj.indexPathForItem(at: currentCellOffset) {
              self.collectionViewObj.scrollToItem(at: indexPath, at: .right, animated: true)
            }
        }
    }
    
    func load(url: String) -> UIView? {
        let vw = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        let imagVe = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        vw.addSubview(imagVe)
        vw.layer.cornerRadius = (vw.frame.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        vw.layer.masksToBounds = true

        vw.backgroundColor = .clear
        
        guard let url = URL.init(string: url) else {
            imagVe.image = #imageLiteral(resourceName: "userImage")
            return vw
        }
        
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                imagVe.image = image
            }else{
                imagVe.image = #imageLiteral(resourceName: "userImage")
            }
        }
        return vw
    }
    
//    deinit {
//        repo.disconnectSocket()
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        repo.disconnectSocket()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class RestaurantCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension OrderTrackingViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellObj = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantCollectionCell", for: indexPath) as! RestaurantCollectionCell
        return cellObj
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let collectionViewSize = collectionView.frame.size.width
        return CGSize(width: collectionViewSize, height: 110)
    }
}

private struct MapPath : Decodable{
    var routes : [Route]?
}

private struct Route : Decodable{
    var overview_polyline : OverView?
}

private struct OverView : Decodable {
    var points : String?
}

extension GMSMapView {

    //MARK:- Call API for polygon points

    func drawPolygon(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(AppConstant.googleKey)") else {
            return
        }
        DispatchQueue.main.async {
            session.dataTask(with: url) { (data, response, error) in
                guard data != nil else {
                    return
                }
                do {
                    let route = try JSONDecoder().decode(MapPath.self, from: data!)
                    if let points = route.routes?.first?.overview_polyline?.points {
                        self.drawPath(with: points)
                    }
                    //print(route.routes?.first?.overview_polyline?.points)

                } catch let error {

                    print("Failed to draw ",error.localizedDescription)
                }
                }.resume()
            }
    }

    //MARK:- Draw polygon
    private func drawPath(with points : String){
        DispatchQueue.main.async {
            let path = GMSPath(fromEncodedPath: points)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 3.0
            polyline.strokeColor = AppConstant.primaryColor
            polyline.map = self

        }
    }
}

extension CLLocationCoordinate2D {
    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        print(radiansToDegrees(radiansBearing))
        print("--------------------")
        return radiansToDegrees(radiansBearing)
    }
}

