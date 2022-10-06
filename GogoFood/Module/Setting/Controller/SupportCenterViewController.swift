//
//  SupportCenterViewController.swift
//  User
//
//  Created by YOGESH BANSAL on 11/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit

class SupportCenterViewController: BaseViewController<BaseData> {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var setViewForRestaurant = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewOutlet.dropShadow(scale: true)
        self.createNavigationLeftButton(NavigationTitleString.supportCenter.localized())
        
        if setViewForRestaurant {
            image.image = UIImage(named: setViewForRestaurant
                ? "supportCenter"
                : "supportCenter")
            
        }
        infoLabel.text  = "If you have any question or something you can tell, please contact to support center.".localized()
        infoLabel.isHidden = !setViewForRestaurant
        
    }
    
    @IBAction func onActionMail(_ sender: Any) {
        let email = "support@gogoeats.com"
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    @IBAction func onActionCall(_ sender: UIButton) {
        callNumber(phoneNumber: sender.titleLabel?.text?.replacingOccurrences(of: " ", with: "") ?? "")
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    private func callNumber(phoneNumber:String) {

        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
        }
    }
    
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
