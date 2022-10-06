//
//  UIVIewExtension.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 12/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import SDWebImage
import MapKit
extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            
            return nil
        }
        
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadows()
            }
        }
    }
    
    @IBInspectable var addBottomShadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadows(shadowOffset: CGSize(width: 0, height: 2), shadowOpacity: 0.2, shadowRadius: 4)
            }
        }
    }
    
    @IBInspectable var addThreeSideShadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadows(shadowOffset: CGSize(width: 0, height: 2), shadowOpacity: 0.2, shadowRadius: 4)
            }
        }
    }
    
    func addShadows(shadowColor: CGColor = UIColor.black.cgColor,
                    shadowOffset: CGSize = CGSize(width: 0, height: 0),
                    shadowOpacity: Float = 0.5,
                    shadowRadius: CGFloat = 1) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        //        addshadow(top: false, left: true, bottom: true, right: true, shadowRadius: 2)
    }
    
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 2.0) {
        
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
    
}

extension UIImageView{
    
    func setImage(_ url:String){
        let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let imageURL = URL(string: urlString ?? "")
        self.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: ""))
    }
}
extension CLLocation {
func fetchAddress(completion: @escaping (_ address: String?, _ error: Error?) -> ()) {
    CLGeocoder().reverseGeocodeLocation(self) {
        let palcemark = $0?.first
        var address = ""
        if let subThoroughfare = palcemark?.subThoroughfare {
            address = address + subThoroughfare + ","
        }
        if let thoroughfare = palcemark?.thoroughfare {
            address = address + thoroughfare + ","
        }
        if let locality = palcemark?.locality {
            address = address + locality + ","
        }
        if let subLocality = palcemark?.subLocality {
            address = address + subLocality + ","
        }
        if let administrativeArea = palcemark?.administrativeArea {
            address = address + administrativeArea + " \n "
        }
        if let postalCode = palcemark?.postalCode {
            address = address + postalCode + ","
        }
        if let country = palcemark?.country {
            address = address + country + ","
        }
        if address.last == "," {
            address = String(address.dropLast())
        }
        completion(address.capitalized,$1)
       // completion("\($0?.first?.subThoroughfare ?? ""), \($0?.first?.thoroughfare ?? ""), \($0?.first?.locality ?? ""), \($0?.first?.subLocality ?? ""), \($0?.first?.administrativeArea ?? ""), \($0?.first?.postalCode ?? ""), \($0?.first?.country ?? "")",$1)
    }
    }
    
}
