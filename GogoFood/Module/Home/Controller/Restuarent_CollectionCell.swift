//
//  Restuarent_CollectionCell.swift
//  User
//
//  Created by ItsDp on 20/08/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class Restuarent_CollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var topSpaceConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var img_freedelivery: UIImageView!
    @IBOutlet weak var soldLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lbl_dscnt: UILabel!
    //    @IBOutlet weak var soldTitleLbl: UILabel!
//    @IBOutlet weak var soldLabel: UILabel!
    //@IBOutlet weak private var quantitySetter: AppStepper!
    @IBOutlet weak var stepper: AppStepper!
//    @IBOutlet weak private var restaurantImage: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var vw_discoun: UIView!
    @IBOutlet weak private var proctName: UILabel!
//    @IBOutlet weak private var cookingTime: UIButton!
//    @IBOutlet weak private var deliveryTime: UIButton!
    @IBOutlet weak var price: UILabel!
//    @IBOutlet weak var orders: UILabel!
//    @IBOutlet weak var soldView: UIView!
//    @IBOutlet weak var likeView: UIStackView!
    
    var restaurantProfile: RestaurantProfileData!
    
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var shareCount: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    private let repo = HomeRepository()
    
    var tapOnLikeButton: (() -> ())!
    var tapOnFavButton: (() -> ())!
    var tapOnCommentButton: (() -> ())!
    var tapOnShareButton: (() -> ())!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if checkDevice() == .small{
            // Small Device
            let smallFontSize:CGFloat = 7.5
            soldLabel.font = UIFont.systemFont(ofSize: smallFontSize)
            deliveryLabel.font = UIFont.systemFont(ofSize: smallFontSize)
            timeLabel.font = UIFont.systemFont(ofSize: smallFontSize)
            price.font = UIFont.systemFont(ofSize: 10)
            topSpaceConstaint.constant = 0
            proctName.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        }
    }
     func initView(withData: ProductData) {
//        if let r = restaurantProfile {
//            restaurantImage.setImage(r.profile_picture ?? "")
//            cookingTime.setTitle(r.getCookingTime(), for: .normal)
//            deliveryTime.setTitle(r.getDeliveryTime(), for: .normal)
//        }else{
//            if withData.dish_images.count > 0{
//
//                restaurantImage.setImage(withData.dish_images?[0] ?? "")
//
//                //                ServerImageFetcher.i.loadProfileImageIn(restaurantImage, url: withData.dish_images?[0] ?? "")
//            }else{
//                restaurantImage.setImage(withData.image ?? "")
//
//                //                ServerImageFetcher.i.loadProfileImageIn(restaurantImage, url: withData.image ?? "")
//            }
//            cookingTime.setTitle(withData.restaurant_id?.getCookingTime(), for: .normal)
//            deliveryTime.setTitle(withData.restaurant_id?.getDeliveryTime(), for: .normal)
//        }
        
        self.timeLabel.text = withData.restaurant_id?.getCookingTime()
        self.deliveryLabel.text = withData.restaurant_id?.getDeliveryTime()
        self.proctName.text = withData.name?.capitalized
        self.img_freedelivery.isHidden = withData.restaurant_id?.deliveryType == "free" ? false:true

        
        let discount = Int(withData.discount_percentage ?? 0.0)
        self.vw_discoun.isHidden = discount > 0 ? false : true
        
        self.lbl_dscnt.text = "\(discount)%"
        if withData.dish_images.count > 0{
            productImage.setImage(withData.dish_images.last ?? "")
            
            //ServerImageFetcher.i.loadImageIn(self.productImage, url: withData.dish_images?[0] ?? "")
        }else{
            productImage.setImage(withData.image ?? "")
            
            //ServerImageFetcher.i.loadImageIn(self.productImage, url: withData.image ?? "")
        }
        
        self.price.text = "$\(withData.getFinalPriceAfterAddUpValue())"
        //withData.getFinalAmount(stikeColor: AppConstant.appBlueColor, normalColor: UIColor.black, fontSize: 13, inSameLine: false)
        self.soldLabel.text = "Sold:\(withData.sold_qty ?? 0)"
        self.stepper.dish = withData

        if withData.restaurant_id?.storeStaus == "closed"{
            self.stepper.isHidden = true
        }else{
            self.stepper.isHidden = false
        }
        //self.soldView.isHidden = (withData.sold_qty ?? 0 == 0)
        //
        //        self.likeCount.text = String(format: "%i Likes", withData.totalLikes)
        //        self.commentCount.text = String(format: "%i Comments", withData.totalComments)
        //        self.shareCount.text = String(format: "%i Share", withData.totalShare)
        //soldTitleLbl.text = "sold".localized()
        
//        self.likeCount.text =  String(format: "%i", withData.totalLikes) + " " + "".localized()
//        self.commentCount.text = String(format: "%i", withData.totalComments) + " " + "".localized()
//        self.shareCount.text = String(format: "%i", withData.totalShare) + " " + "".localized()
        
        if withData.isFavourites == "yes"{
            self.favBtn.isSelected = true
        }else{
            self.favBtn.isSelected = false
        }
        
        if withData.isLike == "yes"{
            self.likeBtn.isSelected = true
        }else{
            self.likeBtn.isSelected = false
        }
    }
    
    @IBAction func likeBtnClicked(_ sender: UIButton) {
        tapOnLikeButton()
    }
    
    @IBAction func favBtnClicked(_ sender: UIButton) {
        tapOnFavButton()
    }
    
    @IBAction func commentBtnClicked(_ sender: UIButton) {
        tapOnCommentButton()
    }
    @IBAction func tapOnShareButton(_ sender: UIButton) {
        tapOnShareButton()
    }
}
