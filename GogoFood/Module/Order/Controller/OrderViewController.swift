//
//  OrderViewController.swift
//  GogoFood
//
//  Created by MAC on 29/03/20.
//  Copyright © 2020 GWS. All rights reserved.
//
import UIKit
import CoreLocation
import BarcodeScanner

class OrderViewController: BaseTableViewController<OrderData>, BottomPopupDelegate {
    
    var expandedOrder  = false
    private let repo = CartRepository()
    private var numberOfSection = 0
    private var cartItems: [[CartItemData]] = []
    @IBOutlet weak var emptyCartImage: UIImageView!
    var paymentTypeCell : PaymentMethodTableViewCell!
    var orderDataDic : OrderData!
    var restuarentID = [RestaurantProfileData]()
    lazy var total = 0.0
    var restLatLong:[(lat: Double, long: Double)] = []

    var orderStatus = [String]()
    override func viewDidLoad() {
        nib = [TableViewCell.orderItemTableViewCell.rawValue, TableViewCell.orderAmountTableViewCell.rawValue,
               TableViewCell.contactInfoTableViewCell.rawValue,
               TableViewCell.deliveryDetailTableViewCell.rawValue,
               TableViewCell.paymentMethodTableViewCell.rawValue]
        super.viewDidLoad()
        
        createNavigationLeftButton(NavigationTitleString.completeOrder.localized())
        addNotification()
        self.orderStatus = []
        if let resturent = self.orderDataDic.restaurantWise {
            for value in resturent.enumerated(){
                restLatLong.append((lat: value.element.restaurantId?.latitude ?? 0.0, long: value.element.restaurantId?.longitude ?? 0.0))
                self.orderStatus.append(value.element.status ?? "")
                if let cartID = value.element.cartId{
                    for _ in cartID{
                        self.restuarentID.append(value.element.restaurantId!)
                    }
                }
            }
        }
        
        self.navigationItem.rightBarButtonItems = [createTrackingBarButton()]
    }
   
