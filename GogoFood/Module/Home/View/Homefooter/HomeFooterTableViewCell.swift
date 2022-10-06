//
//  HomeFooterTableViewCell.swift
//  GogoFood
//
//  Created by MAC on 17/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class HomeFooterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var tapOnButton: (() -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createSearchBarButton()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func createSearchBarButton(){
        let filterBtn = UIButton.init(frame: CGRect.init(x: 10, y: 10, width: 30, height: 30))
        filterBtn.setImage(UIImage(named: "cart11"), for: .normal)
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
        
//         trackButton.tintColor = AppConstant.primaryColor
    }
    
     func totalAmount(){
      let cartItems =   CurrentSession.getI().localData.cart.cartItems
      self.lbl_price.text = String(format: "$ %.2f",getCartTotal(cartItems))
    }
    func getCartTotal(_ cartItems: [CartItemData]) -> Double{
        return  cartItems.compactMap({$0.calculateTotalPrice()}).reduce(0, +)
    }
    
 
    @IBAction func onTap(_ sender: UIButton) {
        tapOnButton()
    }
}
