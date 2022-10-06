
//
//  HistoryViewController.swift
//  User
//
//  Created by YOGESH BANSAL on 14/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import Cosmos

class HistoryViewController: BaseTableViewController<OrderData>, BottomPopupDelegate {
    @IBOutlet weak var lbl_noRecord: UILabel!
    
    @IBOutlet var noRecordView : UIView!
    private let repo = OrderRepository()
    var refreshControl = UIRefreshControl()
    var tmpObj = GGSkeletonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_noRecord.text = "There is no order yet!".localized()
        self.createNavigationLeftButton("My Orders")
//        self.setNavigationTitleTextColor("My Address".localized())
        tmpObj = tmpObj.createHistorySkeletonView(viewObj: self.view) as! GGSkeletonView
       // self.callHistoryAPI()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
//        self.createNavigationLeftButton(nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.callHistoryAPI()
    }
    func callHistoryAPI(){
        repo.orderHistory { (data) in
            self.allItems = data.order
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            if self.allItems.count == 0{
                self.noRecordView.isHidden = false
            }else{
                self.noRecordView.isHidden = true
            }
            self.tmpObj.stopHistorySkeletonView(viewObj: self.tmpObj)
            self.allItems = self.allItems.sorted(by: {($0.OID ?? 0) > ($1.OID ?? 0)})            
        }
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        self.callHistoryAPI()
    }

    func trackingButtonClicked(orderID : String) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderTrackingViewController") as! OrderTrackingViewController
        vc.orderID = orderID
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "UserHistoryTableViewCell") as! UserHistoryTableViewCell
        c.selectionStyle = .none
        c.initView(withData: self.allItems[indexPath.row])
        c.trackButton = {
           // self.loadWriteViewController(indexInt: indexPath.row)
            //self.trackingButtonClicked(orderID: self.allItems[indexPath.row].id.toString())
        }
        return c
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
        vc.orderDataDic = self.allItems[indexPath.row]
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func loadWriteViewController(indexInt : Int) {
        guard let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        popupVC.orderDic = self.allItems[indexInt]
        popupVC.height = 650
        popupVC.topCornerRadius = 20
        popupVC.presentDuration = 0.33
        popupVC.dismissDuration = 0.33
        popupVC.popupDelegate = self
        popupVC.shouldDismissInteractivelty = false
        //popupVC.previousObj = self
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func bottomPopupDidDismiss() {
        print("bottomPopupWillDismiss")
    }
}


class UserHistoryTableViewCell: BaseTableViewCell<OrderData> {
    
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var trackingBtn: UIButton!
    @IBOutlet weak var orderId: UIButton!
    @IBOutlet weak var numberOfItems: UILabel!
    @IBOutlet weak var orderAmount: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var driverName: UILabel!
    @IBOutlet weak var driverPhone: UILabel!
    @IBOutlet weak var cashPaymentBtn: UIButton!
    @IBOutlet weak var paymentType: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    var trackButton: (() -> ())!
    
    @IBOutlet weak var restaurantName2: UILabel!
    @IBOutlet weak var restaurantName3: UILabel!
    @IBOutlet weak var orderStatus2: UILabel!
    @IBOutlet weak var orderStatus3: UILabel!

    
    
    
    
    
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
        let time = TimeDateUtils.getAgoTime(fromDate: withData.getCreatedTime())
        var total = 0.0
        var taxTotal = 0.0
        var totalProduct = [Double]()
        cashPaymentBtn.setTitle("Cash payment".localized(), for: .normal)
        guard let deliverycharges = withData.restaurantWise else {return}

        guard let restaurantWise = withData.restaurantWise else {return}
        guard let tax_percent = withData.restaurantWise?.map({$0.tax_percent}) else {return}
        
        for (_,value) in restaurantWise.enumerated(){
            
            if let cartID = value.cartId{
                
                var check = 0.0
                for (_,cart) in cartID.enumerated(){
                    let realValue = Double(cart.dish_price ?? 0)
                    let addUpValue = (realValue) * Double(value.restaurantId?.add_up_value ?? Int(0.0)) / 100.0
                    let toppingPrice = Double(cart.topping_price ?? 0)
                    let totalDishPrice  =   realValue + addUpValue + toppingPrice
                    total = total + totalDishPrice
                    check = check + totalDishPrice
                }
                totalProduct.append(check)
            }
            
            
//
//
//            let realValue = (value.cartId?.compactMap({$0.calculatePRiceWithTopping()}).reduce(0, +)) ?? 0.0
//            let addUpValue = (realValue) * Double(value.restaurantId?.add_up_value ?? Int(0.0)) / 100.0
//            total =  total + realValue + addUpValue
//            totalProduct.append(realValue + addUpValue)
        }
       
        
        var check  = 0.0
        
        
        for (_,value) in restaurantWise.enumerated(){
            
            
            let realValue = value.cartId?.compactMap({$0.getTotalPrice(true).replacingOccurrences(of: "$", with: "").toDouble() ?? 0.0}).reduce(0, +)
            
            let addUpValue = Double(realValue ?? 0.0) * Double(value.restaurantId?.add_up_value ?? 0) / 100.0
            check =  realValue ?? 0.0 + addUpValue
        }
        
        
        
        
        let percent = (check * (5) / 100)

        
        