    override func tapOnTrackingButtton() {
        print(tapOnTrackingButtton)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderTrackingViewController") as! OrderTrackingViewController
        vc.orderID = self.orderDataDic.id.toString()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            return UITableView.automaticDimension
        }else if indexPath.section == 2 {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            let count =  self.orderDataDic.restaurantWise?.compactMap({$0.cartId?.count}).reduce(0, +)
            return count ?? 0
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return getOrderItemCell(indexPath)
        }else if indexPath.section == 1 {
            return getOrderAmountCell(indexPath)
        }else if indexPath.section == 2 {
            return getContactTableCell(indexPath)
        }else if indexPath.section == 3 {
            return getDeliveryDetailTableCell(indexPath)
        } else {
            return getPaymentMethodCell(indexPath)
        }
    }
    
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    private func getPaymentMethodCell(_ indexPath: IndexPath) -> PaymentMethodTableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! PaymentMethodTableViewCell
        cell.selectionStyle = .none
        cell.setupPaymentAction(withData: self.orderDataDic.payment_method ?? "")
        cell.amountLabel.text = String(format: "$ %.2f",self.total)
        //if self.orderDataDic.getOrderStatus() == .driverAssigned || self.orderDataDic.getOrderStatus() == .pickedUp{
        if self.orderDataDic.getOrderStatus() == .arrived{
            cell.checkOutBtn.isHidden = false
            cell.placeOrder = { (method) in
                if method == .cod{
                    self.callPaymentAPI(orderIDStr: (self.orderDataDic.OID?.toString())!, url: ServerUrl.confirmRecievedUrl)
                }else{
                    let viewController = BarcodeScannerViewController()
                    viewController.codeDelegate = self
                    viewController.errorDelegate = self
                    viewController.dismissalDelegate = self
                    self.present(viewController, animated: true, completion: nil)
                }
            }
        }else if self.orderDataDic.getOrderStatus() == .delivered || self.orderDataDic.getOrderStatus() == .delivered{
            if self.orderDataDic.payment_status != "pending"{
                cell.checkOutBtn.isHidden = false
                cell.checkOutBtn.setTitle("View Receipt", for: .normal)
                cell.placeOrder = { (method) in
                    print("View Receipt")
                    guard let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiptViewController") as? ReceiptViewController else { return }
                    popupVC.orderDic = self.orderDataDic
                    popupVC.total = self.total
                    popupVC.height = 650
                    popupVC.topCornerRadius = 20
                    popupVC.presentDuration = 0.33
                    popupVC.dismissDuration = 0.33
                    popupVC.popupDelegate = self
                    popupVC.shouldDismissInteractivelty = false
                    popupVC.previousObj = self
                    self.present(popupVC, animated: true, completion: nil)
                }
            }else{
                cell.checkOutBtn.isHidden = false
                cell.placeOrder = { (method) in
                    if method == .cod{
                        self.callPaymentAPI(orderIDStr: (self.orderDataDic.OID?.toString())!, url: ServerUrl.confirmRecievedUrl)
                    }else{
                        let viewController = BarcodeScannerViewController()
                        viewController.codeDelegate = self
                        viewController.errorDelegate = self
                        viewController.dismissalDelegate = self
                        self.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        }else if  self.orderDataDic.getOrderStatus() == .pending {
            let status = orderStatus.filter({$0 == "pending"})
            if self.orderStatus.count == status.count{
                cell.checkOutBtn.isHidden = false
                cell.checkOutBtn.setTitle("Cancel Order", for: .normal)
            }else{
                cell.checkOutBtn.isHidden = true
            }
            cell.placeOrder = { (method) in
                self.cancelOrder(orderIDStr: (self.orderDataDic.OID?.toString())!, url: ServerUrl.cancelOrder)
            }

        }else if self.orderDataDic.getOrderStatus() == .completed{
            if orderDataDic.rate_driver == 0 {
                cell.checkOutBtn.isHidden = false
                cell.checkOutBtn.setTitle("Review Order", for: .normal)
                cell.placeOrder = { (method) in
                    guard let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiptViewController") as? ReceiptViewController else { return }
                    popupVC.orderDic = self.orderDataDic
                    popupVC.total = self.total
                    popupVC.height = 650
                    popupVC.topCornerRadius = 20
                    popupVC.presentDuration = 0.33
                    popupVC.dismissDuration = 0.33
                    popupVC.popupDelegate = self
                    popupVC.shouldDismissInteractivelty = false
                    popupVC.previousObj = self
                    self.present(popupVC, animated: true, completion: nil)
                }
            }
        }
        return cell
    }
    
    private func getDeliveryDetailTableCell(_ indexPath: IndexPath) -> DeliveryDetailTableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! DeliveryDetailTableViewCell
        cell.deliveryDetailTitleLbl.text = "Delivery Detail".localized()
        cell.addressLabel.text = self.orderDataDic.delivery_address?.address ?? "Address not found"
        cell.addressLabel.numberOfLines = 2

        let name = restuarentID.compactMap({$0.name}).uniques.joined(separator: "\n")
        cell.itemLabel.text = name.capitalized
        cell.priceLabel.isHidden = true
        
        
        var distance = [String]()
        let coordinate₀ = CLLocation(latitude: CurrentSession.getI().localData.profile.default_address!.latitude ?? 0, longitude: CurrentSession.getI().localData.profile.default_address!.longitude ?? 0)

        
        for value in restLatLong{
            let coordinate₁ = CLLocation(latitude: value.lat , longitude: value.long)
            let distanceInMeters = coordinate₀.distance(from: coordinate₁)/1000
            let distnace = String(format: "%.2fkm",distanceInMeters)
            distance.append(distnace)
        }
        cell.distanceLabel.text =  distance.joined(separator: "\n")
        cell.selectionStyle = .none
        return cell
    }
    
    private func getContactTableCell(_ indexPath: IndexPath) -> ContactInfoTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ContactInfoTableViewCell
        cell.selectionStyle = .none
        return cell
    }
    
    private func getOrderAmountCell(_ indexPath: IndexPath) -> OrderAmountTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nib[1], for: indexPath) as! OrderAmountTableViewCell
        
        var total = 0.0
        var taxTotal = 0.0
        var totalProduct = [Double]()
        let tax_percent = orderDataDic.restaurantWise?.map({$0.tax_percent})
        cell.subTotalTitleLbl.text = "Subtotal".localized()
        cell.deliveryTitleLbl.text = "Delivery Fee".localized()
        cell.vatTitleLbl.text = "incl. VAT".localized()
        if let restaurantWise = orderDataDic.restaurantWise {
            for (_,value) in restaurantWise.enumerated(){
                
                if let cartID = value.cartId{
                    
                    var check = 0.0
                    for (_,cart) in cartID.enumerated(){
                        if let dis = orderDataDic.coupon_discount,dis > 0{
                            let realValue = Double(cart.dish_price ?? 0)
                            let addUpValue = (realValue) * Double(value.restaurantId?.add_up_value ?? Int(0.0)) / 100.0
                            let toppingPrice = Double(cart.topping_price ?? 0)
                            let totalDishPrice  =   (realValue + addUpValue + toppingPrice) * Double(cart.quantity ?? 1)
                            total = total + totalDishPrice
                            check = check + totalDishPrice
                        }else{
                            var  realValue = Double(cart.dish_price ?? 0)
                            
                            if let type = cart.discount_type,let dicount = cart.dish_discount{
                                if type == "percent"{
                                    let percent = realValue * dicount / 100
                                    realValue = realValue - percent
                                }else{
                                    realValue = realValue - dicount
                                }
                            }
                            
                            
                            let addUpValue = (realValue) * Double(value.restaurantId?.add_up_value ?? Int(0.0)) / 100.0
                            let toppingPrice = Double(cart.topping_price ?? 0)
                            let totalDishPrice  =   (realValue + addUpValue + toppingPrice) * Double(cart.quantity ?? 1)
                            total = total + totalDishPrice
                            check = check + totalDishPrice
                        }
                      
                    }
                    totalProduct.append(check)
                }
                
                cell.subTotalLabel.text = String(format: "$ %.2f", total)

                
                
//                let realValue = Double(value.cartId?.compactMap({$0.dish_price}).reduce(0, +) ?? Int(0.0))
//                let addUpValue = (realValue) * Double(value.restaurantId?.add_up_value ?? Int(0.0)) / 100.0
//                total =  total + realValue + addUpValue
//                totalProduct.append(realValue + addUpValue)
            }
        }
        if let checkTmpBool = orderDataDic.restaurantWise?.compactMap({$0.tax_applicable}){
            var tax  = 0.0
            if checkTmpBool.contains("no"){
                for (index,value) in checkTmpBool.enumerated(){
                    if value == "no"{
                        taxTotal =  taxTotal + totalProduct[index]
                    }
                }
                tax  = ((total - taxTotal) * (10 )) / 100
                cell.vatLabel.text = String(format: "$ %.2f", tax)
                
            }else{
                tax  = ((total) * (10 )) / 100
                cell.vatLabel.text = String(format: "$ %.2f", tax)
            }
            if let dis = orderDataDic.coupon_discount,dis > 0{
                if let  type = orderDataDic.coupon_type,type == "percent"{
                    let percent = (total * dis / 100)
                    total = total - percent
                    cell.couponCode.text = String(format: "$ %.2f", percent)
                    cell.CouponBtn.setTitle(orderDataDic.coupon_code ?? "", for: .normal)
                }else{
                    cell.couponCode.text = String(format: "$ %.2f", dis)
                    total = total - Double(dis)
                }
            }else{
            }

            let delivery = self.orderDataDic.delivery_charges ?? 0.0
            total = total + tax + delivery
            cell.totalAmtLabel.text = String(format: "$ %.2f", total)
            self.total = total
        }
        
        
        cell.deliveryLabel.text = String(format: "$ %.2f", self.orderDataDic.delivery_charges ?? 0.0)
        cell.CouponBtn.setTitle("Coupon: \(orderDataDic.coupon_code ?? "")", for: .normal)
        cell.removeCouponBtn.isHidden = true
        cell.selectionStyle = .none
        return cell
    }
    
    private func getOrderItemCell(_ indexPath: IndexPath) -> OrderItemTableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: nib[0], for: indexPath) as! OrderItemTableViewCell
        cell.isFromOrder = true
        cell.ordersData = self.restuarentID[indexPath.row]
        if let _ = self.orderDataDic {
            if  let cartID = self.orderDataDic.restaurantWise?.compactMap({$0.cartId}).reduce([], +){
                cell.initView(withData: cartID[indexPath.row])
            }
            cell.initViewForHistoryDetail()
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func loadWriteViewController() {
        guard let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewViewController") as? ReviewViewController else { return }
        popupVC.orderDic = self.orderDataDic
        popupVC.height = 650
        popupVC.topCornerRadius = 20
        popupVC.presentDuration = 0.33
        popupVC.dismissDuration = 0.33
        popupVC.popupDelegate = self
        popupVC.shouldDismissInteractivelty = false
        popupVC.previousObj = self
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func callPaymentAPI(orderIDStr : String,url:String) {
        self.repo.confirmOrder(orderIDStr,url:url) { (data) in
            guard let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "ReceiptViewController") as? ReceiptViewController else { return }
            popupVC.orderDic = self.orderDataDic
            popupVC.total = self.total
            popupVC.height = 650
            popupVC.topCornerRadius = 20
            popupVC.presentDuration = 0.33
            popupVC.dismissDuration = 0.33
            popupVC.popupDelegate = self
            popupVC.shouldDismissInteractivelty = false
            popupVC.previousObj = self
            self.present(popupVC, animated: true, completion: nil)
        }
    }
  
    func cancelOrder(orderIDStr : String,url:String){
        self.repo.cancelOrder(orderIDStr, url: url) { (data) in
            oneButtonAlertControllerWithBlock(msgStr: "Your order has been Cancelled successfully!", naviObj: self) { (true) in
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func bottomPopupDidDismiss() {
        print("bottomPopupWillDismiss")
    }
}

extension Int{
    func toString() -> String{
        let myString = String(self)
        return myString
    }
}

extension OrderViewController: BarcodeScannerCodeDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
        controller.dismiss(animated: true) {
            print("---------->")
            print(code)
            self.callPaymentAPI(orderIDStr: code, url: ServerUrl.scanQrCode)
        }
        controller.reset(animated: true)
    })
  }
}

extension OrderViewController: BarcodeScannerErrorDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
    print(error)
  }
}

extension OrderViewController: BarcodeScannerDismissalDelegate {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
}


