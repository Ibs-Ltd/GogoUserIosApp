//
//  FoodDetailTableViewCell.swift
//  User
//
//  Created by YOGESH BANSAL on 13/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit

class FoodDetailTableViewCell: BaseTableViewCell<ProductData> {
    @IBOutlet weak var lbl_discount: UILabel!
    @IBOutlet weak var lbl_rating: UILabel!

    @IBOutlet weak var vw_rating: UIView!
    @IBOutlet weak var soldTitleLbl: UILabel!
    @IBOutlet weak var soldLabel: UILabel!
    //@IBOutlet weak private var quantitySetter: AppStepper!
    @IBOutlet weak var stepper: AppStepper!
    @IBOutlet weak private var restaurantImage: UIImageView!
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var img_freedelivery: UIImageView!
    @IBOutlet weak private var proctName: UILabel!
    @IBOutlet weak private var cookingTime: UIButton!
    @IBOutlet weak private var deliveryTime: UIButton!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var orders: UILabel!
    @IBOutlet weak var soldView: UIView!
    @IBOutlet weak var likeView: UIStackView!
    
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
        #if User
//        quantitySetter.onModifyItem = { count in
//            print(count)
//        }
        #endif
    }
    
    override func initView(withData: ProductData) {
        super.initView(withData: withData)
        if let r = restaurantProfile {
            restaurantImage.setImage(r.profile_picture ?? "")
            
//            ServerImageFetcher.i.loadProfileImageIn(restaurantImage, url: r.profile_picture ?? "")
            cookingTime.setTitle(r.getCookingTime(), for: .normal)
            deliveryTime.setTitle(r.getDeliveryTime(), for: .normal)
        }else{
            if withData.dish_images.count > 0{
                
                restaurantImage.setImage(withData.dish_images.last ?? "")

//                ServerImageFetcher.i.loadProfileImageIn(restaurantImage, url: withData.dish_images?[0] ?? "")
            }else{
                restaurantImage.setImage(withData.image ?? "")

//                ServerImageFetcher.i.loadProfileImageIn(restaurantImage, url: withData.image ?? "")
            }
            cookingTime.setTitle(withData.restaurant_id?.getCookingTime(), for: .normal)
            deliveryTime.setTitle(withData.restaurant_id?.getDeliveryTime(), for: .normal)
        }
        self.proctName.text = withData.name?.capitalized
        if withData.dish_images.count > 0{
            productImage.setImage(withData.dish_images.last ?? "")

            //ServerImageFetcher.i.loadImageIn(self.productImage, url: withData.dish_images?[0] ?? "")
        }else{
            productImage.setImage(withData.image ?? "")

            //ServerImageFetcher.i.loadImageIn(self.productImage, url: withData.image ?? "")
        }
        
        
        
        if withData.restaurant_id?.storeStaus == "closed"{
            self.stepper.isHidden = true
        }else{
            self.stepper.isHidden = false
        }
        
        
        
        self.img_freedelivery.isHidden = withData.restaurant_id?.deliveryType == "free" ? false:true

        
        let discount = Int(withData.discount_percentage ?? 0.0)
        self.vw_rating.isHidden = discount > 0 ? false : true
        self.lbl_discount.text = "\(discount)% DISCOUNT"
        let rating = withData.avgRating > 0 ?  withData.avgRating : 4.5

        self.lbl_rating.text = "\(rating ?? 4.5)"
        self.price.text = "$\(withData.getFinalPriceAfterAddUpValue())"
           // withData.getFinalAmount(stikeColor: AppConstant.appBlueColor, normalColor: UIColor.black, fontSize: 13, inSameLine: false)
        self.orders.text = "Sold:\(withData.sold_qty ?? 0)"
        self.stepper.dish = withData
        //self.soldView.isHidden = (withData.sold_qty ?? 0 == 0)
//
//        self.likeCount.text = String(format: "%i Likes", withData.totalLikes)
//        self.commentCount.text = String(format: "%i Comments", withData.totalComments)
//        self.shareCount.text = String(format: "%i Share", withData.totalShare)
        //soldTitleLbl.text = "sold".localized()
        
        self.likeCount.text =  String(format: "%i", withData.totalLikes) + " " + "".localized()
        self.commentCount.text = String(format: "%i", withData.totalComments) + " " + "".localized()
        self.shareCount.text = String(format: "%i", withData.totalShare) + " " + "".localized()
        
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
    
//    override func initView(withData: ProductData) {
//        super.initView(withData: withData)
//        if let r = restaurantProfile {
//         ServerImageFetcher.i.loadProfileImageIn(restaurantImage, url: r.profile_picture ?? "")
//            cookingTime.setTitle(r.getCookingTime(), for: .normal)
//            deliveryTime.setTitle(r.getDeliveryTime(), for: .normal)
//        }
//        
//        self.proctName.text = withData.name
//        ServerImageFetcher.i.loadImageIn(self.productImage, url: withData.image ?? "")
//        self.price.attributedText = withData.getFinalAmount(stikeColor: AppConstant.appBlueColor, normalColor: UIColor.white, fontSize: 13, inSameLine: false)
//        self.orders.text = "\(withData.sold_qty ?? 0)"
//        #if User
//        self.stepper.dish = withData
//        #endif
//        self.soldView.isHidden = (withData.sold_qty ?? 0 == 0)
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