        guard  let checkTmpBool = withData.restaurantWise?.compactMap({$0.tax_applicable}) else {return}
        
        if checkTmpBool.contains("no"){
            for (index,value) in checkTmpBool.enumerated(){
                if value == "no"{
                    taxTotal =  taxTotal + totalProduct[index]
                }
            }
        }
        let tax  = ((total - taxTotal) * (10 )) / 100
        total = total + tax
        if let dis = withData.coupon_discount,dis > 0{
            if let  type = withData.coupon_type,type == "percent"{
                let percent = (totalProduct.reduce(0, +) * (dis) / 100)
                total = total - percent
            }else{
                total = total - Double(dis)
            }
        }else{
             
        }
        let delivery = withData.delivery_charges ?? 0.0
        total = total + delivery
        self.orderId.setTitle("Order ID".localized() + ": \((withData.OID)!.description)", for: .normal)
        numberOfItems.text = "\((withData.totalItems ?? 0).description) " + "Items".localized()
        orderAmount.text =  String(format: "$ %.2f", total)
        orderDate.text = TimeDateUtils.getAgoTime(fromDate: withData.getCreatedTime())
        driverName.text = withData.driver_id?.name?.capitalized ?? "Driver not Assigned"
        driverPhone.text = withData.driver_id?.mobile ?? ""
        self.trackingBtn.isHidden = true
        cosmosView.rating = withData.driver_id?.avg_rating ?? 0
        
