//
//  PaymentMethodTableViewCell.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 04/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class PaymentMethodTableViewCell: BaseTableViewCell<CartData> {

    @IBOutlet weak var paymentMethodTitleLbl: UILabel!
    @IBOutlet weak var totalPaymentTitleLbl: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var checkOutBtn: UIButton!
    
    @IBOutlet weak var COD_btn: UIButton!
    @IBOutlet weak var wallet_btn: UIButton!

   
    @IBOutlet private var paymentMethod: [UIButton]!
    private var paymentMethodType: PaymentMethod = .cod
    var placeOrder: ((_ withPaymentMethod: PaymentMethod)-> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkOutBtn.setTitle("CHECK OUT".localized(), for: .normal)
        COD_btn.setTitle("Cash on delivery".localized(), for: .normal)
        wallet_btn.setTitle("Wallet".localized(), for: .normal)

       
        // Initialization code
    }

    override func initView(withData: CartData) {
      paymentMethodTitleLbl.text = "Payment method".localized()
      totalPaymentTitleLbl.text = "Total Payment".localized()
      self.amountLabel.text = withData.getCartTotal().total
    }
    
    func setupPaymentAction(withData:String) {
        
        if withData == "wallet"{
            paymentMethod[0].isSelected = false
            paymentMethod[1].isSelected = true
            self.paymentMethodType = .wallet
        }else{
            paymentMethod[1].isSelected = false
            paymentMethod[0].isSelected = true
            self.paymentMethodType = .cod
        }
        
    }
    
    
    
    
    @IBAction private func selectPaymentMethod(_ sender: UIButton) {
        self.paymentMethod.forEach({$0.isSelected = !$0.isSelected})
        if self.paymentMethodType == .cod{
            self.paymentMethodType = .wallet
        }else{
            self.paymentMethodType = .cod
        }
    }
    
    @IBAction private func palaceOrder(_ sender: UIButton) {
        Session.paymentType = self.paymentMethodType.rawValue
        placeOrder(self.paymentMethodType)
    }
    
}
