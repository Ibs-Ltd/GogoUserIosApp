//
//  FooterView_Cart.swift
//  User
//
//  Created by ItsDp on 26/08/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class FooterView_Cart: UIView {
    @IBOutlet weak var lbl_order: UILabel!

    @IBOutlet weak var lbl_price: UILabel!
    var tapOnButton: (() -> ())!
    static func instantiate(message: String) -> FooterView_Cart {
        let view: FooterView_Cart = initFromNib()
        view.lbl_order.text = "View your order".localized()
        return view
    }
    func createSearchBarButton(){
        let filterBtn = UIButton.init(frame: CGRect.init(x: 10, y: 10, width: 24, height: 24))
        filterBtn.setImage(UIImage(named: "cart2"), for: .normal)
        let lblBadge = UILabel.init(frame: CGRect.init(x: 20, y: 10, width: 15, height: 15))
        lblBadge.backgroundColor = .white
        lblBadge.clipsToBounds = true
        lblBadge.layer.cornerRadius = 7
        lblBadge.textColor = AppConstant.primaryColor
        lblBadge.font = UIFont.systemFont(ofSize: 10)
        lblBadge.textAlignment = .center
        let cart = CurrentSession.getI().localData.cart.cartItems
        let count = (cart.compactMap({$0.quantity ?? 0}).reduce(0, +))
        lblBadge.text = count.description
        lblBadge.isHidden = CurrentSession.getI().localData.cart.cartItems.isEmpty
        filterBtn.addSubview(lblBadge)
        self.addSubview(filterBtn)
        
    }
    
    func totalAmount(){
        let cartItems =   CurrentSession.getI().localData.cart.cartItems
        self.lbl_price.text = String(format: "$ %.2f",getCartTotal(cartItems))
    }
    func total() -> Double {
        let cartItems =   CurrentSession.getI().localData.cart.cartItems
        return  getCartTotal(cartItems)
    }
    func getCartTotal(_ cartItems: [CartItemData]) -> Double{
        return  cartItems.compactMap({$0.calculateTotalPrice()}).reduce(0, +)
    }
    @IBAction func onTap(_ sender: UIButton) {
          tapOnButton()
      }
    
}

extension UIView {
    class func initFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}
