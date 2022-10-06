//
//  RestrauntCollectionViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 11/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit

class RestrauntCollectionViewCell: BaseCollectionViewCell<RestaurantProfileData> {
    @IBOutlet weak var img_freedelivery: UIImageView!
    
    @IBOutlet weak var freeDeliveryLbl: UILabel!
    @IBOutlet weak var rateLbl: UILabel!
    @IBOutlet weak var soldBtn: UIButton!
    @IBOutlet weak var deliveryBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    
    @IBOutlet weak var lbl_desc: UILabel!

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()        
       
    }
    
    func initView(withData: RestaurantProfileData) {
        
        DispatchQueue.main.async {
            
            self.lbl_desc.text = withData.description ?? ""
            self.img_freedelivery.isHidden = withData.deliveryType == "free" ? false:true
            self.restaurantName.text = withData.name?.capitalized ?? ""
            //self.time.text = withData.getCookingTime()
            self.timeBtn.setTitle(withData.getCookingTime(), for: .normal)
            ServerImageFetcher.i.loadImageIn(self.restaurantImageView, url: withData.profile_picture ?? "")
            self.soldBtn.setTitle(withData.getTotalSold(), for: .normal)
            self.deliveryBtn.setTitle(withData.getDeliveryTime(), for: .normal)
            self.freeDeliveryLbl.isHidden = !(withData.deliveryType == "free")
        }

    }
}


class ActionButtonWithImage:UIButton{

    override func layoutSubviews() {
        self.imageView?.frame.origin.x = 0
        self.titleLabel?.frame.origin.x = 20
    }
}
