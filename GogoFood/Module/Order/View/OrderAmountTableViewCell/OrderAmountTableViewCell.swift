//
//  OrderAmountTableViewCell.swift
//  Restaurant
//
//  Created by YOGESH BANSAL on 21/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class OrderAmountTableViewCell: BaseTableViewCell<CartData> {
    @IBOutlet weak var subTotalTitleLbl: UILabel!
    
    @IBOutlet weak var vatTitleLbl: UILabel!
    @IBOutlet weak var deliveryTitleLbl: UILabel!
    @IBOutlet weak var removeCouponBtn: UIButton!
    @IBOutlet weak var CouponBtn: UIButton!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var vatLabel: UILabel!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var totalAmtLabel: UILabel!
    @IBOutlet weak var couponCode: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var totalText: UILabel!
    
    var cancelCoupon: (()-> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        subTotalTitleLbl.text = "Subtotal".localized()
        deliveryTitleLbl.text = "Delivery Fee".localized()
        vatTitleLbl.text = "incl. VAT".localized()
        CouponBtn.setTitle("Do you have a coupon code?".localized(), for: .normal)
        totalText.text = "Total (Include VAT)".localized()
        // Initialization code
    }

    override func initView(withData: CartData) {
        super.initView(withData: withData)
        
        //let subTotalPrice = withData.getSubtotal().replacingOccurrences(of: "$ ", with: "").toDouble()
        //let vatPrice = withData.getVat().replacingOccurrences(of: "$ ", with: "").toDouble()
        //let subTotalFinal = (subTotalPrice ?? 0.0) + (vatPrice ?? 0.0)
       
        subTotalLabel.text = withData.getSubtotal()
        if withData.delivery_fee != nil{
            deliveryLabel.text = withData.getDeliveryCharges()
        }
        
        vatLabel.text = withData.getVat()
        totalAmtLabel.text = withData.getCartTotal().total
        if withData.getCartTotal().isDisCount{
            subTotalLabel.text = withData.getCartTotal().subtotal
        }
        
        
        if withData.couponDic != nil{
                        
            if withData.couponDic?.promotionType == "amount"{
                self.couponCode.text = String(format: "$ %.2f", withData.couponDic?.discount ?? 0.0)
            }else{
                self.couponCode.text = withData.getPromocodeValue()
            }
            self.removeCouponBtn.isHidden = false
            self.CouponBtn.setTitle(String(format: "%@ applied", withData.couponDic!.generateCode!), for: .normal)
        }else{
            self.couponCode.text = "$ 0.0"
            self.removeCouponBtn.isHidden = true
            self.CouponBtn.setTitle("Do you have a coupon code?".localized(), for: .normal)
        }
        //totalAmtLabel.text = "$ \(subTotalFinal.DtoString())"
    }
    
    func setViewForDetail() {
        
        stackView.isHidden = true
        self.couponCode.isHidden = true
        totalText.attributedText = NSAttributedString(string: "Total")
    }
    
    @IBAction private func cancelCouponBtnClicked(_ sender: UIButton) {
        cancelCoupon()
        
    }
    
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func toInt() -> Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
}

extension Double{
    func DtoString() -> String{
        let myString = String(self)
        return myString
    }
}
