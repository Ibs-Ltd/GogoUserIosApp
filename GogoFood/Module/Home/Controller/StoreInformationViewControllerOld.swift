//
//  ItemQuantityViewController.swift
//  User
//
//  Created by YOGESH BANSAL on 14/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import SocketIO
import MarqueeLabel

class StoreInformationViewController: BaseTableViewController<StoreInfomationData> {
    
    @IBOutlet weak var restroInfoView: UIView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mealTypes: UILabel!
    @IBOutlet weak var cookingTime: UIButton!
    @IBOutlet weak var totalSold: UILabel!
    @IBOutlet weak var openingInfoView: UIView!
    @IBOutlet weak var openingInfoLbl: UILabel!
    @IBOutlet weak var offerBtn: UIButton!
    @IBOutlet weak var couponsLbl: MarqueeLabel!
    
    private let repo = HomeRepository()
    private var product: [ProductData] = []
    private var selectedTag: UInt!
    var tmpObj = GGSkeletonView()
    
    override func viewDidLoad() {
        nib = [TableViewCell.tagTableViewCell.rawValue,
               TableViewCell.tagTableViewCell.rawValue,
               TableViewCell.restuarent_TableViewCell.rawValue,
               TableViewCell.homeFooter.rawValue,
               TableViewCell.recommendation.rawValue
        ]
        super.viewDidLoad()
        designFooter()
        navigationController?.edgesForExtendedLayout = []

        setRestaurantInfo()
        //createNavigationLeftButton(NavigationTitleString.storeInformation)
        
        if self.data?.restaurant?.storeStaus == "open"{
            self.openingInfoView.backgroundColor = AppConstant.tertiaryColor
            self.openingInfoLbl.text = "Opening"
            self.openingInfoLbl.textColor = AppConstant.tertiaryColor
        }else{
            self.openingInfoView.backgroundColor = AppConstant.appYellowColor
            self.openingInfoLbl.text = "Close"
            self.openingInfoLbl.textColor = AppConstant.appYellowColor
        }
        createNavigationLeftButtonRed(nil)
        tmpObj = tmpObj.createStoreInfoSkeletonView(viewObj: self.view) as! GGSkeletonView
    }
    
    
    fileprivate func loadData(){
        repo.getStoreInformation(self.data?.restaurant?.id ?? 0) { (data) in
            self.data = data
            self.setRestaurantInfo()
            self.getProduct(categoryId: "all", restaurent: self.data?.restaurant?.id ?? 0)
            var mainStr = ""
            for indexDic in 0..<data.coupanDic!.count {
                let tmp = data.coupanDic![indexDic]
                var codeStr = ""
                if tmp.promotionType == "percent"{
                    codeStr = String(format: "%.2f%% off till %@ - Use Promotion code %@", tmp.discount ?? 0, TimeDateUtils.getDataWithTime(fromDate: tmp.expireDate!), tmp.generateCode ?? "0")
                }else{
                    codeStr = String(format: "$%.2f off till %@ - Use Promotion code %@", tmp.discount ?? 0, TimeDateUtils.getDataWithTime(fromDate: tmp.expireDate!), tmp.generateCode ?? "0")
                }
                mainStr = mainStr.appending(codeStr + "  ||  ")
            }
            self.couponsLbl.text = mainStr
        }
    }
    
    
    
    deinit {
       repo.disconnectSocket()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transparentNavigationBar()
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
        updateFooter()
        
        
   //     addCartButton()
        addNotification()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visibleNavigationBar()
    }
    
    override func onChangeCartItem(notification: Notification) {
        super.onChangeCartItem(notification: notification)
        updateFooter()
        self.tableView.reloadData()
    }
    
