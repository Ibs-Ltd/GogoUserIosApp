//
//  StoreLocationViewController.swift
//  User
//
//  Created by ItsDp on 27/09/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
class StoreLocationViewController: BaseViewController<StoreInfomationData> {
    
    @IBOutlet weak var mapView: GMSMapView!
    private let locationManager = CLLocationManager()

    
    private lazy var leftImage:UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 32, height: 32)
        imageView.image =  UIImage(named:"backRed")
        let tapGesture = UITapGestureRecognizer.init(target: self, action:#selector(tapOnLeftItem))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    @IBOutlet weak var restroInfoView: UIView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mealTypes: UILabel!
    @IBOutlet weak var cookingTime: UIButton!
    @IBOutlet weak var deliveryItem: UIButton!
    @IBOutlet weak var soldItems: UIButton!
    var zoomLevel : Float = 18

    override func viewDidLoad() {
        super.viewDidLoad()
         setupNavItems()
         transparentNavigationBar()
         setRestaurantInfo()

        // Do any additional setup after loading the view.
    }
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         transparentNavigationBar()
     }
    private func  setupNavItems(){
        let leftButton = UIBarButtonItem.init(customView: leftImage)
        navigationItem.leftBarButtonItem = leftButton
    }
    func setRestaurantInfo() {
        if let profile = self.data?.restaurant {
            restaurantImageView.setImage(profile.profile_picture ?? "")
            name.text = profile.name
            let cookTimeStr = String(format: "  %@", profile.getCookingTime())
            cookingTime.setTitle(cookTimeStr, for: .normal)
            soldItems.setTitle(profile.getTotalSold(), for: .normal)
            cookingTime.setTitle(cookTimeStr, for: .normal)
            mealTypes.text = profile.address ?? ""
            
            let camera = GMSCameraPosition.camera(withLatitude: profile.latitude ?? 0.0, longitude: profile.longitude ?? 0.0, zoom: zoomLevel)
            self.mapView.camera = camera
            self.mapView.settings.myLocationButton = false
            
        }
    }
    @IBAction func zoomButtonClicked(_ sender: UIButton) {
         zoomLevel = zoomLevel + 1
         mapView.animate(toZoom: zoomLevel)
     }
     
     @IBAction func zoomOutButtonClicked(_ sender: UIButton) {
         zoomLevel = zoomLevel - 1
         mapView.animate(toZoom: zoomLevel)
     }
     
     @IBAction func focusonCurrentLocationButtonClicked(_ sender: UIButton) {
         if let profile = self.data?.restaurant {


        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "current_latitude") as? Double ?? 0.0, longitude: UserDefaults.standard.value(forKey: "current_longitude") as? Double ?? 0.0)))
        source.name = "Current addrees"

        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: profile.latitude ?? 0.0, longitude: profile.longitude ?? 0.0)))
        destination.name = profile.name

        MKMapItem.openMaps(with: [source, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }

     }
     
    
}
