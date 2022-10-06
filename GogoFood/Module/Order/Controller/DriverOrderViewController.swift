//
//  DriverOrderViewController.swift
//  Driver
//
//  Created by MAC on 04/04/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class DriverOrderViewController: BaseTableViewController<OrderData> {
    
    private let repo = OrderRepository()
    private var orderDetail: OrderDetailData!
    private var cartItem: [CartItemData] = []
    
    // RestaurantView
    
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantDetail: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    // Regarding order
    
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var orderInfoHeightConstraint: NSLayoutConstraint!
    
    

    override func viewDidLoad() {
        nib.append(TableViewCell.orderItemTableViewCell.rawValue)
        super.viewDidLoad()
        createNavigationLeftButton(NavigationTitleString.receiptRestaurant)
        repo.getOrderDetail(self.data!) { (item) in
            self.orderDetail = item
            self.setOrderData(item.order)
        }
        // Do any additional setup after loading the view.
    }
    
    
    func setOrderData(_ data: OrderData) {
        self.totalAmount.text = data.order_id?.getOrderTotal()
        self.subTotal.text = data.order_id?.getOrderTotal()
        ServerImageFetcher.i.loadProfileImageIn(restaurantImage, url: data.restaurant_id?.getProfileImagerUrl() ?? "")
        restaurantDetail.text = data.restaurant_id?.name ?? ""
        restaurantAddress.text = data.restaurant_id?.getCompleteAddress(secure: false)
        self.cartItem = data.cart_id ?? []
        self.tableView.reloadData()
        
        
        
    }
    
    
    
    
    @IBAction func modifyView(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UIView.animate(withDuration: 0.5) {
            self.orderInfoHeightConstraint.constant = sender.isSelected ? 0 : 370
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func onPickOrder(_ sender: UIButton) {
        
        
        
//        repo.confirmPickup(order: self.orderDetail.order) {
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    

    //Mark: - TableView Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nib[0], for: indexPath) as! OrderItemTableViewCell
        cell.initView(withData: self.cartItem[indexPath.row])
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItem.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
}
