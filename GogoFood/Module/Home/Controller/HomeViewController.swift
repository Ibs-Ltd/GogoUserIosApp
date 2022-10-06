//
//  HomeViewController.swift
//  User
//
//  Created by YOGESH BANSAL on 16/02/20.
//  Copyright © 2020 GWS. All rights reserved.
//

import UIKit
import ImageSlideshow
import SkeletonView
import MapKit
import GoogleMaps
import MarqueeLabel
class HomeViewController: BaseTableViewController<HomeData>, ImageSlideshowDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var lbl_sold: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bannerView: ImageSlideshow!
    //@IBOutlet weak var profileImage: UIImageView!
    //@IBOutlet weak var badgeImage: UIImageView!
    //@IBOutlet weak var searchBa: SearchBar!
    private let repo = HomeRepository()
  
    ////Banner
    @IBOutlet weak var soldView: UIView!
    @IBOutlet weak var soldLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceView: UIView!
    private var currentBannerItem = 0
    
    @IBOutlet weak var orderNowButton: UIButton!
    private let repoCart = CartRepository()
    var refreshControl = UIRefreshControl()
    var tmpObj = GGSkeletonView()
    private let geoCoder = GMSGeocoder()

    //////End banner
    
    private lazy var titleLabel:MarqueeLabel = {
        let label = MarqueeLabel()
        label.text = ""
        label.textColor = AppConstant.secondaryColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.frame =  CGRect.init(x: 10, y: 4, width: self.view.frame.width - 100, height: 30)
        return label
    }()
    
    
