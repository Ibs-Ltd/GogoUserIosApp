//
//  DriverMapViewController.swift
//  Restaurant
//
//  Created by MAC on 04/04/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import GoogleMaps

class DriverMapViewController: BaseViewController<OrderData> {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var orderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonViewHeightConstraint: NSLayoutConstraint!
    private let repo = OrderRepository()
    private var orderDetail: OrderDetailData!
    
    @IBOutlet weak var arriveButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mapVIew: GMSMapView!
    // regarding the order
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoneNumer: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var deliveryFee: UILabel!
    @IBOutlet weak var paymentMethod: UILabel!
    @IBOutlet weak var userAdress: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        createNavigationLeftButton(nil)
        self.setOrderView(self.data!)
        // Do any additional setup after loading the view.
    }
    
    func setOrderView(_ orderData: OrderData) {
        let userData = orderData.order_id?.user_id
        ServerImageFetcher.i.loadProfileImageIn(userImage, url: userData?.getProfileImagerUrl() ?? "")
        userName.text = userData?.name?.capitalized
        userPhoneNumer.text = userData?.getPhoneNumber(secure: false)
        self.userAdress.text = userData?.getCompleteAddress(secure: false)
        let order = orderData.order_id
        totalPrice.text = "Total Price :" + (order?.getOrderTotal() ?? "")
        deliveryFee.text = "Delivery Fee :" + (order?.getDeliveryFee() ?? "")
        paymentMethod.text = "Payment : " + (order?.getPaymentMethodType() ?? "")
        self.collectionView.reloadData()
        setUserLocation()
        
    }
    
    
    
    func setUserLocation() {
        self.mapVIew.mapType = .normal
        let marker = GMSMarker()
        let corrdinate = CurrentSession.getI().localData.profile.location?.coordinates
        let long = CLLocationCoordinate2DMake((corrdinate?.first ?? 0.0), (corrdinate?.last ?? 0.0))
        
        
        marker.position = long
        marker.map = mapVIew
        mapVIew.moveCamera(GMSCameraUpdate.setTarget(long, zoom: 12))
        self.mapVIew.isMyLocationEnabled = true
        
        
        
    }
    
    
    
    
    
    @IBAction func onReviewOrder(_ sender: UIButton) {
        // sender.tag == 0 for accept
        repo.confirmPickup(order: OrderData()) {
            UIView.animate(withDuration: 0.1, animations: {
                self.orderViewHeightConstraint.constant = 230
                self.buttonViewHeightConstraint.constant = 0
                self.arriveButtonHeight.constant = 50
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @IBAction func tapOnCallButton(_ sender: UIButton) {
        self.showAlert(msg: "call will Intiated")
        
    }
    

   

}

extension DriverMapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.order_id?.restaurant_wise?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DriverRestaurantCollectionViewCell
        let restaurant = self.data?.order_id?.restaurant_wise?[indexPath.row]
       
            cell.name.text = "\(restaurant?.restaurant_id?.name?.capitalized ?? "") || \(restaurant?.restaurant_id?.mobile ?? "")"
            cell.address.text = restaurant?.restaurant_id?.getCompleteAddress(secure: false)
        let marker = GMSMarker()
        marker.icon = UIImage(named: "Group 409")
    
//        let lat: Double = restaurant?.restaurant_id?.latitude  ?? 0.0
//        let lng: Double = restaurant?.restaurant_id?.longitude  ?? 0.0
        
        
//        marker.position = CLLocationCoordinate2DMake(lat,lng)
        marker.title = restaurant?.restaurant_id?.name?.capitalized
        marker.map = mapVIew
            ServerImageFetcher.i.loadProfileImageIn(cell.restaurantImage, url: restaurant?.restaurant_id?.getProfileImagerUrl() ?? "")
        
    return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc: DriverOrderViewController = self.getViewController(.driverOrder, on: .order)
        let order = self.data?.order_id?.restaurant_wise?[indexPath.row]
        let orderData = self.data
        orderData?.order_id?.restaurant_wise?.removeAll()
        orderData?.order_id?.restaurant_wise?.append(order!)
        vc.data = orderData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
    
    
    
}




class DriverRestaurantCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    
    
}
