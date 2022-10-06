//
//  DriverOrderTableViewCell.swift
//  Driver
//
//  Created by MAC on 05/04/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class DriverOrderTableViewCell: BaseTableViewCell<OrderData> {
    @IBOutlet weak var orderId: UIButton!
    @IBOutlet weak var itemsInOrder: UILabel!
    
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var orderTime: UILabel!
    @IBOutlet weak var restaurantOne: UILabel!
    @IBOutlet weak var restaurantTwo: UILabel!
    
    @IBOutlet weak var restaurantThree: UILabel!
    @IBOutlet weak var autoRejectTimer: UILabel!
    
    @IBOutlet weak var restaurant1Status: UILabel!
    
    @IBOutlet weak var restaurant2Status: UILabel!
    
    @IBOutlet weak var restaurant3Status: UILabel!
    
    @IBOutlet weak var paymentMode: UILabel!
    var onReviewOrder: ((_ hasAccept: Bool)-> Void)!
    
    @IBOutlet weak var acceptRejectButton: UIStackView!
    
    @IBOutlet weak var userAddress: UILabel!
    var isForAceptedOrder: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func reviewOrder(_ sender: UIButton) {
        onReviewOrder(sender.tag == 0)
    }
    
    override func initView(withData: OrderData) {
        hideLabels()
        self.acceptRejectButton.isHidden = isForAceptedOrder
        self.autoRejectTimer.isHidden = isForAceptedOrder
        self.orderId.setTitle("Order ID" + (withData.order_id?.id.description ?? "0"), for: .normal)
        self.totalAmount.text = withData.order_id?.getOrderTotal()
        self.itemsInOrder.text = (withData.order_id?.getTotalItemInOrder() ?? "0") + " Items" 
        
        if withData.order_id?.restaurant_wise?.indices.contains(0) ?? false {
            let restaurant = withData.order_id?.restaurant_wise?[0]
            self.restaurantOne.isHidden = false
            self.restaurant1Status.isHidden = false
            self.restaurantOne.text = restaurant?.restaurant_id?.name
            self.restaurant1Status.text = restaurant?.getOrderStatusAsString().capitalized
            self.restaurant1Status.backgroundColor = restaurant?.getColorForStatus()
        }
        if withData.order_id?.restaurant_wise?.indices.contains(1) ?? false {
            let restaurant = withData.order_id?.restaurant_wise?[1]
            self.restaurantTwo.isHidden = false
            self.restaurant2Status.isHidden = false
            self.restaurantOne.text = restaurant?.restaurant_id?.name
            self.restaurant2Status.text = restaurant?.getOrderStatusAsString().capitalized
            self.restaurant2Status.backgroundColor = restaurant?.getColorForStatus()
        }
        if withData.order_id?.restaurant_wise?.indices.contains(2) ?? false {
            let restaurant = withData.order_id?.restaurant_wise?[2]
            self.restaurantThree.isHidden = false
            self.restaurant3Status.isHidden = false
            self.restaurantThree.text = restaurant?.restaurant_id?.name
            self.restaurant3Status.text = restaurant?.getOrderStatusAsString().capitalized
            self.restaurant3Status.backgroundColor = restaurant?.getColorForStatus()
        }
        
        //self.userAddress.text = withData.
        
    }
    
    
    
    func hideLabels() {
        self.restaurantOne.isHidden = true
        self.restaurant1Status.isHidden = true
        self.restaurantTwo.isHidden = true
        self.restaurant2Status.isHidden = true
        self.restaurantThree.isHidden = true
        self.restaurant3Status.isHidden = true
        
    }
    

}
