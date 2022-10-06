//
//  OrderItemTableViewCell.swift
//  Restaurant
//
//  Created by YOGESH BANSAL on 21/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class OrderItemTableViewCell: BaseTableViewCell<CartItemData> {
    
    @IBOutlet weak var vatTitleLbl: UILabel!
    @IBOutlet weak var deliveryFeeTitleLbl: UILabel!
    @IBOutlet weak var subTotalTitleLbl: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stepper: AppStepper!
    @IBOutlet weak var chooseOptionButton: UIButton!
    var onTapToReject: (() -> Void)!
    @IBOutlet weak var itemStatusButtonView: UIView!
    var isFromOrder =  false
    var ordersData:RestaurantProfileData?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func initViewForDetail() {
        #if User
        let setForUser = true
        #else
        let setForUser = false
        #endif
        rejectButton.isHidden = setForUser
        chooseOptionButton.isHidden = setForUser
        quantityLabel.isHidden = setForUser
        stepper.isHidden = !setForUser
    }
    
    func initViewForHistoryDetail() {
        rejectButton.isHidden = true
        chooseOptionButton.isHidden = true
        quantityLabel.isHidden = false
        stepper.isHidden = true
    }
    
    override func initView(withData: CartItemData) {
        super.initView(withData: withData)
        initViewForDetail()
        setViewForCart(withData:withData)
    }
    
    
    
    
    
    private func setViewForCart(withData:CartItemData) {
        if let d = self.data?.first {
            if let product = d.dish_id {
                #if User
                self.stepper.dish = product
                stepper.showFromCart = true
                stepper.cartItem = d
                #else
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    if d.hasRejecetd {
                        self.rejectButton.backgroundColor = AppConstant.primaryColor
                        self.rejectButton.setTitle("Cancelled", for: .normal)
                        self.rejectButton.isUserInteractionEnabled = false
                    }else if d.status == "rejected by restaurant" {
                        self.rejectButton.backgroundColor = AppConstant.primaryColor
                        self.rejectButton.setTitle("Cancelled", for: .normal)
                        self.rejectButton.isUserInteractionEnabled = false
                    }else{
                        self.rejectButton.backgroundColor = AppConstant.appYellowColor
                        self.rejectButton.setTitle("Reject", for: .normal)
                        self.rejectButton.isUserInteractionEnabled = true
                    }
                })
                #endif
                if product.dish_images.count > 0{
                    foodImage.setImage(product.dish_images.last ?? "")
//                    ServerImageFetcher.i.loadImageIn(self.foodImage, url: product.dish_images?[0] ?? "")
                }else{
                    foodImage.setImage(product.image ?? "")

                  //  ServerImageFetcher.i.loadImageIn(self.foodImage, url: product.image ?? "")
                }
                self.foodImage.contentMode = .scaleAspectFill
                self.itemLabel.text = product.name?.capitalized
                
                if product.discount_type == "none"{
                    
                    if isFromOrder {
                        let realValue = withData.getTotalPrice(true).replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0
                        let addUpValue = Double(realValue) * Double(ordersData?.add_up_value ?? 0) / 100.0
                        let total =  realValue + addUpValue
                        self.priceLabel.text = String(format: "$ %.2f", total)
                    }else{
                        self.priceLabel.text = String(format: "$ %.2f", d.calculateTotalPriceWithAddUp())
                    }
                }else{
                    
                    
                    if isFromOrder{
                        
                        let realValue = withData.getTotalPrice(true).replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0
                        let addUpValue = Double(realValue) * Double(ordersData?.add_up_value ?? 0) / 100.0
                        let total =  realValue + addUpValue

                        
                        let realValue1 = withData.getTotalPrice(false).replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0
                        let addUpValue1 = Double(realValue1) * Double(ordersData?.add_up_value ?? 0) / 100.0
                        let total1 =  realValue1 + addUpValue1


                        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
                        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
                        
                        let attributedString1 = NSMutableAttributedString(string:String(format: "$ %.2f", total), attributes:attrs1 as [NSAttributedString.Key : Any])
                        attributedString1.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedString1.length))
                        let attributedString2 = NSMutableAttributedString(string:String(format: "\n $ %.2f", total1), attributes:attrs2 as [NSAttributedString.Key : Any])
                        
                        attributedString1.append(attributedString2)
                        self.priceLabel.attributedText = attributedString1
                        self.priceLabel.adjustsFontSizeToFitWidth = true
                        
                        
                    }else{
                        
                        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
                        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .semibold), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
                        let attributedString1 = NSMutableAttributedString(string:String(format: "$ %.2f", d.calculateTotalPriceWithAddUp()), attributes:attrs1 as [NSAttributedString.Key : Any])
                        attributedString1.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedString1.length))
                        let attributedString2 = NSMutableAttributedString(string:String(format: "\n%@", d.getTotalPrice()), attributes:attrs2 as [NSAttributedString.Key : Any])
                        
                        if Session.couponApplied == true {
                            let attributedStringNew = NSMutableAttributedString(string:String(format: "$ %.2f", d.calculateTotalPriceWithAddUp()), attributes:attrs2 as [NSAttributedString.Key : Any])
                            self.priceLabel.attributedText = attributedStringNew
                            self.priceLabel.adjustsFontSizeToFitWidth = true
                        }else{
                            attributedString1.append(attributedString2)
                            self.priceLabel.attributedText = attributedString1
                            self.priceLabel.adjustsFontSizeToFitWidth = true
                        }
                    }
                }
                self.descriptionLabel.text = d.toppings?.compactMap({$0.addonId!.addonName! + " " + $0.topping_name!}).joined(separator: ",")
                self.chooseOptionButton.isHidden = product.options?.isEmpty ?? true
                self.quantityLabel.text = (d.quantity ?? 0).description
            }
        }
    }
    
    @IBAction func onSelectOption(_ sender: UIButton) {
        #if User
        stepper.showProductOption()
        #endif
    }
    @IBAction func onRejectItem(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            sender.backgroundColor = AppConstant.primaryColor
        }else{
            sender.backgroundColor = AppConstant.appYellowColor
        }
        onTapToReject()
    }
}


