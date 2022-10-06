//
//  RecommendsCollectionViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 15/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit

class RecommendsCollectionViewCell: BaseCollectionViewCell<ProductData> {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cookingTime: UIButton!
    @IBOutlet weak var deliveryTime: UIButton!
    @IBOutlet weak var stepper: AppStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func initViewWith(_ data: ProductData) {
        super.initViewWith(data)
        if data.dish_images.count > 0{
            ServerImageFetcher.i.loadImageIn(imageView, url: data.dish_images?[0] ?? "")
        }else{
            ServerImageFetcher.i.loadImageIn(imageView, url: data.image ?? "")
        }
        
        if data.restaurant_id?.storeStaus == "closed"{
            stepper.isHidden = true
        }else{
            stepper.isHidden = false
        }
        
        name.text = data.name?.capitalized
        price.attributedText = data.getFinalAmount(stikeColor: AppConstant.primaryColor, normalColor: AppConstant.appBlueColor, fontSize: 12, inSameLine: false) 
        price.numberOfLines = 2
        price.backgroundColor = .clear
        cookingTime.setTitle(data.getCookingTime(), for: .normal)
        deliveryTime.setTitle(data.getDeliveryTime(), for: .normal)
        #if User
        stepper.dish = data
        #endif
       
    }
    

}
