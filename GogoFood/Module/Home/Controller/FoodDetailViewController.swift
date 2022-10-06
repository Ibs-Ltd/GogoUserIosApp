//
//  FoodDetailViewController.swift
//  GogoFood
//
//  Created by YOGESH BANSAL on 13/02/20.
//  Copyright © 2020 YOGESH BANSAL. All rights reserved.
//

import UIKit
import ImageSlideshow
import SBCardPopup
import Cosmos

class FoodDetailViewController: BaseTableViewController<ProductData> {
    
    
    @IBOutlet weak var lbl_comment: UILabel!
    @IBOutlet weak var constant_height: NSLayoutConstraint!
    @IBOutlet weak var vw_scroll: UIScrollView!
    @IBOutlet weak var lbl_rating: UILabel!

    @IBOutlet weak var lbl_discount: UILabel!
    @IBOutlet weak var bannerViewOutlet: ImageSlideshow!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var stepper: AppStepper!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var soldButton: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var cookingTime: UIButton!
    @IBOutlet weak var deliveryTime: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    var itemDetail: FoodDetailData!
    
    
    
    private lazy var leftImage:UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 32, height: 32)
        imageView.image =  UIImage(named:"backRed")
        let tapGesture = UITapGestureRecognizer.init(target: self, action:#selector(tapOnLeftItem))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private let repo = HomeRepository()
    override func viewDidLoad() {
        
        //nib = [TableViewCell.FoodDetailTableViewCell.rawValue]
        nib = [TableViewCell.listItemTableViewCell.rawValue,
               TableViewCell.homeFooter.rawValue,
        TableViewCell.restuarent_TableViewCell.rawValue]
        //nib = [TableViewCell.HistoryTableViewCell.rawValue]
        super.viewDidLoad()
        DispatchQueue.main.async {
            BaseRepository.shared.dismiss()
        }
       // navigationController?.edgesForExtendedLayout = []
        self.tableView.contentInset.bottom = 50
      //  scrollView.delegate = self
        addNotification()
        refreshView()
       NotificationCenter.default.addObserver(self, selector: #selector(self.onSucessRating), name: Notification.Name("ratingSuccess"), object: nil)

    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          designFooter()
      }
    func refreshView()  {
        var tmpObj = GGSkeletonView()
        tmpObj = tmpObj.createFoodDetailSkeletonView(viewObj: self.view) as! GGSkeletonView
        repo.getDetailOf(self.data!) { (data) in
            self.itemDetail = data
            self.prepareData()
            tmpObj.stopFoodDetailSkeletonView(viewObj: tmpObj)
        }
        let leftButton = UIBarButtonItem.init(customView: leftImage)
        navigationItem.leftBarButtonItem = leftButton
    }
    
    private func prepareData(){
        self.setItemDetail()
        //self.addCartButton()
        self.tableView.reloadData()
        if self.itemDetail.product.isLike == "yes"{
            self.likeBtn.isSelected = true
        }
        if self.itemDetail.product.isFavourites == "yes"{
            self.favBtn.isSelected = true
        }else{
            self.favBtn.isSelected = false
        }
        self.likeCount.text = String(format: "%i ", self.itemDetail.product.totalLikes ?? 0)
        self.lbl_comment.text = String(format: "%i ", self.itemDetail.product.totalComments ?? 0)
        let rating = self.itemDetail.product.avgRating > 0 ?  self.itemDetail.product.avgRating : 4.5
        self.lbl_rating.text = "\(rating ?? 4.5)"
    }
    
    
    
    @objc  func onSucessRating(notification: Notification) {
        refreshView()
     }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeCartItem(notification:)), name: Notification.Name("CartValueGetChanged"), object: nil)
        updateFooter()
      
    }
    override func onChangeCartItem(notification: Notification) {
          super.onChangeCartItem(notification: notification)
          updateFooter()
        setItemDetail()
      }
    
    override func viewDidAppear(_ animated: Bool) {
        transparentNavigationBar()
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            //self.constant_height.constant = 2000
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onActionShare(_ sender: Any) {
        self.generateShareProductLink(url: self.itemDetail.product.dish_images.last ?? "", productName: self.itemDetail.product.name ?? "", productID: self.itemDetail.product.id, restuarentID: self.itemDetail.product.restaurant_id?.id ?? 0)

    }
    @IBAction func onActionComment(_ sender: Any) {
       // if self.itemDetail.product.is_commentable == "yes"{
            let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
            vc.producrtID = self.itemDetail.product
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
       // }
    }
    override func viewWillDisappear(_ animated: Bool) {
           super.viewDidAppear(animated)
            
           visibleNavigationBar()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visibleNavigationBar()
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        print(self.itemDetail.product.id)
        repo.postDishLike(self.itemDetail.product.id.toString()) { (data) in
            if self.likeBtn.isSelected{
                self.itemDetail.product.totalLikes = self.itemDetail.product.totalLikes - 1
            }else{
                self.itemDetail.product.totalLikes = self.itemDetail.product.totalLikes + 1
            }
            self.likeBtn.isSelected = !self.likeBtn.isSelected
            self.likeCount.text = String(format: "%i ", self.itemDetail.product.totalLikes ?? 0)
        }
    }
    
    @IBAction func favButtonClicked(_ sender: UIButton) {
        repo.postDishFavourite(self.itemDetail.product.id.toString()) { (data) in
            self.favBtn.isSelected = !self.favBtn.isSelected
        }
    }
    
    @IBAction func ratingButtonClicked(_ sender: UIButton) {
        print("Open Rating")
        if self.itemDetail.product.user_rated == "not_rated"{
            let popupContent = RatingViewController.create(productObj: self.itemDetail.product)
            let cardPopup = SBCardPopupViewController(contentViewController: popupContent)
            cardPopup.show(onViewController: self)
            print("Opened")
        }
        print("not available Rating")

    }
    
    @IBAction func commentButtonClicked(_ sender: UIButton) {
        if self.itemDetail.product.is_commentable == "yes"{
            let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
            vc.producrtID = self.itemDetail.product
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setItemDetail() {
        guard let detail = self.itemDetail else {return}
        self.itemName.text = detail.product.name?.capitalized
        let rating = self.itemDetail.product.avgRating > 0 ?  self.itemDetail.product.avgRating : 4.5
        self.lbl_rating.text = "\(rating ?? 4.5)"
        let soldText = "Sold: \(detail.product.sold_qty ?? 0)"
        soldButton.setTitle(soldText, for: .normal)
//        let discount = Int(detail.product.discount_percentage ?? 0.0)
//        self.lbl_discount.isHidden = discount > 0 ? false : true
//        self.lbl_discount.text = "  \(discount)% DISCOUNT"
        self.itemPrice.text = "$\(detail.product.getFinalPriceAfterAddUpValue())"
        //detail.product.getFinalAmount(stikeColor: AppConstant.primaryColor, normalColor: AppConstant.appBlueColor, fontSize: 15, inSameLine: true)
        if detail.product.restaurant_id?.storeStaus == "closed"{
            self.stepper.isHidden = true
        }else{
            self.stepper.isHidden = false
        }
        self.stepper.dish = detail.product
        self.tableView.reloadData()
        self.cookingTime.setTitle(detail.product.getCookingTime(), for: .normal)
        self.deliveryTime.setTitle(detail.product.getDeliveryTime(), for: .normal)
        
        self.setBannerData()
    }
    
    deinit {
        removeNotification()
        repo.disconnectSocket()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CartValueGetChanged"), object: nil)

    }
    func escape(string: String) -> String {
          let unreserved = "-._~/?%$!:"
          let allowed = NSMutableCharacterSet.alphanumeric()
          allowed.addCharacters(in: unreserved)
          let escapedString = string.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
          return escapedString!
      }
    
    func setBannerData() {
        if itemDetail.product.dish_images.count > 0{

//            let urlString = itemDetail.product.dish_images?[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            bannerViewOutlet.setImageInputs(itemDetail.product.dish_images.compactMap({SDWebImageSource(urlString: self.escape(string: $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!}))

        //    bannerViewOutlet.setImageInputs([(SDWebImageSource(urlString: (urlString ?? ""), placeholder: UIImage(named: "")) ?? SDWebImageSource(urlString: "https://gogo-food.s3.ap-southeast-1.amazonaws.com/1587550577357-ice.jpg")!)])
        }else{
            
            let urlString = itemDetail.product.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            bannerViewOutlet.setImageInputs([(SDWebImageSource(urlString: (urlString ?? ""), placeholder: UIImage(named: "")) ?? SDWebImageSource(urlString: "https://gogo-food.s3.ap-southeast-1.amazonaws.com/1587550577357-ice.jpg")!)])
        }
        
        //bannerViewOutlet.setImageInputs([SDWebImageSource(urlString: itemDetail.product.image ?? "") ?? ""])
        
        bannerViewOutlet.zoomEnabled = true
        bannerViewOutlet.contentScaleMode = .scaleAspectFill
        bannerViewOutlet.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        bannerViewOutlet.activityIndicator = DefaultActivityIndicator(style: .gray, color: nil)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FoodDetailViewController.didTap))
        bannerViewOutlet.addGestureRecognizer(gestureRecognizer)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let detail = self.itemDetail else {return 0}
        var count = 0.0
        if indexPath.section == 0{
            // recommended
            count = (Double(detail.recommended.count)/2)
        }else{
            // Similar
            count = (Double(detail.similar.count)/2)
        }
        if count > 0 {
            return CGFloat(246 * count.rounded()) + CGFloat((10.0*(count-1)))
        }else{
            return CGFloat(0.0)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "header") as! FoodDetailHeaderTableViewCell
        headerView.frame.origin.x = -20
        headerView.typeLabel.text  = section == 0 ? "Recommended" : "Similars"
        headerView.typeLabel.font = UIFont.systemFont(ofSize: 25, weight: .regular)
        // Top Border & Bottom Border
        let topBorderView = UIView(frame: CGRect(x: 0, y: 0, width: headerView.frame.size.width, height: 8))
        topBorderView.backgroundColor = .groupTableViewBackground
        headerView.addSubview(topBorderView)
        
        guard let detail = self.itemDetail  else {return UIView()}
        if section == 0 {
            return detail.recommended.count > 0 ? headerView : UIView()
        }else{
            return detail.similar.count > 0 ? headerView : UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let detail = self.itemDetail  else {return 0}

        if section == 0 {
            return detail.recommended.count > 0 ? 44 : 0
        }else{
            return detail.similar.count > 0 ? 44 : 0
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let detail = self.itemDetail else {return UITableViewCell()}
        let c = tableView.dequeueReusableCell(withIdentifier: nib[2], for: indexPath) as!   Restuarent_TableViewCell
        c.initWithData(indexPath.section == 0 ? detail.recommended : detail.similar)
        
        c.tapOnCommentButton = { product,index in
            if product.is_commentable == "yes"{
                let vc: FeedDetailViewController = self.getViewController(.feedDetail, on: .home)
                vc.producrtID = product
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            print("Comment Button Clicked")
        }
        c.tapOnDidSelect = { product,index in // didselect collectionview element
            if product.restaurant_id?.storeStaus == "closed"{
                self.oneButtonAlertController(msgStr: "This item is not available at the moment", naviObj: self)
            }else{
                showDetailOf(product: product, vc: self)
            }
        }
        
        c.tapOnShareButton = { product,index in

                       self.generateShareProductLink(url: product.dish_images.last ?? "", productName: product.name ?? "", productID: product.id, restuarentID: product.restaurant_id?.id ?? 0)
                   }
        return c
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let product = indexPath.section == 0 ? self.itemDetail.recommended[indexPath.row] : self.itemDetail.similar[indexPath.row]
//        showDetailOf(product: product, vc: self)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {return nil}
//        let c = tableView.dequeueReusableCell(withIdentifier: nib[1]) as! HomeFooterTableViewCell
        if CurrentSession.getI().localData.cart.cartItems.count != 0{
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.zero : 0
    }
    
    
    @objc func didTap() {
        bannerViewOutlet.presentFullScreenController(from: self)
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        //print(scrollView.contentOffset.y)
//        if scrollView == self.scrollView {
//            self.navigationBar.backgroundColor = AppConstant.backgroundColor.withAlphaComponent(scrollView.contentOffset.y / 160)
//        }
//
//    }

    
}

class FoodDetailHeaderTableViewCell: BaseTableViewCell<BaseData>{
    
    @IBOutlet weak var typeLabel: UILabel!
    
    
}
