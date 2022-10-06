//
//  FoodCollectionViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 11/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit

class FoodCollectionViewCell: BaseCollectionViewCell<ProductData> {
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var shares: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!

    @IBOutlet weak var img_freedelivery: UIImageView!
    
    
    
    
    
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var favourites: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var likes: UILabel!
    
    @IBOutlet weak var stepper: AppStepper!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var freeDeliveryLbl: UILabel!
    @IBOutlet weak var soldBtn: UIButton!
    @IBOutlet weak var discountPercentLbl: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var cookingTime: UIButton!
    @IBOutlet weak var delevieryTime: UIButton!
    @IBOutlet weak var price: UILabel!
    
    
    var tapOnLikeButton: (() -> ())!
    var tapOnFavButton: (() -> ())!
    var tapOnCommentButton: (() -> ())!
    var tapOnShareButton: (() -> ())!
    var tapOndidSelect: (() -> ())!

    override func awakeFromNib() {
        super.awakeFromNib()
        //Set skeleton
        //self.productImageView.showAnimatedGradientSkeleton()
        // Initialization code
        
    }

    override func initViewWith(_ data: ProductData) {
        super.initViewWith(data)
        if data.dish_images.count > 0{
            let urlString = data.dish_images.last?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let imageURL = URL(string: urlString ?? "")
            productImageView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: ""))
        }else{
            
            let urlString = data.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let imageURL = URL(string: urlString ?? "")
            productImageView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: ""))
            //ServerImageFetcher.i.loadImageIn(productImageView, url: data.image ?? "")
        }
        if data.restaurant_id?.storeStaus == "closed"{
            stepper.isHidden = true
        }else{
            stepper.isHidden = false
        }
        
        
        
        itemNameLbl.text = data.name?.capitalized ?? ""
        likes.text = convertNumberToString(val: data.totalLikes)
        comments.text = convertNumberToString(val: data.totalComments)
        shares.text = convertNumberToString(val: data.totalShare)
        productImageView.contentMode = .scaleAspectFill
        favoriteBtn.setImage(UIImage(named: data.isFavourites == "yes" ? "favouritered" : "favouritewhite"), for: .normal)
        //cookingTime.setTitle(data., for: .normal)
        let rating = data.avgRating > 0 ?  data.avgRating : 4.5
        ratingLbl.text = String(format: "%.1f", rating ?? 0.0)
        let sold = data.sold_qty?.description ?? ""
        soldBtn.setTitle("\("Sold".localized()): \(sold)", for: .normal)
//        price.attributedText = data.getFinalAmount(stikeColor: AppConstant.appBlueColor, normalColor: UIColor.white, fontSize: 12, inSameLine: false)
        price.text = "$" + String(format: "%.2f", data.getFinalPriceAfterAddUpValue() ?? 0)
        self.delevieryTime.setTitle(data.getDeliveryTime(), for: .normal)
        self.cookingTime.setTitle(data.getCookingTime(), for: .normal)
        img_freedelivery.isHidden = data.restaurant_id?.deliveryType == "free" ? false : true
        freeDeliveryLbl.isHidden = true
        discountView.isHidden = !(data.discount_type == "percent")
        discountPercentLbl.text = String(format: "%.0f", data.discount_percentage ?? 0) + "%"
        self.stepper.dish = data
        self.stepper.backgroundColor = .clear
        if data.isFavourites == "yes"{
            self.favBtn.isSelected = true
        }else{
            self.favBtn.isSelected = false
        }
    }
    
    
    private func convertNumberToString(val: Int)->String{
        let nf = NumberFormatter().string(from: NSNumber(value: val))
        return nf ?? "0"
    }
    
    @IBAction func didSelect(_ sender: Any) {
        tapOndidSelect()
    }
    @IBAction func onActionFav(_ sender: Any) {
        tapOnFavButton()
    }
    @IBAction func onActinComment(_ sender: Any) {
        tapOnCommentButton()
    }
    @IBAction func onActionLike(_ sender: Any) {
        tapOnLikeButton()
    }
    @IBAction func onActionShare(_ sender: Any) {
        tapOnShareButton()
    }
}


class ButtonWithImage: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame.origin.x = 16
        imageView?.frame.origin.x = 0
    }
}
