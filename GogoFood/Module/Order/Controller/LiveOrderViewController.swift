//
//  LiveOrderViewController.swift
//  Restaurant
//
//  Created by MAC on 21/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import CoreLocation


class LiveOrderViewController: BaseTableViewController<OrdersData> {
    
    @IBOutlet weak var onlineStatus: UISwitch!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var badgeImage: UIImageView!
    private let repo = OrderRepository()
    private var liveOrder: [OrderData] = []
    private var acceptedOrder: [OrderData] = []
    private var acceptedDriverOrder: [OrderInfoData] = []
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        nib.append(TableViewCell.restaurantHistoryTableViewCell.rawValue)
        super.viewDidLoad()
        createNavigationLeftButton(nil)
        #if Restaurant
        self.navigationItem.rightBarButtonItem = createNotificationBarButton()
        #endif
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBottomBarWhenPushed = true
       
      
        #if Restaurant
        setOrder()
        #else
        repo.updateUserLocation(CLLocationCoordinate2D()) {
            self.setOrder()
        }
        
        #endif
        
        
    }
    
    @objc func appWillEnterForeground() {
        if self.viewIfLoaded?.window != nil {
            // viewController is visible
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }else{
                let alert = UIAlertController(title: "Location Error", message: "Please enable location", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Enable Location", style: .default, handler: { (_) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }

    override func createNavigationLeftButton(_ withTitle: String?) {
        self.profileImage.contentMode = .scaleAspectFill
        ServerImageFetcher.i.loadProfileImageIn(profileImage, url: CurrentSession.getI().localData.profile.profile_picture ?? "")
    }
    
    @IBAction func showProfile(_ sender: UIButton) {
        let c: EditProfileViewController = self.getViewController(.editProfile, on: .setting)
        c.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(c, animated: true)
        
    }
    
    deinit {
        repo.disconnectSocket()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 1)
        ? acceptedOrder.isEmpty ? 1 : acceptedOrder.count
        : liveOrder.isEmpty ? 1 : liveOrder.count
       
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellFor(indexPath: indexPath, tableView: tableView)
    }
    
    func getCellForEmpty(_ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EmptyWaitingTableViewCell
        #if Driver
        cell.imageVie.image = UIImage(named: "waiting")
        #endif
        cell.imageVie.isHidden = (indexPath.section == 1)
        cell.emptyMessage.isHidden = (indexPath.section == 0)
        cell.emptyMessage.text = AppStrings.noLiveOrder
        cell.label.text = (indexPath.section == 1)
            ? AppStrings.todayOrder
            : AppStrings.waitingForNewOrder
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0
        ? liveOrder.isEmpty ? tableView.frame.height / 2 : UITableView.automaticDimension
        : acceptedOrder.isEmpty ? tableView.frame.height / 2 : UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectat(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        let yourLabel: UILabel = UILabel()
        yourLabel.frame = CGRect(x: 10, y: 0, width: 200, height: 40)
        yourLabel.textColor = UIColor.black
        yourLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        if self.liveOrder.isEmpty{
            yourLabel.text = section == 0 ? "Waiting for New Order" : "Today's Order"
        }else{
            yourLabel.text = section == 0 ? "New Task" : "Today's Order"
        }
        headerView.addSubview(yourLabel)
        return headerView
    }
    
    @IBAction func setOnline(_ sender: UISwitch) {
        #if Driver
        repo.setAvailaiblityStatus(sender.isOn ? "online" : "Offine") {
        }
        #endif
    }
}

// Set Live order for the restaurant
#if Restaurant
extension LiveOrderViewController {
    
    func setOrder() {
        if (CurrentSession.getI().localData.profile.userStatus) == .pending || (CurrentSession.getI().localData.profile.userStatus ?? .inital) == .inital {
            self.showAlert(msg: "Your request is pending from admin. Please wait until admin take action")
        }else{
            repo.getOrder() { item in
                self.repo.getTodayOrder() { item in
                    print(item)
                    self.acceptedOrder = item.order
                    self.tableView.reloadData()
                }
                self.data = item
                self.filterOrder()
            }
        }
    }
    
    private func filterOrder() {
        if let d = self.data {
            self.liveOrder = d.order.filter({$0.getOrderStatus() == .pending}).filter({$0.cart_id?.count != 0}).filter({$0.order_id != nil})
            self.tableView.reloadData()
        }
    }
    
    func getCellFor(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        // section 0 will show the accepted order
        if indexPath.section == 0 {
            return self.liveOrder.isEmpty
            ? getCellForEmpty(indexPath, tableView)
            : getOrderCell(indexPath, tableView)
        }
        return self.acceptedOrder.isEmpty
        ? getCellForEmpty(indexPath, tableView)
        : getOrderCell(indexPath, tableView)
    }
    
    private func getOrderCell(_ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "restaurantOrder", for: indexPath) as! RestaurantOrderTableViewCell
        c.selectionStyle = .none
        c.initView(withData:
            (indexPath.section == 1)
            ? self.acceptedOrder[indexPath.row]
                : self.liveOrder[indexPath.row]
        )
        c.onRejectOrder = {
            self.showRejectAlert(indexPath: indexPath)
        }
        return c
    }
    
    func showRejectAlert (indexPath: IndexPath) {
        let alert = UIAlertController.init(title: "Reject Order", message: "Really want to reject order", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
        alert.addAction(
            UIAlertAction(title: "Reject", style: .default, handler: { (_) in
                self.repo.rejectOrder(id: self.liveOrder[indexPath.row].id, response: {
                    self.liveOrder.remove(at: indexPath.row)
                    self.tableView.reloadData()
                })
            })
        )
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func didSelectat(_ indexPath: IndexPath) {
        if indexPath.section == 0 {
            let c: OrderViewController = self.getViewController(.viewOrder, on: .order)
            c.data = self.liveOrder[indexPath.row]
            c.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(c, animated: true)
        }else{
            let c: OrderViewController = self.getViewController(.viewOrder, on: .order)
            c.data = self.acceptedOrder[indexPath.row]
            c.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(c, animated: true)
        }
    }
}

#else
extension LiveOrderViewController {
    
    func setOrder() {
        repo.getOrderList() { item in
            self.liveOrder = item.newOrder
            item.order.forEach({ (item) in
                let order = OrderData()
                order.order_id = item
                self.acceptedOrder.append(order)
                })
            self.tableView.reloadData()
        }
    }
    
    
    func getCellFor(indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        // section 1 will show the accepted order
        if indexPath.section == 0 {
            return self.liveOrder.isEmpty
                ? getCellForEmpty(indexPath, tableView)
                : getOrderCell(indexPath, tableView)
        }
        return self.acceptedOrder.isEmpty
            ? getCellForEmpty(indexPath, tableView)
            : getOrderCell(indexPath, tableView)
    }
    
    private func getOrderCell(_ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "driverOrder", for: indexPath) as! DriverOrderTableViewCell
        c.isForAceptedOrder = (indexPath.section == 1)
        if indexPath.section == 0 {
            c.initView(withData: self.liveOrder[indexPath.row])
        }else{
            c.initView(withData: self.acceptedOrder[indexPath.row])
        }
       
        c.onReviewOrder = { isAccepted in
            if indexPath.section == 0 {
              self.onAcceptOrder(indexPath)
            }
        }
        return c
    }
    
    
    func onAcceptOrder(_ indexPath: IndexPath) {
        repo.acceptOrder(self.liveOrder[indexPath.row].order_id?.id ?? 0) {
            self.setOrder()
        }
    }
    
    func didSelectat(_ indexPath: IndexPath) {
        if indexPath.section == 1 {
            let c: DriverMapViewController = self.getViewController(.orderOnMap, on: .map)
            c.data = self.acceptedOrder[indexPath.row]
            c.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(c, animated: true)
        }
        
    }
    
    
    
    
    
    
}

#endif
extension LiveOrderViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
       
    }
}


class EmptyWaitingTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageVie: UIImageView!
    @IBOutlet weak var emptyMessage: UILabel!
    override func awakeFromNib() {
        label.text = AppStrings.waitingForNewOrder
    }
    
    
    
}