    func setRestaurantInfo() {
        if let profile = self.data?.restaurant {
            restaurantImageView.setImage(profile.profile_picture ?? "")
//            ServerImageFetcher.i.loadProfileImageIn(restaurantImageView, url: profile.profile_picture ?? "")
            name.text = profile.name
            let cookTimeStr = String(format: "  %@", profile.getCookingTime())
            cookingTime.setTitle(cookTimeStr, for: .normal)
            totalSold.text = profile.getTotalSold()
            mealTypes.text = profile.description
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if let d = self.data?.categories {
                return d.isEmpty ? CGFloat.zero : 60
            }
        }
        return CGFloat.zero
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  section == 1 ? 1 : 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            
            let c =  tableView.dequeueReusableCell(withIdentifier: nib[1]) as! TagTableViewCell
            if let tags = self.data?.categories {
                c.tags = tags
                c.canAddAll = true
                c.select = self.selectedTag
                c.initData()
                c.titleTextHeightConstraint.constant = 0
                
                //c.tagViewOutlet.reload()
                c.onSelectTag = {category, selectedTag in
                    self.selectedTag = selectedTag
                    let categoryId = (selectedTag == 0) ? "all" : category.id.description
                    self.getProduct(categoryId: categoryId, restaurent: (self.data?.restaurant!.id)!)
                }
            }
            return c
        }
        return nil
    }
    
    func getProduct(categoryId: String, restaurent: Int) {
        self.repo.getProductOf(categoryId: categoryId, of: restaurent, limit: 10, page: 1, onComplition: { (data) in
            self.product = data.products
            self.tableView.reloadData()
            if self.tmpObj != nil{
                self.tmpObj.stopStoreInfoSkeletonView(viewObj: self.tmpObj)
            }
        })
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.showProduct(product: product[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let d = self.data{
                return (d.recommended?.isEmpty ?? true) ? 0 : 0
            }
            return 130
        }
        else if indexPath.section == 2{
            return 60.0
        }else{
            let count = (Double(self.product.count)/2)
            if count > 0 {
                return CGFloat(250 * count.rounded()) + 50
            }else{
                return CGFloat(0.0)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c =  tableView.dequeueReusableCell(withIdentifier: nib[4]) as! RecommendationCollectionTableViewCell
            if let recommend = self.data?.recommended {
                c.initView(withData: recommend)
            }
            c.selectProduct = { item in
                self.showProduct(product: item)
                
            }
            return c
            
        }else   if indexPath.section == 1{
            let c = tableView.dequeueReusableCell(withIdentifier: nib[2]) as! Restuarent_TableViewCell
            
            c.backgroundColor = .black
            
            c.initWithData(self.product)
            
            c.tapOnCommentButton = { product,index in
                
                if product.is_commentable == "yes"{
                    let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
                    vc.producrtID = product
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            c.tapOnDidSelect = { product,index in
                self.showProduct(product: product)
            }
                       
            
//            if let profile = self.data?.restaurant {
//                c.restaurantProfile = profile
//                c.initView(withData: product[indexPath.row])
//
//                c.tapOnLikeButton = {
//                    self.repo.postDishLike(self.product[indexPath.row].id.toString()) { (data) in
//                        if c.likeBtn.isSelected{
//                            self.product[indexPath.row].isLike = "no"
//                            self.product[indexPath.row].totalLikes = self.product[indexPath.row].totalLikes - 1
//                        }else{
//                            self.product[indexPath.row].isLike = "yes"
//                            self.product[indexPath.row].totalLikes = self.product[indexPath.row].totalLikes + 1
//                        }
//                        c.likeBtn.isSelected = !c.likeBtn.isSelected
//                        c.likeCount.text = String(format: "%i Likes", self.product[indexPath.row].totalLikes)
//                    }
//                }
//
//                c.tapOnFavButton = {
//                    self.repo.postDishFavourite(self.product[indexPath.row].id.toString()) { (data) in
//                        if c.favBtn.isSelected{
//                            self.product[indexPath.row].isFavourites = "no"
//                        }else{
//                            self.product[indexPath.row].isFavourites = "yes"
//                        }
//                        c.favBtn.isSelected = !c.favBtn.isSelected
//                    }
//                }
//
//                c.tapOnCommentButton = {
//                    if self.product[indexPath.row].is_commentable == "yes"{
//                        let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
//                        vc.producrtID = self.product[indexPath.row]
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                }
//            }
            return c
        }else{
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
                //                    let footer = tableView.dequeueReusableCell(withIdentifier: nib[3]) as! HomeFooterTableViewCell
                //                    footer.totalAmount()
                //                    footer.tapOnButton = {
                //                        self.tapOnCartButton()
                //                    }
                //
                //                    return footer
                //                }else{
                //
                //
                //                }
            }
    }
    
    private func showProduct(product: ProductData) {
        showDetailOf(product: product, vc: self)
    }
    
}

