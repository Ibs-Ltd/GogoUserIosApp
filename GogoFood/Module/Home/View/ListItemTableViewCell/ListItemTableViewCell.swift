//
//  ListItemTableViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 22/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class ListItemTableViewCell: BaseTableViewCell<ProductData> {

    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var deliveryTime: UIButton!
    @IBOutlet weak var cookingTime: UIButton!
    @IBOutlet weak var appStepper: AppStepper!
    
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    private let repo = HomeRepository()

    var tapOnLikeButton: (() -> ())!
    var tapOnFavButton: (() -> ())!
    var tapOnButton: (() -> ())!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func initView(withData: ProductData) {
        super.initView(withData: withData)
        if withData.dish_images.count > 0{
//            let urlString = withData.dish_images[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//            let imageURL = URL(string: urlString ?? "")
//            imageName.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: ""))
//
////            ServerImageFetcher.i.loadImageIn(imageName, url: withData.dish_images[0])
            imageName.setImage(withData.dish_images.last ?? "")
        }else{
            
//            let imageURL = URL(string: withData.image ?? "")
//            imageName.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: ""))
             imageName.setImage(withData.image ?? "")

//            ServerImageFetcher.i.loadImageIn(imageName, url: withData.image ?? "")
        }
        itemName.text = withData.name?.capitalized
        itemPrice.attributedText = withData.getFinalAmount(stikeColor: AppConstant.primaryColor,    normalColor: AppConstant.appBlueColor, fontSize: 12, inSameLine: true)
        deliveryTime.setTitle(withData.getDeliveryTime(), for: .normal)
        cookingTime.setTitle(withData.getCookingTime(), for: .normal)
        appStepper.dish = withData
        self.favButton.subviews.first?.contentMode = .scaleAspectFill
        self.likeButton.subviews.first?.contentMode = .scaleAspectFill
        
        if withData.isFavourites == "yes"{
            self.favButton.isSelected = true
        }else{
            self.favButton.isSelected = false
        }
        
        if withData.isLike == "yes"{
            self.likeButton.isSelected = true
        }else{
            self.likeButton.isSelected = false
        }
    }


    @IBAction func likeBtnClicked(_ sender: UIButton) {
        tapOnLikeButton()
    }
    
    @IBAction func favBtnClicked(_ sender: UIButton) {
        tapOnFavButton()
    }
    
    @IBAction func commentBtnClicked(_ sender: UIButton) {
        tapOnButton()
    }
    
}