        DispatchQueue.main.async {
            guard let restWiseStatus = withData.restaurantWise?.compactMap({$0.getOrderStatus()}) else{return}
            switch restWiseStatus.count {
            case 1:
                self.restaurantName.text = withData.restaurantWise![0].restaurantId?.name ?? ""
                self.restaurantName2.text =  ""
                self.restaurantName3.text =  ""
                self.restaurantName2.isHidden = true
                self.restaurantName3.isHidden = true
                self.orderStatus2.isHidden = true
                self.orderStatus3.isHidden = true
            case 2:
                self.restaurantName.text = withData.restaurantWise?[0].restaurantId?.name ?? ""
                self.restaurantName2.text =  withData.restaurantWise?[1].restaurantId?.name ?? ""
                self.restaurantName3.text =  ""
                self.restaurantName2.isHidden = false
                self.restaurantName3.isHidden = true
                self.orderStatus2.isHidden = false
                self.orderStatus3.isHidden = true
            case 3:
                self.restaurantName.text = withData.restaurantWise?[0].restaurantId?.name ?? ""
                self.restaurantName2.text =  withData.restaurantWise?[1].restaurantId?.name ?? ""
                self.restaurantName3.text =  withData.restaurantWise?[2].restaurantId?.name ?? ""
                self.restaurantName2.isHidden = false
                self.restaurantName3.isHidden = false
                self.orderStatus2.isHidden = false
                self.orderStatus3.isHidden = false
            default:
                break;
            }
            
            
            for (index,value) in restWiseStatus.enumerated() {
                //self.orderStatus.backgroundColor = AppConstant.appYellowColor
                if index == 0{
                    if  value == .accept{
                        self.orderStatus.backgroundColor = AppConstant.appBlueColor
                        self.orderStatus.text = " Accepted "
                    }else if value == .completed || value == .delivered{
                        self.orderStatus.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus.text = " Completed "
                    }else if value == .dispatched{
                        self.trackingBtn.isHidden = false
                        self.orderStatus.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus.text = " Dispatched "
                    }else if value == .driverAssigned{
                        self.trackingBtn.isHidden = false
                        self.orderStatus.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus.text = " Cooking "
                    }else if value == .pickedUp{
                        self.trackingBtn.isHidden = false
                        self.orderStatus.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus.text = " Picked Up "
                    }else if value == .started{
                        self.trackingBtn.isHidden = false
                        self.orderStatus.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus.text = " Started "
                    }else if value == .cancel{
                        self.orderStatus.backgroundColor = AppConstant.primaryColor
                        self.orderStatus.text = " Cancelled "
                    }else if value == .pending{
                        self.orderStatus.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus.text = " Pending "
                    }else if value == .arrived{
                        self.orderStatus.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus.text = " Arrived "
                    }else{
                        self.orderStatus.text = String(format: "  %@  ", value.rawValue.capitalized)
                    }
                }else if index == 1{
                    if  value == .accept{
                        self.orderStatus.backgroundColor = AppConstant.appBlueColor
                        self.orderStatus2.text = " Accepted "
                    }else if value == .completed || value == .delivered{
                        self.orderStatus2.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus2.text = " Completed "
                    }else if value == .dispatched{
                        self.trackingBtn.isHidden = false
                        self.orderStatus2.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus.text = " Dispatched "
                    }else if value == .driverAssigned{
                        self.trackingBtn.isHidden = false
                        self.orderStatus2.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus2.text = " Cooking "
                    }else if value == .pickedUp{
                        self.trackingBtn.isHidden = false
                        self.orderStatus2.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus2.text = " Picked Up "
                    }else if value == .started{
                        self.trackingBtn.isHidden = false
                        self.orderStatus2.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus2.text = " Started "
                    }else if value == .cancel{
                        self.orderStatus2.backgroundColor = AppConstant.primaryColor
                        self.orderStatus2.text = " Cancelled "
                    }else if value == .pending{
                        self.orderStatus2.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus2.text = " Pending "
                    }else if value == .arrived{
                        self.orderStatus2.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus2.text = " Arrived "
                    }else{
                        self.orderStatus2.text = String(format: "  %@  ", value.rawValue.capitalized)
                    }
                }else{
                    if  value == .accept{
                        self.orderStatus3.backgroundColor = AppConstant.appBlueColor
                        self.orderStatus3.text = " Accepted "
                    }else if value == .completed || value == .delivered{
                        self.orderStatus3.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus3.text = " Completed "
                    }else if value == .dispatched{
                        self.trackingBtn.isHidden = false
                        self.orderStatus3.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus3.text = " Dispatched "
                    }else if value == .driverAssigned{
                        self.trackingBtn.isHidden = false
                        self.orderStatus3.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus3.text = " Cooking "
                    }else if value == .pickedUp{
                        self.trackingBtn.isHidden = false
                        self.orderStatus3.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus3.text = " Picked Up "
                    }else if value == .started{
                        self.trackingBtn.isHidden = false
                        self.orderStatus3.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus3.text = " Started "
                    }else if value == .cancel{
                        self.orderStatus3.backgroundColor = AppConstant.primaryColor
                        self.orderStatus3.text = " Cancelled "
                    }else if value == .pending{
                        self.orderStatus3.backgroundColor = AppConstant.appYellowColor
                        self.orderStatus3.text = " Pending "
                    }else if value == .arrived{
                        self.orderStatus3.backgroundColor = AppConstant.tertiaryColor
                        self.orderStatus3.text = " Arrived "
                    }else{
                        self.orderStatus3.text = String(format: "  %@  ", value.rawValue.capitalized)
                    }
                }
            }
            self.addressLbl.text = withData.delivery_address?.address ?? "Address not found!"
        }
        
        
        
        
        
        
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//            //self.orderStatus.backgroundColor = AppConstant.appYellowColor
//            if withData.getOrderStatus() == .accept{
//                self.orderStatus.backgroundColor = AppConstant.appBlueColor
//                self.orderStatus.text = " Accepted "
//            }else if withData.getOrderStatus() == .completed || withData.getOrderStatus() == .delivered{
//                self.orderStatus.backgroundColor = AppConstant.tertiaryColor
//                self.orderStatus.text = " Completed "
//            }else if withData.getOrderStatus() == .dispatched{
//                self.trackingBtn.isHidden = false
//                self.orderStatus.backgroundColor = AppConstant.tertiaryColor
//                self.orderStatus.text = " Dispatched "
//            }else if withData.getOrderStatus() == .driverAssigned{
//                self.trackingBtn.isHidden = false
//                self.orderStatus.backgroundColor = AppConstant.appYellowColor
//                self.orderStatus.text = " Cooking "
//            }else if withData.getOrderStatus() == .pickedUp{
//                self.trackingBtn.isHidden = false
//                self.orderStatus.backgroundColor = AppConstant.appYellowColor
//                self.orderStatus.text = " Picked Up "
//            }else if withData.getOrderStatus() == .started{
//                self.trackingBtn.isHidden = false
//                self.orderStatus.backgroundColor = AppConstant.appYellowColor
//                self.orderStatus.text = " Started "
//            }else if withData.getOrderStatus() == .cancel{
//                self.orderStatus.backgroundColor = AppConstant.primaryColor
//                self.orderStatus.text = " Cancelled "
//            }else if withData.getOrderStatus() == .pending{
//                self.orderStatus.backgroundColor = AppConstant.appYellowColor
//                self.orderStatus.text = " Pending "
//            }else{
//                self.orderStatus.text = String(format: "  %@  ", withData.getOrderStatus().rawValue.capitalized)
//            }
//        })
        
      
    }
    
    @IBAction func trackingBtnClicked(_ sender: UIButton) {
        trackButton()
    }
    
}
