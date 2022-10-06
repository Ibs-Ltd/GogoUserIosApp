//
//  RestaurantHistoryTableViewCell.swift
//  Restaurant
//
//  Created by YOGESH BANSAL on 21/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class RestaurantHistoryTableViewCell: BaseTableViewCell<OrderData> {
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    
    @IBOutlet weak var numberOfItems: UILabel!
    
    @IBOutlet weak var orderAmount: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func initView(withData: OrderData) {
        super.initView(withData: withData)
        orderId.text = "Order ID: \((withData.id).description)"
        numberOfItems.text = (withData.cart_id?.count ?? 0).description
        orderDate.text = TimeDateUtils.getAgoTime(fromDate: withData.getCreatedTime())
        orderStatus.text = withData.getOrderStatus().rawValue.capitalized
        ServerImageFetcher.i.loadProfileImageIn(userImage, url: withData.user_id?.profile_picture ?? "")
        self.userImage.contentMode = .scaleAspectFill
        orderAmount.text =  withData.order_id?.getOrderTotal()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            if withData.getOrderStatus().rawValue == "cancelled"{
                self.orderStatus.textColor = AppConstant.primaryColor
            }
        })
        
    }
    
    
    
}