//    private let mapPinImageView:UIImageView = {
//        let imageSize:CGSize = CGSize(width: 24, height: 24)
//        let imageView = UIImageView(frame: CGRect.init(origin: .zero, size: imageSize))
//        imageView.backgroundColor = .lightGray
//        return imageView
//    }()
    
    override func viewDidLoad() {
        nib = [TableViewCell.tagTableViewCell.rawValue,
               TableViewCell.foodCollectionTableViewCell.rawValue,
               TableViewCell.restrauntCollectionTableViewCell.rawValue,
               TableViewCell.homeFooter.rawValue]
        
        super.viewDidLoad()
       // getCurrentLocationName()
        lbl_sold.text = "Sold".localized()
        orderNowButton.setTitle("order now".localized(), for: .normal)
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        
        tmpObj = tmpObj.createHomeSkeletonView(viewObj: self.view) as! GGSkeletonView
        definesPresentationContext = true
      //  self.searchBa.searchView.delegate = self
    }
    deinit {
           NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)
      }
    @objc override func onChangeCartItem(notification: Notification) {
        super.onChangeCartItem(notification: notification)
        updateFooter()
        self.tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        DispatchQueue.main.async {
            BaseRepository.shared.dismiss()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        designFooter()
    }
    
    func getCurrentLocationName()  {
        
        let latObj =  UserDefaults.standard.value(forKey: "current_latitude") as? Double ?? 23
        let lngObj = UserDefaults.standard.value(forKey: "current_longitude") as? Double ?? 72
        let location = CLLocationCoordinate2D(latitude: latObj, longitude: lngObj)
    
        geoCoder.reverseGeocodeCoordinate(location) { (response, error) in
            if let address = response?.firstResult() {
                let lines = address.lines ?? [""]
                let currentAddress = lines.joined(separator: "\n")
                self.titleLabel.text = currentAddress + " "
                
//                self.configureNavigationTitle(currentAddress)
                // currentAdd(returnAddress: currentAddress)
            }
        }
        
        
        
//        location.fetchAddress { (address, error) in
//            let address = address
//            self.titleLabel.text = address ?? ""
//            //self.setNavigationTitleTextColor(address ?? "",isHome: true)
//            print(address ?? "")
//        }
    }
    
    
    override func tapOnTrackingButtton() {
           print(tapOnTrackingButtton)
        let storyboard = UIStoryboard.init(name: "History", bundle: nil)
           let vc = storyboard.instantiateViewController(withIdentifier: "OrderTrackingViewController") as! OrderTrackingViewController
           vc.orderID = "\(self.data?.trackingID ?? 0)"
           vc.hidesBottomBarWhenPushed = true
           self.navigationController?.pushViewController(vc, animated: true)
       }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        repo.getHomeData { (data) in
            self.data = data
            self.initateBanner()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        let vc: SearchViewController = self.getViewController(.searchVC, on: .home)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
        updateFooter()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        self.navigationItem.titleView = nil
       // getCurrentLocationName()
        repo.getHomeData { (data) in
            self.data = data
            if data.banners.count == 0 {
                self.bannerView.isHidden = true
                self.orderNowButton.isHidden = true
                self.priceView.alpha = 0.0
                self.initateBanner()
            }else{
                self.orderNowButton.isHidden = false
                self.bannerView.isHidden = false
                self.priceView.alpha = 1.0
                self.initateBanner()
            }
            if self.data?.trackingID == nil {
                self.navigationItem.rightBarButtonItems = [self.createSearchBarButton()]
            }else{
                self.navigationItem.rightBarButtonItems = [self.createTrackingBarButton(),self.createSearchBarButton()]
            }
            self.getCurrentLocationName()
            
            self.tableView.reloadData()
            self.tmpObj.stopHomeSkeletonView(viewObj: self.tmpObj)
        }
    } 
    func startMarqueeLabelAnimation() {
        
        DispatchQueue.main.async(execute: {
            
            UIView.animate(withDuration: 20.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
                self.titleLabel.center = CGPoint(x: 0 - self.titleLabel.bounds.size.width / 2, y: self.titleLabel.center.y)
                
            }, completion:  nil)
            
        })
    }
    override func createNavigationLeftButton(_ withTitle: String?) {
        if CurrentSession.getI().localData.profile.profile_picture == nil{
            
        }else{
           // ServerImageFetcher.i.loadProfileImageIn(profileImage, url: CurrentSession.getI().localData.profile.profile_picture ?? "profile.png")
        }
    }
    
    @IBAction func showProfile(_ sender: Any) {
        self.navigationController?.pushViewController(Controller.editProfile, avaibleFor: StoryBoard.setting)
    }
    
    // MARK:- Banner related stuff
    func initateBanner(){
        bannerView.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .customUnder(padding: 50))
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = AppConstant.primaryColor
        pageIndicator.pageIndicatorTintColor = UIColor.white
        bannerView.pageIndicator = pageIndicator
        bannerView.zoomEnabled = true
        bannerView.delegate = self
        bannerView.circular = true
        bannerView.contentScaleMode = .scaleAspectFill
        bannerView.slideshowInterval = 5
        
        bannerView.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        //bannerView.activityIndicator = DefaultActivityIndicator(style: .gray, color: UIColor.red)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FoodDetailViewController.didTap))
        bannerView.addGestureRecognizer(gestureRecognizer)
        self.setBannerItems()
        if self.data?.banners.count != 0{
            if let d = self.data{
                bannerView.setImageInputs(d.banners.compactMap({SDWebImageSource(urlString: self.escape(string: $0.image!))!}))
            }
        }
        
    }
    
    func escape(string: String) -> String {
        let unreserved = "-._~/?%$!:"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        let escapedString = string.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
        return escapedString!
    }
    
    @objc func didTap() {
//        repoCart.appToCart(dishId: (self.data?.banners[self.currentBannerItem].dish_id)!, toppings: [0]) { (data) in
//            CurrentSession.getI().localData.cart = data
//            CurrentSession.getI().saveData()
//            self.addTrackingAndCartButton()
//        }
        //bannerView.presentFullScreenController(from: self)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let c = tableView.dequeueReusableCell(withIdentifier: self.nib.first!) as! TagTableViewCell
    
        if let home = self.data {
            c.tags = home.categories
            c.initData()
            c.tagViewOutlet.reload()
            c.onSelectTag = { tag, _ in
                let vc: FoodCategoryViewController = self.getViewController(.foodCategory, on: .home)
                vc.lastVCObj = "cat"
                vc.category = tag
                vc.restaurant = tag.restaurant_id
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return c
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if let d = self.data {
            return d.categories.isEmpty ? 0 : 50
        }
        return 15
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return getTopOrder(tableView)
        }else if indexPath.row == 1 {
            return getRecommended(tableView)
        }else if indexPath.row == 2 {
            return getRestaurant(tableView)
        }else{
            if CurrentSession.getI().localData.cart.cartItems.count != 0{
                    let footer = tableView.dequeueReusableCell(withIdentifier: nib[3]) as! HomeFooterTableViewCell
                    footer.totalAmount()
                    footer.tapOnButton = {
                        self.tapOnCartButton()
                    }
                    
                    return UITableViewCell()
            }else{
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
                
            }
        }
    }
    
    private func showRestaurant(all: Bool) {
        let vc: RestaurantsViewController = self.getViewController(.restaurants, on: .home)
        vc.hasShowTopRestuarants = !all
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func getTopOrder(_ tableview: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nib[1]) as! FoodCollectionTableViewCell
        cell.selectionStyle =  .none
        cell.nameLabel.text = "TOP ORDERS".localized()
        
        if let data = data{
            cell.initView(withData: data.topOrder)
            cell.selectProduct = { item in
                showDetailOf(product: item, vc: self)
            }
            cell.tapOnCommentButton = { product,index in
                
                if product.is_commentable == "yes"{
                    let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
                    vc.hidesBottomBarWhenPushed = true
                    vc.producrtID = product
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            cell.tapOnShareButton = { product,index in

                self.generateShareProductLink(url: product.dish_images.last ?? "", productName: product.name ?? "", productID: product.id, restuarentID: product.restaurant_id?.id ?? 0)
            }
            
            
            cell.onTapAll = {
                let vc: FoodCategoryViewController = self.getViewController(.foodCategory, on: .home)
                vc.lastVCObj = "topOrder"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        return cell
        
    }
    
    private func getRecommended(_ tableview: UITableView)-> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nib[1]) as! FoodCollectionTableViewCell
        cell.selectionStyle =  .none
        cell.nameLabel.text = "RECOMMENDED".localized()
        if let data = data {
            cell.initView(withData: data.recommended)
            cell.selectProduct = { item in
                showDetailOf(product: item, vc: self)
            }
            cell.onTapAll = {
                let vc: FoodCategoryViewController = self.getViewController(.foodCategory, on: .home)
                vc.lastVCObj = "rec"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    
        cell.tapOnShareButton = { product,index in
            self.generateShareProductLink(url: product.dish_images.last ?? "", productName: product.name ?? "", productID: product.id, restuarentID: product.restaurant_id?.id ?? 0)
        }
        cell.tapOnCommentButton = { product,index in
            
            if product.is_commentable == "yes"{
                let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
                vc.producrtID = product
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        
        return cell
    }
    
    private func getRestaurant(_ tableview: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: nib[2]) as! RestrauntCollectionTableViewCell
        cell.selectionStyle =  .none

        cell.hideInfoView = true
        
        cell.onTapAll = {
            self.showRestaurant(all: false)
        }
        
        cell.onTapSingleResraunt = { (Obj) in
            let vc: StoreInformationViewController = self.getViewController(.storeInformation, on: .home)
            vc.hidesBottomBarWhenPushed = true
            let data = StoreInfomationData()
            data.restaurant = Obj
            vc.data = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if let _ = data {
            cell.initView(withData: self.data?.topResaturant ?? [])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let d = self.data else{return 0}
        // for topOrder
        if indexPath.row == 0 {
            return d.topOrder.isEmpty ? 0 : 290
        }
        // for recommneded order
        if indexPath.row == 1  {
           return d.recommended.isEmpty ? 0 : 290
        }
        if indexPath.row == 3 {
            return CGFloat(60)
        }
        if indexPath.row == 2 {
            if let data = self.data {
                let count = CGFloat(self.data?.topResaturant.count ?? 0) * 290 + 20
                return data.topResaturant.isEmpty ? 0 : count
            }
        }
        return 0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    @IBAction func orderBannerItem(_ sender: UIButton) {
        //        repoCart.removeDish((self.data?.banners[self.currentBannerItem].dish_id?.id)!) { (data) in
        //            print("Dish Removed")
        //        }
        
        if self.data?.banners[self.currentBannerItem].dish_id?.restaurant_id?.storeStaus == "closed"{
            self.oneButtonAlertController(msgStr: "This item is not available at the moment", naviObj: self)
        }else{
            repoCart.appToCart(dishId: (self.data?.banners[self.currentBannerItem].dish_id)!, toppings: [0]) { (data) in
                CurrentSession.getI().localData.cart = data
                CurrentSession.getI().saveData()
                self.updateFooter()
            }
        }
        
        
        
        //showDetailOf(product: (self.data?.banners[self.currentBannerItem].dish_id)!, vc: self)
    }
    
   
    
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        self.currentBannerItem = page
        setBannerItems()
    }
    
    func setBannerItems() {
        if self.data?.banners.count != 0{
           
            let curentBanner = self.data?.banners[self.currentBannerItem]
            self.soldLabel.text = (curentBanner?.dish_id?.sold_qty ?? 0).description
            
            if curentBanner?.dish_id?.discount_type == "none"{
                priceView.alpha = 0.0
            }else{
                priceView.alpha = 1.0
            }
            let price  = String(format: "%.0f", curentBanner?.dish_id?.discount_percentage ?? 0)
            priceLabel.text = "\(price)%"
            self.soldView.isHidden = self.soldLabel.text == "0"
//          self.priceLabel.text = "$\(curentBanner?.dish_id?.price ?? 0.0)"
            self.priceLabel.textColor = .white
            //curentBanner?.dish_id?.getFinalAmount(stikeColor: AppConstant.appBlueColor, normalColor: UIColor.white, fontSize: 15, inSameLine: false)
            self.priceView.isHidden = self.data?.banners.isEmpty ?? true
            self.soldView.isHidden = self.data?.banners.isEmpty ?? true
            self.orderNowButton.isHidden = self.data?.banners.isEmpty ?? true
        }else{
            self.topView.frame = CGRect(x: self.topView.frame.origin.x, y: self.topView.frame.origin.y, width: self.topView.frame.size.width, height: 0)
        }
    }
}

extension UINavigationController {
    
    func getController(_ vc: Controller, avaibleFor storyBoard: StoryBoard) -> UIViewController {
        
        let storyBoard = UIStoryboard(name: storyBoard.rawValue, bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: vc.rawValue)
        
    }
    
    func pushViewController(_ vc: Controller, avaibleFor storyBoard: StoryBoard){
        let storyBoard = UIStoryboard(name: storyBoard.rawValue, bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: vc.rawValue)
        viewController.hidesBottomBarWhenPushed = true
        self.pushViewController(viewController, animated: true)
        
    }
    
    func present(_ viewControllerToPresent: String, onStoryboard: String,animated flag: Bool, completion: (() -> Void)? = nil) {
        let storyBoard = UIStoryboard(name: onStoryboard, bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: viewControllerToPresent)
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: flag, completion: completion)
    }
    
}
extension UIViewController {
  
     func configureNavigationTitle(_ title: String) {
        let tempLabel = UILabel()
        tempLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        tempLabel.text = title

        if tempLabel.intrinsicContentSize.width > UIScreen.main.bounds.width - 30 {
            var currentTextSize: CGFloat = 34
            for _ in 1 ... 34 {
                currentTextSize -= 1
                tempLabel.font = UIFont.systemFont(ofSize: currentTextSize, weight: .bold)
                if tempLabel.intrinsicContentSize.width < UIScreen.main.bounds.width - 30 {
                    break
                }
            }
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: currentTextSize, weight: .bold)]
        }
        self.title = title
    }
}
