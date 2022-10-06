//
//  OrderDetailViewController.swift
//  Restaurant
//
//  Created by MAC on 21/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import CoreLocation

class CartViewController: BaseTableViewController<CartData> {
    
    @IBOutlet weak var btn_confirmOrder: UIButton!
    @IBOutlet weak var btn_tap: UIButton!
    @IBOutlet weak var lbl_addTitle: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    @IBOutlet weak var vw_address: UIView!
    var expandedOrder  = false
    private let repo = CartRepository()
    private var numberOfSection = 0
    private var cartItems: [[CartItemData]] = []
    @IBOutlet weak var emptyCartImage: UIImageView!
    var paymentTypeCell : PaymentMethodTableViewCell!
    
    override func viewDidLoad() {
        nib = [TableViewCell.orderItemTableViewCell.rawValue, TableViewCell.orderAmountTableViewCell.rawValue,
               TableViewCell.contactInfoTableViewCell.rawValue,
               TableViewCell.deliveryDetailTableViewCell.rawValue,
               TableViewCell.paymentMethodTableViewCell.rawValue]
        super.viewDidLoad()
        
        btn_confirmOrder.setTitle("Confirm Order".localized(), for: .normal)
        btn_tap.setTitle("Tap to change".localized(), for: .normal)
        lbl_addTitle.text   = "Do you want to change  delivery location?".localized()
        
        
        createNavigationLeftButton(NavigationTitleString.viewProduct.localized())
        addNotification()
        repo.getCartItems { (data) in
            self.data = data
            self.data?.couponDic = data.promoApplied
            CurrentSession.getI().localData.cart = data
            CurrentSession.getI().saveData()
            self.seprateRestaurantWise()
        }
    }
    
    
    @IBAction func onActionChangeAddress(_ sender: Any) {
        let vc: AddAddressViewController = self.getViewController(.address, on: .map)
        vc.restaurantLocation = self.data?.cartItems[0].restaurant_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onActionClose(_ sender: Any) {
        self.vw_address.alpha = 0.0
    }
    @IBAction func onActionOrder(_ sender: Any) {
        if let _ = CurrentSession.getI().localData.profile.default_address {
            let coordinate₀ = CLLocation(latitude: CurrentSession.getI().localData.profile.default_address?.latitude ?? 0, longitude: CurrentSession.getI().localData.profile.default_address?.longitude ?? 0)
            let coordinate₁ = CLLocation(latitude: self.data?.cartItems[0].restaurant_id?.latitude ?? 0, longitude: self.data?.cartItems[0].restaurant_id?.longitude ?? 0)
            let distanceInMeters = coordinate₀.distance(from: coordinate₁)
            if distanceInMeters <= 5000{
                self.vw_address.alpha = 0.0
                self.repo.placeOrder(paymentMethod: Session.paymentType ?? "", onComplition: { (d) in
                    let cart = CartData()
                    cart.cartItems = []
                    CurrentSession.getI().localData.cart = cart
                    CurrentSession.getI().saveData()
                    oneButtonAlertControllerWithBlock(msgStr: "Your order has been placed successfully!", naviObj: self) { (true) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                })
            }else{
                self.showAlert(msg: "Your address is outside the restaurant's delivery area!")
            }
            
        }else{
            let vc: AddAddressViewController = self.getViewController(.address, on: .map)
            vc.restaurantLocation = self.data?.cartItems[0].restaurant_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Session.couponApplied = false
    }
    
    @objc override func onChangeCartItem(notification: Notification) {
        seprateRestaurantWise()
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vw_address.alpha = 0.0
        if CurrentSession.getI().localData.cart.cartItems.count != 0{
            seprateRestaurantWise()
        }
    }

    func seprateRestaurantWise() {
        self.data = CurrentSession.getI().localData.cart
        let cartData = data?.cartItems ?? []
        var restaurant = cartData.compactMap({$0.dish_id?.restaurant_id})
        restaurant.forEach { (item) in
            restaurant.removeAll(where: {$0.id == item.id})
            restaurant.append(item)
        }
        
        self.cartItems.removeAll()
      
        restaurant.forEach { (item) in
            self.cartItems.append(cartData.filter({$0.dish_id?.restaurant_id?.id == item.id}))
        }
        self.emptyCartImage.isHidden = !cartData.isEmpty
        self.tableView.isHidden = cartData.isEmpty
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.cartItems.count == 0{
            return 0
        }
        return self.cartItems.count + 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section >= cartItems.count {
            return 1
        }
        if !self.cartItems.isEmpty{
            if self.cartItems[section].first?.hasExpanded ?? false{
                return self.cartItems[section].count
            }
            return min(self.cartItems[section].count,  2)
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fixSection = cartItems.count - 1
        if indexPath.section <= fixSection {
            return getOrderItemCell(indexPath)
        }else if indexPath.section ==  fixSection + 1 {
            return getOrderAmountCell(indexPath)
        } else if indexPath.section == fixSection + 2 {
            return getContactTableCell(indexPath)
        } else if indexPath.section == fixSection + 3    {
            return getDeliveryDetailTableCell(indexPath)
        } else {
            return getPaymentMethodCell(indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let fixSection = cartItems.count - 1
        if indexPath.section == fixSection + 1 {
            return 150 // for subtotal
        } else if indexPath.section == fixSection + 2 {
            return 120
        }else if indexPath.section == fixSection + 3 {
            return UITableView.automaticDimension
        } else if indexPath.section == fixSection + 4 {
            return 200
        }
        return 80
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= cartItems.count {return nil}
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell4") as! RestaurantMenuTableViewCell
        cell.resName.text = self.cartItems[section].first?.dish_id?.restaurant_id?.name?.capitalized
        cell.showMenu = {
            let vc: StoreInformationViewController = self.getViewController(.storeInformation, on: .home)
            let d = StoreInfomationData()
            d.restaurant = self.cartItems[section].first?.dish_id?.restaurant_id
            vc.data = d
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section >= cartItems.count {return nil}
        if self.cartItems[section].count < 2 {return nil}
        let footer = tableView.dequeueReusableCell(withIdentifier: "footer") as! CartFooterTableViewCell
        footer.expandSection = {
            self.cartItems[section].forEach({$0.hasExpanded = !$0.hasExpanded})
            self.tableView.reloadData()
            
        }
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= cartItems.count {return CGFloat.zero}
        if self.cartItems[section].count < 2 {return CGFloat.zero}
        return 30
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section >= cartItems.count {return CGFloat.zero}
        return 80
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fixSection = cartItems.count - 1
        if indexPath.section <= fixSection {
           
        }else if indexPath.section ==  fixSection + 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.callEnterPromocodeAlert()
            })
        } else if indexPath.section == fixSection + 2 {
            
        } else if indexPath.section == fixSection + 3    {
            let vc: AddAddressViewController = self.getViewController(.address, on: .map)
            vc.restaurantLocation = self.data?.cartItems[0].restaurant_id
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            
        }
    }
    
    func callEnterPromocodeAlert() {
        let alert = UIAlertController(title: "", message: "Coupon Code", preferredStyle: UIAlertController.Style.alert )
        let save = UIAlertAction(title: "Submit", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            if textField.text != "" {
                print("Code : \(textField.text!)")
                self.repo.applyCoupnCode(textField.text!) { (data) in
                    print(data)
                    Session.couponApplied = true
                    self.data?.couponDic = data.couponDic
                    self.tableView.reloadData()
                    //self.paymentTypeCell.initView(withData: self.data!)
                    if self.paymentTypeCell != nil{
                        self.paymentTypeCell.initView(withData: CurrentSession.getI().localData.cart)
                    }
                }
            } else {
                print("Empty")
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your Code"
            textField.textColor = .black
        }
    
        alert.addAction(save)
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        self.present(alert, animated:true, completion: nil)
    }
    
    func callRemovePromocode() {
        self.repo.removeCoupnCode() { (data) in
            print(data)
            Session.couponApplied = false
            self.data?.couponDic = data.couponDic
            self.tableView.reloadData()

        }
    }
    
    private func getContactTableCell(_ indexPath: IndexPath) -> ContactInfoTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ContactInfoTableViewCell
        cell.selectionStyle = .none
        if let d = self.data?.user {
            cell.initView(withData: d)
        }
        return cell
    }
    
    
    private func getDeliveryDetailTableCell(_ indexPath: IndexPath) -> DeliveryDetailTableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! DeliveryDetailTableViewCell
        if (self.data?.cartItems.count)! > 0{
            cell.cartItems = self.cartItems
            cell.initView(withData: self.data!)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    private func getPaymentMethodCell(_ indexPath: IndexPath) -> PaymentMethodTableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! PaymentMethodTableViewCell
        self.paymentTypeCell = cell
        cell.initView(withData: CurrentSession.getI().localData.cart)
        cell.selectionStyle = .none
        cell.placeOrder = { (method) in
            self.vw_address.alpha = 1.0
            self.lbl_address.text = CurrentSession.getI().localData.profile.default_address?.address ?? ""
            
            
            
//            if let _ = CurrentSession.getI().localData.profile.default_address {
//                let coordinate₀ = CLLocation(latitude: CurrentSession.getI().localData.profile.default_address?.latitude ?? 0, longitude: CurrentSession.getI().localData.profile.default_address?.longitude ?? 0)
//                let coordinate₁ = CLLocation(latitude: self.data?.cartItems[0].restaurant_id?.latitude ?? 0, longitude: self.data?.cartItems[0].restaurant_id?.longitude ?? 0)
//                let distanceInMeters = coordinate₀.distance(from: coordinate₁)
//                if distanceInMeters <= 5000{
//                    self.repo.placeOrder(paymentMethod: method, onComplition: { (d) in
//                        oneButtonAlertControllerWithBlock(msgStr: "Your order has been placed successfully!", naviObj: self) { (true) in
//                            self.navigationController?.popToRootViewController(animated: true)
//                            CurrentSession.getI().localData.clearAll()
//                        }
//                    })
//                }else{
//                    self.showAlert(msg: "Your address is outside the restaurant's delivery area!")
//                }
//
//            }else{
//                let vc: AddAddressViewController = self.getViewController(.address, on: .map)
//                vc.restaurantLocation = self.data?.cartItems[0].restaurant_id
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
        }
        return cell
    }
    
    private func getOrderAmountCell(_ indexPath: IndexPath) -> OrderAmountTableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: nib[1], for: indexPath) as! OrderAmountTableViewCell
        c.selectionStyle = .none
        if let d = self.data {
            c.initView(withData: d)
        }
        
        c.cancelCoupon = { () in
            if let d = self.data {
                self.callRemovePromocode()
                self.data?.couponDic = nil
                if self.paymentTypeCell != nil{
                    self.paymentTypeCell.initView(withData: self.data!)
                }
                c.initView(withData: d)
            }
        }
       return c
    }
    
    private func getOrderItemCell(_ indexPath: IndexPath) -> OrderItemTableViewCell {
        let c =  tableView.dequeueReusableCell(withIdentifier: nib[0], for: indexPath) as! OrderItemTableViewCell
        c.selectionStyle = .none
        c.initViewForDetail()
        if let _ = self.data {
            c.initView(withData: self.cartItems[indexPath.section][indexPath.row])
        }
        return c
    }
    
}

class RestaurantMenuTableViewCell: BaseTableViewCell<RestaurantProfileData> {
    
    @IBOutlet weak var resName: UILabel!
    var showMenu: (()-> Void)!
    
    @IBAction func showMenu(_ sender: UIButton) {
        showMenu()
    }
    
}

class CartFooterTableViewCell: BaseTableViewCell<BaseData> {
    var expandSection: (()-> Void)!
    @IBAction func expandSection(_ sender: Any) {
        expandSection()
    }
}

struct Session {
    private static let enableCoupon = "coupon_applied"
    private static let payment = "payment_mode"

    static var couponApplied: Bool? {
        get {
            // Read from UserDefaults
            return UserDefaults.standard.object(forKey: enableCoupon) as? Bool
        }
        set {
            // Save to UserDefaults
            UserDefaults.standard.set(newValue, forKey: enableCoupon)
        }
    }
    static var paymentType: String? {
        get {
            // Read from UserDefaults
            return UserDefaults.standard.object(forKey: payment) as? String
        }
        set {
            // Save to UserDefaults
            UserDefaults.standard.set(newValue, forKey: payment)
        }
    }
}
