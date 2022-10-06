//
//  DeliveryDetailTableViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 04/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import CoreLocation

class DeliveryDetailTableViewCell: BaseTableViewCell<CartData> {

    
    @IBOutlet weak var deliveryDetailTitleLbl: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var arrowImage: UIButton!
    var cartItems: [[CartItemData]] = []
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
    }

    override func initView(withData: CartData) {
         deliveryDetailTitleLbl.text = "Delivery Detail".localized()
        if let _ = CurrentSession.getI().localData.profile.default_address {
            
            var distance = [String]()
            self.addressLabel.text = CurrentSession.getI().localData.profile.default_address!.address
            let coordinate₀ = CLLocation(latitude: CurrentSession.getI().localData.profile.default_address!.latitude ?? 0, longitude: CurrentSession.getI().localData.profile.default_address!.longitude ?? 0)
            
            for value in cartItems {
                let coordinate₁ = CLLocation(latitude: value.first?.restaurant_id?.latitude ?? 0, longitude: value.first?.restaurant_id?.longitude ?? 0)
                let distanceInMeters = coordinate₀.distance(from: coordinate₁)/1000
                let distnace = String(format: "%.2fkm",distanceInMeters)
                distance.append(distnace)
            }
            self.distanceLabel.text =  distance.joined(separator: "\n")
        }else{
            self.addressLabel.text = "Address not added"
        }
        self.priceLabel.isHidden = true
        self.itemLabel.text = withData.cartItems.compactMap({$0.restaurant_id?.name}).uniques.joined(separator: "\n")
    }
    
//    override func initView(withData: CartData) {
//        if let _ = CurrentSession.getI().localData.profile.default_address {
//
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
