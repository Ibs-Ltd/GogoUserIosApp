//
//  NotificationViewController.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 17/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit

class NotificationViewController: BaseTableViewController<BaseData> {
    
    @IBOutlet weak var noitemImage: UIImageView!
    @IBOutlet weak var emptyLbl: UILabel!
    private let repo = HomeRepository()
    var selectedIndexPath: IndexPath?
    var extraHeight: CGFloat = 90
    
    var notificationListArray : [NotificationList]!
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        nib = [TableViewCell.notificationTableViewCell.rawValue]
        super.viewDidLoad()
        emptyLbl.text  = "There is no notification yet!".localized()
        self.setNavigationTitleTextColor(NavigationTitleString.notification.localized())
        self.tableView.tableFooterView = UIView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        designFooter()
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
       }
     @objc override func onChangeCartItem(notification: Notification) {
         super.onChangeCartItem(notification: notification)
         updateFooter()
     }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
        updateFooter()
        
        var tmpObj = GGSkeletonView()
        tmpObj = tmpObj.createFoodCategorySkeletonView(viewObj: self.view) as! GGSkeletonView

        self.repo.notificationListAPI() { (data) in
            print(data)
            tmpObj.stopHomeSkeletonView(viewObj: tmpObj)

            self.notificationListArray = data.notifications
            if self.notificationListArray.count == 0{
                self.noitemImage.isHidden = false
                self.emptyLbl.isHidden = false
                
            }else{
                self.noitemImage.isHidden = true
                self.emptyLbl.isHidden = true
                self.tableView.reloadData()
            }
        }
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    
    @objc private func refreshWeatherData(_ sender: Any) {
        refreshdata()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.notificationListArray != nil{
            return self.notificationListArray.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCellNew") as! NotificationTableViewCellNew
        let cellDic = self.notificationListArray[indexPath.row]
        cell.titleLbl.text = cellDic.notificationId?.title ?? ""
        cell.subtitle.text = cellDic.notificationId?.descriptionField ?? ""
        cell.dateLbl.text = TimeDateUtils.getDateOnly(fromDate: cellDic.createdAt!)
        if self.selectedIndexPath == indexPath {
            cell.imageCon.constant = 150
        }else{
            cell.imageCon.constant = 0
        }
        if cellDic.notificationId?.notifyType == "image"{
            cell.typeImage.image = UIImage(named: "news")
            ServerImageFetcher.i.loadImageIn(cell.cellImageObj, url: cellDic.notificationId?.image  ?? "")
            cell.cellImageObj.isUserInteractionEnabled = true
        }else{
            cell.typeImage.image = UIImage(named: "news")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let cellDic = self.notificationListArray[indexPath.row]
        if cellDic.notificationId?.type == "image"{
            self.selectedIndexPath = indexPath
            tableView.reloadData()
        }
        if cellDic.notificationId?.type == "comment"{
            let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
            vc.hidesBottomBarWhenPushed = true
            vc.noti.isFromNoti = true
            vc.noti.dishID = cellDic.notificationId?.dish_id ?? 0
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func estimatedLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: font]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        return rectangleHeight
    }
}

class NotificationTableViewCellNew: UITableViewCell {
    
    @IBOutlet var typeImage : UIImageView!
    @IBOutlet var titleLbl : UILabel!
    @IBOutlet var subtitle : UILabel!
    @IBOutlet var dateLbl : UILabel!
    @IBOutlet var imageCon : NSLayoutConstraint!
    @IBOutlet var cellImageObj : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
extension NotificationViewController{
    func refreshdata()  {
        self.repo.notificationListAPI() { (data) in
            print(data)
            self.notificationListArray = data.notifications
            if self.notificationListArray.count == 0{
                self.noitemImage.isHidden = false
                self.emptyLbl.isHidden = false
            }else{
                self.noitemImage.isHidden = true
                self.emptyLbl.isHidden = true
                self.tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
}

